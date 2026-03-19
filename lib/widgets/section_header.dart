import 'package:flutter/material.dart';

/// Section header with title and optional "See All" button.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    required this.icon,
    this.onSeeAll,
  });

  final String title;
  final IconData icon;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFE65100).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFFE65100)),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          if (onSeeAll != null)
            TextButton.icon(
              onPressed: onSeeAll,
              icon: const Text(
                'See All',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE65100),
                ),
              ),
              label: const Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: Color(0xFFE65100),
              ),
            ),
        ],
      ),
    );
  }
}

