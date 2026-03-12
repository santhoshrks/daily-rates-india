import 'package:flutter/material.dart';

/// Skeleton / shimmer-style loading placeholder card.
class LoadingCard extends StatefulWidget {
  const LoadingCard({super.key});

  @override
  State<LoadingCard> createState() => _LoadingCardState();
}

class _LoadingCardState extends State<LoadingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: [
          // Accent bar skeleton
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: AnimatedBuilder(
              animation: _opacity,
              builder: (context, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon + title row
                    Row(
                      children: [
                        _Bone(width: 42, height: 42, radius: 12, opacity: _opacity.value),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Bone(width: 90, height: 14, opacity: _opacity.value),
                              const SizedBox(height: 6),
                              _Bone(width: 50, height: 10, opacity: _opacity.value),
                            ],
                          ),
                        ),
                        _Bone(width: 40, height: 22, radius: 8, opacity: _opacity.value),
                      ],
                    ),
                    const Spacer(),
                    _Bone(width: 140, height: 22, opacity: _opacity.value),
                    const SizedBox(height: 10),
                    _Bone(width: 100, height: 10, opacity: _opacity.value),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// AnimatedBuilder wrapper.
class AnimatedBuilder extends AnimatedWidget {
  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
  }) : super(listenable: animation);

  final Widget Function(BuildContext, Widget?) builder;

  @override
  Widget build(BuildContext context) => builder(context, null);
}

class _Bone extends StatelessWidget {
  const _Bone({
    required this.width,
    required this.height,
    this.radius = 8,
    required this.opacity,
  });

  final double width;
  final double height;
  final double radius;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: (isDark ? Colors.grey.shade700 : Colors.grey.shade200)
            .withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
