import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/rates_provider.dart';
import '../widgets/error_card.dart';
import '../widgets/loading_card.dart';
import '../widgets/rate_card.dart';

/// The main dashboard page.
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
    final isDark = themeProvider.isDark;

    return Scaffold(
      body: Column(
        children: [
          // ── Gradient AppBar ──────────────────────────
          Container(
            decoration: const BoxDecoration(gradient: AppTheme.appBarGradient),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Logo
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.show_chart_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Rates India',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Text(
                            'Live Market Dashboard',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Dark mode
                    _AppBarButton(
                      icon: isDark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      tooltip: isDark ? 'Light mode' : 'Dark mode',
                      onPressed: themeProvider.toggle,
                    ),
                    const SizedBox(width: 8),
                    // Refresh
                    _AppBarButton(
                      icon: Icons.refresh_rounded,
                      tooltip: 'Refresh',
                      onPressed: () =>
                          context.read<RatesProvider>().fetchAll(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ─────────────────────────────────────
          Expanded(
            child: Consumer<RatesProvider>(
              builder: (context, provider, _) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    int crossAxisCount;
                    double childAspectRatio;
                    if (width >= 1100) {
                      crossAxisCount = 4;
                      childAspectRatio = 1.15;
                    } else if (width >= 700) {
                      crossAxisCount = 2;
                      childAspectRatio = 1.4;
                    } else {
                      crossAxisCount = 1;
                      childAspectRatio = 2.6;
                    }

                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1320),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),

                              // ── Stats bar ────────────────────
                              _StatsBar(
                                refreshAgo: _refreshAgo,
                                rateCount: provider.filteredRates.length,
                                isLoading: provider.status == RatesStatus.loading,
                              ),
                              const SizedBox(height: 16),

                              // ── Search bar ───────────────────
                              SizedBox(
                                height: 46,
                                child: TextField(
                                  onChanged: provider.setSearchQuery,
                                  decoration: InputDecoration(
                                    hintText: 'Search gold, petrol, bitcoin...',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 14,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search_rounded,
                                      size: 20,
                                      color: Colors.grey.shade400,
                                    ),
                                    contentPadding:
                                        const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // ── Grid ─────────────────────────
                              Expanded(
                                child: RefreshIndicator(
                                  onRefresh: provider.fetchAll,
                                  color: const Color(0xFFE65100),
                                  child: _buildGrid(
                                    provider,
                                    crossAxisCount,
                                    childAspectRatio,
                                  ),
                                ),
                              ),

                              // ── Footer ───────────────────────
                              _Footer(),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(
    RatesProvider provider,
    int crossAxisCount,
    double childAspectRatio,
  ) {
    final delegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: childAspectRatio,
    );

    switch (provider.status) {
      case RatesStatus.loading:
        return GridView.builder(
          itemCount: 8,
          gridDelegate: delegate,
          itemBuilder: (_, _) => const LoadingCard(),
        );

      case RatesStatus.error:
        return GridView.builder(
          itemCount: 8,
          gridDelegate: delegate,
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
                    size: 56, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  'No rates match "${provider.searchQuery}"',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade400,
                      ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => provider.setSearchQuery(''),
                  child: const Text('Clear search'),
                ),
              ],
            ),
          );
        }
        return GridView.builder(
          itemCount: items.length,
          gridDelegate: delegate,
          itemBuilder: (_, index) => RateCard(rate: items[index]),
        );
    }
  }
}

// ── Reusable AppBar icon button ─────────────────────────────
class _AppBarButton extends StatelessWidget {
  const _AppBarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

// ── Stats bar with live indicator ───────────────────────────
class _StatsBar extends StatelessWidget {
  const _StatsBar({
    required this.refreshAgo,
    required this.rateCount,
    required this.isLoading,
  });

  final String refreshAgo;
  final int rateCount;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Title
        Text(
          'Market Dashboard',
          style: theme.textTheme.headlineSmall,
        ),
        const Spacer(),

        // Live badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: isLoading ? Colors.orange : Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isLoading
                    ? 'Updating...'
                    : refreshAgo.isNotEmpty
                        ? 'Updated $refreshAgo'
                        : 'Live',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isLoading ? Colors.orange.shade700 : Colors.green.shade700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),

        // Rate count badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$rateCount rates',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Footer ──────────────────────────────────────────────────
class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Divider(color: Colors.grey.shade300, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.show_chart_rounded,
                  size: 16, color: Colors.grey.shade400),
              const SizedBox(width: 6),
              Text(
                'Daily Rates India  •  © 2026  •  Data for informational purposes only',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
