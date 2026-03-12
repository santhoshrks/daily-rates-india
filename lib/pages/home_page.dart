import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/rates_provider.dart';
import '../widgets/error_card.dart';
import '../widgets/loading_card.dart';
import '../widgets/rate_card.dart';

/// The main dashboard page.
///
/// Responsive grid, search filter, dark mode toggle, refresh countdown,
/// and branded footer.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _ticker;
  String _refreshAgo = '';

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRefreshAgo();
    });
  }

  void _updateRefreshAgo() {
    final provider = context.read<RatesProvider>();
    final last = provider.lastRefreshedAt;
    if (last == null) {
      if (_refreshAgo != '') setState(() => _refreshAgo = '');
      return;
    }
    final diff = DateTime.now().difference(last);
    String text;
    if (diff.inSeconds < 60) {
      text = '${diff.inSeconds}s ago';
    } else {
      text = '${diff.inMinutes}m ago';
    }
    if (text != _refreshAgo) setState(() => _refreshAgo = text);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Rates India'),
        actions: [
          // ── Dark mode toggle ─────────────────────────
          IconButton(
            tooltip: themeProvider.isDark ? 'Light mode' : 'Dark mode',
            icon: Icon(
              themeProvider.isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            onPressed: themeProvider.toggle,
          ),
          // ── Refresh ──────────────────────────────────
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<RatesProvider>().fetchAll(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<RatesProvider>(
        builder: (context, provider, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              int crossAxisCount;
              double childAspectRatio;
              if (width >= 1100) {
                crossAxisCount = 4;
                childAspectRatio = 1.1;
              } else if (width >= 700) {
                crossAxisCount = 2;
                childAspectRatio = 1.4;
              } else {
                crossAxisCount = 1;
                childAspectRatio = 2.4;
              }

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Header row ─────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Market Dashboard',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _refreshAgo.isNotEmpty
                                        ? 'Last refreshed $_refreshAgo  •  Auto-refresh every 5 min'
                                        : 'Live rates refreshed every 5 minutes',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // ── Search bar ─────────────────────
                        SizedBox(
                          height: 44,
                          child: TextField(
                            onChanged: provider.setSearchQuery,
                            decoration: InputDecoration(
                              hintText: 'Search rates...',
                              prefixIcon: const Icon(Icons.search_rounded, size: 20),
                              filled: true,
                              fillColor: Theme.of(context).cardTheme.color,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Grid ───────────────────────────
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: provider.fetchAll,
                            child: _buildGrid(
                              provider,
                              crossAxisCount,
                              childAspectRatio,
                            ),
                          ),
                        ),

                        // ── Footer ─────────────────────────
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            '© 2026 Daily Rates India  •  Data for informational purposes only',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildGrid(
    RatesProvider provider,
    int crossAxisCount,
    double childAspectRatio,
  ) {
    switch (provider.status) {
      case RatesStatus.loading:
        return GridView.builder(
          itemCount: 8,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (_, _) => const LoadingCard(),
        );

      case RatesStatus.error:
        return GridView.builder(
          itemCount: 8,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, _) => ErrorCard(
            onRetry: () => provider.fetchAll(),
          ),
        );

      case RatesStatus.loaded:
        final items = provider.filteredRates;
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off_rounded,
                    size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'No rates match "${provider.searchQuery}"',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          );
        }
        return GridView.builder(
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (_, index) => RateCard(rate: items[index]),
        );
    }
  }
}

