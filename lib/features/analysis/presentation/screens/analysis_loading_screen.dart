import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/app_screen.dart';
import '../../../../shared/widgets/illustrations.dart';
import '../../../../shared/widgets/ui_kit.dart';
import '../providers/analysis_providers.dart';

class AnalysisLoadingScreen extends ConsumerStatefulWidget {
  const AnalysisLoadingScreen({super.key, required this.jobUrl});

  final String jobUrl;

  @override
  ConsumerState<AnalysisLoadingScreen> createState() =>
      _AnalysisLoadingScreenState();
}

class _AnalysisLoadingScreenState extends ConsumerState<AnalysisLoadingScreen> {
  static const _steps = [
    'Reading the webpage',
    'Extracting job description',
    'Understanding requirements',
    'Generating summary',
  ];

  Timer? _stepTimer;
  int _completedStep = 0;
  String? _error;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAnalysis());
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    super.dispose();
  }

  Future<void> _startAnalysis() async {
    if (_started) {
      return;
    }
    _started = true;
    setState(() {
      _error = null;
      _completedStep = 0;
    });

    _stepTimer?.cancel();
    _stepTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted) {
        return;
      }
      if (_completedStep < _steps.length - 1) {
        setState(() => _completedStep += 1);
      }
    });

    try {
      final repository = ref.read(jobAnalysisRepositoryProvider);
      final analysis = await repository.analyzeUrl(widget.jobUrl);

      if (!mounted) {
        return;
      }

      _stepTimer?.cancel();
      setState(() => _completedStep = _steps.length);
      ref.read(currentAnalysisProvider.notifier).setAnalysis(analysis);
      ref.invalidate(historyProvider);

      await Future<void>.delayed(const Duration(milliseconds: 650));
      if (!mounted) {
        return;
      }

      if (mounted) {
        context.go('/summary');
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      _stepTimer?.cancel();
      setState(() {
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 2, 18, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              tooltip: 'Back',
              onPressed: () => context.go('/'),
              iconSize: 18,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 34, height: 34),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(height: 14),
            const RocketIllustration(),
            const SizedBox(height: 16),
            Center(
              child: Text(
                _error == null ? 'Analyzing Job...' : 'Analysis stopped',
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontSize: 22, height: 1.1),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                _error == null
                    ? 'This can take up to 45 seconds'
                    : 'Try again or use a different job link.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                  fontSize: 13,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 35),
            ...List.generate(_steps.length, (index) {
              return _ProgressStep(
                label: _steps[index],
                completed: index < _completedStep,
                active: index == _completedStep && _error == null,
              );
            }),
            const SizedBox(height: 30),
            if (_error == null)
              const _TipPanel()
            else
              JDCard(
                padding: const EdgeInsets.all(14),
                borderColor: Colors.red.withValues(alpha: .2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _error ??
                          'We could not analyze this job. Please try another link.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 11.5),
                    ),
                    const SizedBox(height: 14),
                    PrimaryAction(
                      label: 'Try Again',
                      height: 48,
                      onPressed: () {
                        _started = false;
                        _startAnalysis();
                      },
                      icon: Icons.refresh_rounded,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProgressStep extends StatelessWidget {
  const _ProgressStep({
    required this.label,
    required this.completed,
    required this.active,
  });

  final String label;
  final bool completed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11.5),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: completed ? AppColors.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: completed || active
                    ? AppColors.primary
                    : AppColors.muted,
                width: 1.7,
              ),
            ),
            child: completed
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 15)
                : active
                ? const Padding(
                    padding: EdgeInsets.all(4),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 13.5,
                color: AppColors.ink,
                height: 1.1,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipPanel extends StatelessWidget {
  const _TipPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
      decoration: BoxDecoration(
        color: AppColors.soft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: AppColors.accent,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Some job pages take longer to read and summarize.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                    fontSize: 12.5,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
