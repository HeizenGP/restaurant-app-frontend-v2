import 'package:flutter/material.dart';
import '../foundations/asia_colors.dart';
import '../foundations/asia_radii.dart';

class AdminSkeletonLoader extends StatefulWidget {
  const AdminSkeletonLoader({
    this.width,
    this.height = 18,
    this.borderRadius = AsiaRadii.sm,
    super.key,
  });

  final double? width;
  final double height;
  final BorderRadius borderRadius;

  @override
  State<AdminSkeletonLoader> createState() => _AdminSkeletonLoaderState();
}

class _AdminSkeletonLoaderState extends State<AdminSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsiaThemeTokens tokens = context.tokens;

    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: tokens.cardElevated.withValues(alpha: _animation.value),
            borderRadius: widget.borderRadius,
            border: Border.all(
              color: tokens.border.withValues(alpha: 0.2),
              width: 0.8,
            ),
          ),
        );
      },
    );
  }
}

class AdminTableSkeleton extends StatelessWidget {
  const AdminTableSkeleton({
    this.rows = 5,
    this.columns = 4,
    super.key,
  });

  final int rows;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(
        rows,
        (_) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: List<Widget>.generate(
              columns,
              (_) => const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: AdminSkeletonLoader(height: 38),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
