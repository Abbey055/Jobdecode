import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(backgroundColor: _SplashColors.base, body: _SplashBody()),
    );
  }
}

class _SplashBody extends StatelessWidget {
  const _SplashBody();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final height = size.height;
    final contentWidth = size.width.clamp(0, 430).toDouble();
    final horizontalPadding = contentWidth < 360 ? 28.0 : 34.0;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_SplashColors.top, _SplashColors.base, _SplashColors.bottom],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                24,
                horizontalPadding,
                24,
              ),
              child: Column(
                children: [
                  const Spacer(flex: 42),
                  const SplashLogoMark(size: 96),
                  SizedBox(height: height < 700 ? 28 : 34),
                  Text(
                    'Hi there',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontSize: contentWidth < 340 ? 28 : 31,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      letterSpacing: 0,
                      shadows: [
                        Shadow(
                          color: AppColors.primaryDark.withValues(alpha: .14),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 30),
                  const _SplashMiniMark(),
                  SizedBox(height: height < 700 ? 34 : 44),
                  _SplashAction(onPressed: () => context.go('/')),
                  SizedBox(height: height < 700 ? 12 : 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SplashLogoMark extends StatelessWidget {
  const SplashLogoMark({super.key, this.size = 88});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * .78,
      child: CustomPaint(painter: _SplashLogoPainter()),
    );
  }
}

class _SplashMiniMark extends StatelessWidget {
  const _SplashMiniMark();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: .48,
      child: SizedBox(
        width: 48,
        height: 36,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: -.72,
              child: Container(
                width: 36,
                height: 10,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                    strokeAlign: BorderSide.strokeAlignCenter,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Transform.rotate(
              angle: .72,
              child: Container(
                width: 36,
                height: 10,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                    strokeAlign: BorderSide.strokeAlignCenter,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Container(
              width: 17,
              height: 17,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashAction extends StatelessWidget {
  const _SplashAction({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5940B8).withValues(alpha: .38),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color(0xFFF6F4FF),
            foregroundColor: AppColors.primaryDark,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          child: const Text("Let's go"),
        ),
      ),
    );
  }
}

class _SplashLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final eyeWidth = size.width * .13;
    final eyeHeight = size.height * .48;
    final eyeRadius = Radius.circular(eyeWidth * .48);
    final top = size.height * .08;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * .34, top, eyeWidth, eyeHeight),
        eyeRadius,
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * .54, top, eyeWidth, eyeHeight),
        eyeRadius,
      ),
      paint,
    );

    final smilePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * .12
      ..strokeCap = StrokeCap.round;
    final smile = Path()
      ..moveTo(size.width * .2, size.height * .72)
      ..cubicTo(
        size.width * .34,
        size.height * .94,
        size.width * .66,
        size.height * .94,
        size.width * .8,
        size.height * .72,
      );
    canvas.drawPath(smile, smilePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SplashColors {
  const _SplashColors._();

  static const top = Color(0xFFA69CEB);
  static const base = Color(0xFF9B8CE7);
  static const bottom = Color(0xFF8E6DF1);
}
