import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../domain/version_models.dart';

class ForcedUpdateScreen extends StatelessWidget {
  const ForcedUpdateScreen({
    super.key,
    required this.config,
    required this.installed,
  });
  final VersionConfig config;
  final String installed;
  @override
  Widget build(BuildContext context) {
    final target = config.telegramUrl.hasAuthority
        ? config.telegramUrl
        : config.downloadUrl;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.system_update_alt,
                      size: 72,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'به‌روزرسانی ضروری',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'نسخه فعلی برنامه دیگر پشتیبانی نمی‌شود. لطفاً برای دریافت آخرین نسخه برنامه را به‌روزرسانی کنید.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'نسخه نصب‌شده: $installed  •  نسخه جدید: ${config.current}',
                    ),
                    if (config.releaseNotes.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(config.releaseNotes, textAlign: TextAlign.center),
                    ],
                    const SizedBox(height: 28),
                    FilledButton.icon(
                      onPressed: () => launchUrl(
                        target,
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('دریافت نسخه جدید'),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: target.toString()),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('نشانی کپی شد')),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: Text(
                        target.toString(),
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
