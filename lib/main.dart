import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'core/config/app_config.dart';
import 'core/network/http_client.dart' as network;
import 'core/storage/json_store.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/semver.dart';
import 'features/exchange_rates/data/exchange_rate_remote_data_source.dart';
import 'features/exchange_rates/data/exchange_rate_repository_impl.dart';
import 'features/exchange_rates/presentation/home_screen.dart';
import 'features/exchange_rates/presentation/rates_controller.dart';
import 'features/forced_update/data/version_repository_impl.dart';
import 'features/forced_update/domain/version_models.dart';
import 'features/forced_update/presentation/forced_update_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'services/widget_bridge.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await JsonStore.create();
  if (Platform.isWindows &&
      Platform.executableArguments.contains('--background-refresh')) {
    final http = network.HttpClient();
    try {
      await ExchangeRateRepositoryImpl(
        TomanifyRemoteDataSource(http),
        store,
        WidgetBridge(),
      ).refresh();
      exitCode = 0;
    } catch (_) {
      exitCode = 1;
    }
    return;
  }
  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    await windowManager.waitUntilReadyToShow(
      const WindowOptions(
        size: Size(480, 720),
        minimumSize: Size(360, 540),
        center: true,
        title: AppConfig.appName,
      ),
      () async => windowManager.show(),
    );
  }
  runApp(ProviderScope(child: TomanRatesApp(store: store)));
}

class TomanRatesApp extends StatefulWidget {
  const TomanRatesApp({super.key, required this.store});
  final JsonStore store;
  @override
  State<TomanRatesApp> createState() => _AppState();
}

class _AppState extends State<TomanRatesApp> with TrayListener {
  late final RatesController controller;
  VersionConfig? version;
  String installed = '0.0.0';
  bool checking = true, dark = false;
  int page = 0;
  @override
  void initState() {
    super.initState();
    dark = widget.store.readBool('dark_mode') ?? false;
    final http = network.HttpClient();
    controller = RatesController(
      ExchangeRateRepositoryImpl(
        TomanifyRemoteDataSource(http),
        widget.store,
        WidgetBridge(),
      ),
    )
      ..addListener((_) => mounted ? setState(() {}) : null)
      ..start(interval: const Duration(minutes: AppConfig.refreshMinutes));
    WidgetBridge().schedule();
    _checkVersion(VersionRepositoryImpl(http, widget.store));
    if (Platform.isWindows) _setupTray();
  }

  Future<void> _checkVersion(VersionRepository repo) async {
    try {
      installed = (await PackageInfo.fromPlatform()).version;
      version = await repo.check();
    } finally {
      if (mounted) setState(() => checking = false);
    }
  }

  Future<void> _setupTray() async {
    trayManager.addListener(this);
    await trayManager.setToolTip(AppConfig.appName);
    await trayManager.setContextMenu(
      Menu(
        items: [
          MenuItem(key: 'open', label: 'نمایش برنامه'),
          MenuItem(key: 'refresh', label: 'بروزرسانی'),
          MenuItem.separator(),
          MenuItem(key: 'exit', label: 'خروج'),
        ],
      ),
    );
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
    windowManager.focus();
  }

  @override
  void onTrayMenuItemClick(MenuItem item) {
    if (item.key == 'open') {
      windowManager.show();
      windowManager.focus();
    } else if (item.key == 'refresh') {
      controller.refresh();
    } else if (item.key == 'exit') {
      windowManager.destroy();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    if (Platform.isWindows) trayManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blocked = version != null &&
        SemanticVersion.parse(installed).compareTo(version!.minimum) < 0;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConfig.appName,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa'), Locale('en')],
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: checking && controller.current.snapshot == null
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : blocked
              ? ForcedUpdateScreen(config: version!, installed: installed)
              : page == 0
                  ? HomeScreen(
                      state: controller.current,
                      refresh: controller.refresh,
                      openSettings: () => setState(() => page = 1),
                    )
                  : SettingsScreen(
                      dark: dark,
                      onBack: () => setState(() => page = 0),
                      onDarkChanged: (v) {
                        setState(() => dark = v);
                        widget.store.writeBool('dark_mode', v);
                      },
                    ),
    );
  }
}
