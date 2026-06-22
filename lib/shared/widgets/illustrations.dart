import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class HomeIllustration extends StatelessWidget {
  const HomeIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 258),
      child: const AspectRatio(
        aspectRatio: 3 / 2,
        child: Image(
          image: AssetImage('assets/images/home_books_typewriter.jpg'),
          fit: BoxFit.cover,
          alignment: Alignment.center,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

class RocketIllustration extends StatelessWidget {
  const RocketIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 4,
            child: Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 104,
            top: 18,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 108,
            top: 34,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.accent.withValues(alpha: .9),
              size: 15,
            ),
          ),
          Positioned(
            left: 114,
            top: 52,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.secondary.withValues(alpha: .9),
              size: 14,
            ),
          ),
          Positioned(
            bottom: 22,
            child: Icon(
              Icons.cloud_rounded,
              color: AppColors.primary.withValues(alpha: .13),
              size: 126,
            ),
          ),
          Positioned(
            bottom: 26,
            left: 90,
            child: Icon(
              Icons.cloud_rounded,
              color: const Color(0xFFDDE7FF).withValues(alpha: .8),
              size: 62,
            ),
          ),
          Positioned(
            bottom: 29,
            right: 93,
            child: Icon(
              Icons.cloud_rounded,
              color: const Color(0xFFDDE7FF).withValues(alpha: .8),
              size: 62,
            ),
          ),
          Positioned(
            top: 30,
            child: Transform.rotate(
              angle: .16,
              child: SizedBox(
                width: 70,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: 0,
                      child: Container(
                        width: 43,
                        height: 76,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEEF4FF), Colors.white],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2.2,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 24,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: const Color(0xFFBFD7FF),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 6,
                      bottom: 23,
                      child: Transform.rotate(
                        angle: -.28,
                        child: Container(
                          width: 20,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(14),
                              bottomLeft: Radius.circular(14),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 6,
                      bottom: 23,
                      child: Transform.rotate(
                        angle: .28,
                        child: Container(
                          width: 20,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(14),
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      child: Column(
                        children: [
                          Container(
                            width: 18,
                            height: 23,
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(18),
                                bottomRight: Radius.circular(18),
                              ),
                            ),
                          ),
                          Container(
                            width: 9,
                            height: 13,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFE4A3),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 116,
            top: 19,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary.withValues(alpha: .85),
              size: 15,
            ),
          ),
          Positioned(
            left: 118,
            top: 24,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.accent.withValues(alpha: .9),
              size: 14,
            ),
          ),
          Positioned(
            bottom: 17,
            child: Container(
              width: 116,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InsightsIllustration extends StatelessWidget {
  const InsightsIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.violet.withValues(alpha: .12),
                    AppColors.primary.withValues(alpha: .08),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            left: 28,
            bottom: 20,
            child: Icon(
              Icons.person_rounded,
              size: 74,
              color: AppColors.violet.withValues(alpha: .88),
            ),
          ),
          Positioned(
            right: 30,
            bottom: 24,
            child: Container(
              width: 112,
              height: 76,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.stacked_line_chart_rounded,
                color: AppColors.primary,
                size: 52,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
