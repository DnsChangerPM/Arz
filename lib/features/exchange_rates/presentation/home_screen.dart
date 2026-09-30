import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../core/config/app_config.dart';
import '../../../core/utils/formatters.dart';
import '../domain/models.dart';
import 'rates_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.state,
    required this.refresh,
    required this.openSettings,
  });
  final RatesState state;
  final Future<void> Function() refresh;
  final VoidCallback openSettings;
  static const names = {
    'USD': 'دلار آمریکا',
    'EUR': 'یورو',
    'GBP': 'پوند بریتانیا',
    'AED': 'درهم امارات',
    'TRY': 'لیر ترکیه',
    'CNY': 'یوان چین',
  };
  static const symbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'AED': 'د.إ',
    'TRY': '₺',
    'CNY': '¥',
  };
  @override
  Widget build(BuildContext context) {
    final snapshot = state.snapshot;
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConfig.appName),
        actions: [
          IconButton(
            tooltip: 'بروزرسانی',
            onPressed: state.loading ? null : refresh,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'تنظیمات',
            onPressed: openSettings,
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _Status(snapshot: snapshot, error: state.error),
            ),
            if (snapshot == null && state.loading)
              const SliverPadding(
                padding: EdgeInsets.all(16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    _skeleton,
                    childCount: 6,
                  ),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 420,
                    mainAxisExtent: 170,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                ),
              )
            else if (snapshot == null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _Empty(refresh: refresh),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverLayoutBuilder(
                  builder: (context, c) => SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _RateCard(
                        rate: snapshot.rates[i],
                        name:
                            names[snapshot.rates[i].code] ??
                            snapshot.rates[i].code,
                        symbol: symbols[snapshot.rates[i].code] ?? '',
                      ),
                      childCount: snapshot.rates.length,
                    ),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: c.crossAxisExtent > 700 ? 430 : 600,
                      mainAxisExtent: 170,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static Widget _skeleton(BuildContext c, int i) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 20,
            color: Theme.of(c).colorScheme.surfaceContainerHighest,
          ),
          const Spacer(),
          Container(
            width: 220,
            height: 34,
            color: Theme.of(c).colorScheme.surfaceContainerHighest,
          ),
        ],
      ),
    ),
  );
}

class _Status extends StatelessWidget {
  const _Status({this.snapshot, this.error});
  final RateSnapshot? snapshot;
  final String? error;
  @override
  Widget build(BuildContext context) {
    final cached = snapshot?.isCached ?? false;
    final stale =
        snapshot != null &&
        DateTime.now().difference(snapshot!.fetchedAt).inHours >=
            AppConfig.staleHours;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          Card(
            color: (cached || stale)
                ? Theme.of(context).colorScheme.tertiaryContainer
                : null,
            child: ListTile(
              leading: Icon(cached ? Icons.cloud_off : Icons.verified_outlined),
              title: Text(
                cached
                    ? 'اطلاعات ذخیره‌شده'
                    : snapshot?.rateType ?? AppConfig.providerType,
              ),
              subtitle: Text(
                snapshot == null
                    ? 'در حال آماده‌سازی…'
                    : 'منبع: ${snapshot!.provider}  •  آخرین بروزرسانی: ${DateFormat('yyyy/MM/dd – HH:mm').format(snapshot!.sourceDate.toLocal())}',
              ),
            ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }
}

class _RateCard extends StatelessWidget {
  const _RateCard({
    required this.rate,
    required this.name,
    required this.symbol,
  });
  final CurrencyRate rate;
  final String name, symbol;
  @override
  Widget build(BuildContext context) => Semantics(
    label: '$name، یک $rate برابر ${RateFormatter.toman(rate.toman)}',
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(symbol)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rate.code,
                        textDirection: TextDirection.ltr,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(name),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              RateFormatter.toman(rate.toman),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (rate.isDerived)
              const Text(
                'محاسبه‌شده با نرخ متقاطع دلار',
                style: TextStyle(fontSize: 11),
              ),
          ],
        ),
      ),
    ),
  );
}

class _Empty extends StatelessWidget {
  const _Empty({required this.refresh});
  final Future<void> Function() refresh;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 64),
          const SizedBox(height: 16),
          const Text('نرخ معتبری ذخیره نشده است.'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('تلاش دوباره'),
          ),
        ],
      ),
    ),
  );
}
