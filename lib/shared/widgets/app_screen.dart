import 'package:flutter/material.dart';

import 'bottom_nav.dart';

class AppScreen extends StatelessWidget {
  const AppScreen({
    super.key,
    required this.child,
    this.currentIndex,
    this.bottomPadding = 16,
  });

  final Widget child;
  final int? currentIndex;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: child,
          ),
        ),
      ),
      bottomNavigationBar: currentIndex == null
          ? null
          : BottomNav(currentIndex: currentIndex!),
    );
  }
}
