import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/rate_model.dart';

/// A polished dashboard card that displays a single [RateModel].
///
/// Features: category-colored icon, price change indicator (▲/▼),
/// hover scale animation, and responsive typography.
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
    final timeStr = DateFormat('hh:mm a, dd MMM yyyy').format(rate.updatedAt);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: Card(
          elevation: _hovering ? 8 : 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Icon with category color ───────────────
                Container(
                  decoration: BoxDecoration(
                    color: rate.iconBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(rate.icon, size: 28, color: rate.iconFgColor),
                ),
                const SizedBox(height: 16),

                // ── Title ──────────────────────────────────
                Text(
                  rate.title,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),

                // ── Price + change indicator ───────────────
                Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          rate.prefix.isNotEmpty
                              ? '${rate.prefix} ${rate.value}'
                              : rate.value,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _ChangeChip(change: rate.change),
                  ],
                ),
                const SizedBox(height: 8),

                // ── Timestamp ──────────────────────────────
                Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        timeStr,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
    switch (change) {
      case PriceChange.up:
        icon = Icons.arrow_drop_up_rounded;
        color = const Color(0xFF2E7D32);
      case PriceChange.down:
        icon = Icons.arrow_drop_down_rounded;
        color = const Color(0xFFC62828);
      case PriceChange.unchanged:
        icon = Icons.remove_rounded;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
