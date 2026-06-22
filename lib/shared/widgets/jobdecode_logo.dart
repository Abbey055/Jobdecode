import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class JobDecodeLogo extends StatelessWidget {
  const JobDecodeLogo({
    super.key,
    this.compact = false,
    this.showTagline = false,
  });

  final bool compact;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final brand = RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w900,
          fontSize: compact ? 20 : 24,
          height: 1,
        ),
        children: [
          TextSpan(
            text: 'Job',
            style: TextStyle(color: textColor),
          ),
          const TextSpan(
            text: 'Summary',
            style: TextStyle(color: AppColors.primary),
          ),
        ],
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LogoMark(size: compact ? 40 : 44),
        SizedBox(width: compact ? 9 : 10),
        if (showTagline)
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              brand,
              const SizedBox(height: 3),
              Text(
                'Understand any job in seconds',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.ink,
                  fontSize: 8.5,
                  height: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
        else
          brand,
      ],
    );
  }
}

class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: .22),
                    blurRadius: 16,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: size * .22,
            top: size * .18,
            child: Icon(
              Icons.description_rounded,
              color: Colors.white,
              size: size * .42,
            ),
          ),
          Positioned(
            right: -size * .08,
            bottom: -size * .05,
            child: Container(
              width: size * .52,
              height: size * .52,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 3),
              ),
              child: Icon(
                Icons.work_rounded,
                color: AppColors.secondary,
                size: size * .24,
              ),
            ),
          ),
          Positioned(
            left: -size * .12,
            bottom: size * .02,
            child: Transform.rotate(
              angle: -.62,
              child: Icon(
                Icons.link_rounded,
                color: Colors.white,
                size: size * .34,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
