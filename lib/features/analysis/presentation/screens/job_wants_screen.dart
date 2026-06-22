import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/app_screen.dart';
import '../../../../shared/widgets/jobdecode_scaffold.dart';
import '../../../../shared/widgets/ui_kit.dart';
import '../providers/analysis_providers.dart';

class JobWantsScreen extends ConsumerWidget {
  const JobWantsScreen({super.key});

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
              title: 'What the Job Wants',
              onBack: () => context.go('/summary'),
            ),
            const SizedBox(height: 18),
            JDCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  JobSectionHeader(
                    icon: Icons.work_history_rounded,
                    color: AppColors.secondary,
                    title: 'Key Skills',
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: analysis.requiredSkills.map((skill) {
                      return Chip(
                        avatar: const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.secondary,
                          size: 18,
                        ),
                        label: Text(skill),
                        backgroundColor: AppColors.soft,
                        side: const BorderSide(color: AppColors.border),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {},
                    label: Text(
                      'View all skills (${analysis.requiredSkills.length})',
                    ),
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _RequirementCard(
              icon: Icons.workspace_premium_rounded,
              color: AppColors.violet,
              title: 'Experience Requirement',
              text: analysis.requiredExperience,
            ),
            const SizedBox(height: 14),
            _RequirementCard(
              icon: Icons.school_rounded,
              color: AppColors.secondary,
              title: 'Education Requirement',
              text: analysis.requiredEducation,
            ),
            const SizedBox(height: 14),
            JDCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const JobSectionHeader(
                    icon: Icons.assignment_rounded,
                    color: AppColors.accent,
                    title: 'Other Requirements',
                  ),
                  const SizedBox(height: 8),
                  ...analysis.otherRequirements.map(
                    (item) => BulletLine(text: item),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            PrimaryAction(
              label: 'Job Description',
              icon: Icons.arrow_forward_rounded,
              onPressed: () => context.go('/description'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequirementCard extends StatelessWidget {
  const _RequirementCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return JDCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          JobSectionHeader(icon: icon, color: color, title: title),
          const SizedBox(height: 10),
          Text(text.isEmpty ? 'Not listed' : text),
        ],
      ),
    );
  }
}
