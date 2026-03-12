import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/rate_model.dart';

/// A polished dashboard card that displays a single [RateModel].
class RateCard extends StatefulWidget {
  const RateCard({super.key, required this.rate});

  final RateModel rate;

  @override
  State<RateCard> createState() => _RateCardState();
}

class _RateCardState extends State<RateCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rate = widget.rate;
    final timeStr = DateFormat('hh:mm a, dd MMM').format(rate.updatedAt);
    final category = _getCategory(rate.title);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: _hovering
                ? [
                    BoxShadow(
                      color: rate.iconFgColor.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Card(
            child: Stack(
              children: [
                // ── Accent top bar ──────────────────────
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          rate.iconFgColor,
                          rate.iconFgColor.withValues(alpha: 0.4),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                    ),
                  ),
                ),

                // ── Card content ────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Icon + Category row ──────────────
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: rate.iconBgColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Icon(rate.icon, size: 22, color: rate.iconFgColor),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rate.title,
                                  style: theme.textTheme.titleMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: rate.iconBgColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: rate.iconFgColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ChangeChip(change: rate.change),
                        ],
                      ),

                      const Spacer(),

                      // ── Price ─────────────────────────────
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          rate.prefix.isNotEmpty
                              ? '${rate.prefix} ${rate.value}'
                              : rate.value,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: rate.iconFgColor,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ── Timestamp ─────────────────────────
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.green.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Live  •  $timeStr',
                            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getCategory(String title) {
    final t = title.toLowerCase();
    if (t.contains('gold') || t.contains('silver')) return 'METALS';
    if (t.contains('petrol') || t.contains('diesel')) return 'FUEL';
    if (t.contains('usd') || t.contains('eur')) return 'FOREX';
    if (t.contains('bitcoin')) return 'CRYPTO';
    if (t.contains('nifty')) return 'INDEX';
    return 'MARKET';
  }
}

/// Small chip showing ▲ / ▼ / — to indicate price direction.
class _ChangeChip extends StatelessWidget {
  const _ChangeChip({required this.change});
  final PriceChange change;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String label;
    switch (change) {
      case PriceChange.up:
        icon = Icons.trending_up_rounded;
        color = const Color(0xFF2E7D32);
        label = 'UP';
      case PriceChange.down:
        icon = Icons.trending_down_rounded;
        color = const Color(0xFFC62828);
        label = 'DOWN';
      case PriceChange.unchanged:
        icon = Icons.remove_rounded;
        color = Colors.grey;
        label = '—';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          if (change != PriceChange.unchanged) ...[
            const SizedBox(width: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
