import 'package:flutter/material.dart';
import 'package:aarogivya/core/theme/app_spacing.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.narrow,
    this.medium,
    this.wide,
    this.maxWidth = AppSpacing.maxContentWidth,
  });

  final Widget narrow;
  final Widget? medium;
  final Widget? wide;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1100;
        final isMedium = constraints.maxWidth >= 700;
        final child = isWide
            ? (wide ?? medium ?? narrow)
            : isMedium
                ? (medium ?? narrow)
                : narrow;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        );
      },
    );
  }
}
