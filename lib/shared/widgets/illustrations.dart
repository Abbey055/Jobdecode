import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class HomeIllustration extends StatelessWidget {
  const HomeIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 172,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 10,
            child: Container(
              width: 246,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(
            left: 50,
            bottom: 14,
            child: Container(
              width: 86,
              height: 74,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
          Positioned(
            left: 70,
            top: 45,
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFFFFC79B),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 76,
            top: 62,
            child: Container(
              width: 20,
              height: 7,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Positioned(
            left: 86,
            top: 83,
            child: Transform.rotate(
              angle: -.18,
              child: Container(
                width: 22,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D4ED8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.phone_android_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
          Positioned(
            right: 48,
            top: 44,
            child: Container(
              width: 82,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC7D2FE)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: .08),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 44,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 52,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 86,
            bottom: 10,
            child: Container(
              width: 92,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 42,
                  height: 5,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .22),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 28,
            bottom: 11,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                Container(
                  width: 34,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 42,
            bottom: 42,
            child: Transform.rotate(
              angle: .7,
              child: Container(
                width: 30,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            left: 56,
            top: 18,
            child: _Spark(color: AppColors.primary),
          ),
          const Positioned(
            right: 46,
            top: 24,
            child: _Spark(color: AppColors.accent),
          ),
          Positioned(
            left: 24,
            bottom: 78,
            child: Icon(
              Icons.link_rounded,
              color: AppColors.primary.withValues(alpha: .28),
              size: 36,
            ),
          ),
          Positioned(
            right: 82,
            top: 20,
            child: Text(
              'JOB',
              style: TextStyle(
                color: AppColors.primary.withValues(alpha: .75),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
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

class _Spark extends StatelessWidget {
  const _Spark({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.auto_awesome_rounded, color: color, size: 22);
  }
}
