import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/rates_provider.dart';
import '../widgets/loading_card.dart';
import '../widgets/rate_card.dart';
import '../widgets/section_header.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/tool_card.dart';
import 'tools/currency_converter_page.dart';
import 'tools/emi_calculator_page.dart';
import 'tools/gold_value_calculator_page.dart';
import 'tools/gst_calculator_page.dart';

/// The main dashboard page — Tools section + Live Rates section.
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
    return Scaffold(
      body: Column(
        children: [
          // ── Gradient AppBar ──
          const SharedAppBar(),

          // ── Body ──
          Expanded(
            child: Consumer<RatesProvider>(
              builder: (context, provider, _) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1320),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // ── Welcome Banner ──
                          _WelcomeBanner(
                            refreshAgo: _refreshAgo,
                            isLoading:
                                provider.status == RatesStatus.loading,
                          ),
                          const SizedBox(height: 24),

                          // ── Tools Section ──
                          const SectionHeader(
                            title: 'Financial Tools',
                            icon: Icons.calculate_rounded,
                          ),
                          const SizedBox(height: 12),
                          _buildToolsGrid(context),
                          const SizedBox(height: 28),

                          // ── Live Rates Section ──
                          const SectionHeader(
                            title: 'Live Rates',
                            icon: Icons.show_chart_rounded,
                          ),
                          const SizedBox(height: 12),
                          _buildRatesSection(provider),
                          const SizedBox(height: 24),

                          // ── Footer ──
                          _Footer(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 800 ? 4 : 2;
        final childAspectRatio = width >= 800
            ? 1.1
            : width >= 500
                ? 1.3
                : 0.95;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
          children: [
            ToolCard(
              title: 'EMI Calculator',
              subtitle: 'Home, car & personal loan EMI',
              icon: Icons.account_balance_rounded,
              gradientColors: const [Color(0xFFE65100), Color(0xFFFF8F00)],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const EmiCalculatorPage()),
              ),
            ),
            ToolCard(
              title: 'GST Calculator',
              subtitle: 'CGST, SGST & total GST',
              icon: Icons.receipt_long_rounded,
              gradientColors: const [Color(0xFF1565C0), Color(0xFF42A5F5)],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const GstCalculatorPage()),
              ),
            ),
            ToolCard(
              title: 'Gold Value',
              subtitle: 'Calculate gold value at live rates',
              icon: Icons.monetization_on_rounded,
              gradientColors: const [Color(0xFFFF8F00), Color(0xFFFFC107)],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const GoldValueCalculatorPage()),
              ),
            ),
            ToolCard(
              title: 'Currency Converter',
              subtitle: '24+ currencies, live rates',
              icon: Icons.currency_exchange_rounded,
              gradientColors: const [Color(0xFF00695C), Color(0xFF26A69A)],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CurrencyConverterPage()),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRatesSection(RatesProvider provider) {
    if (provider.status == RatesStatus.loading) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final crossAxisCount = width >= 1100 ? 3 : (width >= 700 ? 3 : 1);
          final childAspectRatio =
              width >= 1100 ? 1.15 : (width >= 700 ? 1.2 : 2.6);
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: childAspectRatio,
            ),
            itemBuilder: (_, _) => const LoadingCard(),
          );
        },
      );
    }

    // Show key rates: Gold, Petrol, USD/INR
    final keyTitles = ['gold rate', 'petrol price', 'usd to inr'];
    final keyRates = provider.rates
        .where((r) => keyTitles.contains(r.title.toLowerCase()))
        .toList();

    // If not enough key rates found, show first 3
    final displayRates =
        keyRates.isNotEmpty ? keyRates : provider.rates.take(3).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1100 ? 3 : (width >= 700 ? 3 : 1);
        final childAspectRatio =
            width >= 1100 ? 1.15 : (width >= 700 ? 1.2 : 2.6);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayRates.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (_, index) =>
              RateCard(rate: displayRates[index]),
        );
      },
    );
  }
}

// ── Welcome Banner ──
class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({
    required this.refreshAgo,
    required this.isLoading,
  });

  final String refreshAgo;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE65100).withValues(alpha: 0.08),
            const Color(0xFFFF8F00).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE65100).withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Daily Rates India 🇮🇳',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your one-stop dashboard for live market rates, EMI calculator, GST calculator, gold value and currency converter.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Live status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    color: isLoading
                        ? Colors.orange.shade700
                        : Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Footer ──
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
