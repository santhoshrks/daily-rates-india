import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/rates_provider.dart';

/// Reusable gradient AppBar used across all pages.
class SharedAppBar extends StatelessWidget {
  const SharedAppBar({
    super.key,
    this.title = 'Daily Rates India',
    this.subtitle = 'Live Market Dashboard',
    this.showRefresh = true,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final bool showRefresh;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;

    return Container(
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              ?trailing,
              // Dark mode
              _AppBarIconButton(
                icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                tooltip: isDark ? 'Light mode' : 'Dark mode',
                onPressed: themeProvider.toggle,
              ),
              if (showRefresh) ...[
                const SizedBox(width: 8),
                _AppBarIconButton(
                  icon: Icons.refresh_rounded,
                  tooltip: 'Refresh',
                  onPressed: () => context.read<RatesProvider>().fetchAll(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  const _AppBarIconButton({
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


