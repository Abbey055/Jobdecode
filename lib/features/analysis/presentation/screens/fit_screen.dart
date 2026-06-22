import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/app_screen.dart';
import '../../../../shared/widgets/jobdecode_scaffold.dart';
import '../../../../shared/widgets/ui_kit.dart';
import '../providers/analysis_providers.dart';

class FitScreen extends ConsumerWidget {
  const FitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = ref.watch(currentAnalysisProvider);
    if (analysis == null) {
      return AppScreen(
        child: NoAnalysisSelected(onGoHome: () => context.go('/')),
      );
    }

    return AppScreen(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            JobTopBar(
              title: 'Who Should Apply?',
              onBack: () => context.go('/description'),
            ),
            const SizedBox(height: 18),
            JDCard(
              backgroundColor: const Color(0xFFF0FDFA),
              borderColor: const Color(0xFF99F6E4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const JobSectionHeader(
                    icon: Icons.group_rounded,
                    color: AppColors.secondary,
                    title: 'Good Fit For',
                  ),
                  const SizedBox(height: 10),
                  ...analysis.suitableCandidates.map(
                    (item) => CheckLine(text: item),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            JDCard(
              backgroundColor: const Color(0xFFF8FAFF),
              borderColor: const Color(0xFFC7D2FE),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const JobSectionHeader(
                    icon: Icons.bar_chart_rounded,
                    color: AppColors.primary,
                    title: 'Difficulty Level',
                  ),
                  const SizedBox(height: 14),
                  Text(
                    analysis.difficultyLevel,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This role requires some experience and strong analytical skills.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 14),
                  _Stars(level: analysis.difficultyLevel),
                ],
              ),
            ),
            const SizedBox(height: 14),
            JDCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const JobSectionHeader(
                    icon: Icons.monetization_on_rounded,
                    color: AppColors.secondary,
                    title: 'Salary Range (Est.)',
                  ),
                  const SizedBox(height: 14),
                  Text(
                    analysis.salaryEstimate.isEmpty
                        ? 'Salary not listed'
                        : analysis.salaryEstimate,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Estimate based on similar roles',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            PrimaryAction(
              label: 'Full Job Description',
              icon: Icons.arrow_forward_rounded,
              onPressed: () => context.go('/full-description'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.level});

  final String level;

  @override
  Widget build(BuildContext context) {
    final filled = switch (level.toLowerCase()) {
      'beginner' => 2,
      'advanced' => 5,
      _ => 4,
    };

    return Row(
      children: List.generate(5, (index) {
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Icon(
            index < filled ? Icons.star_rounded : Icons.star_border_rounded,
            color: AppColors.accent,
            size: 30,
          ),
        );
      }),
    );
  }
}
