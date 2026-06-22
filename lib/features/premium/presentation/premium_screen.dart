import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/app_screen.dart';
import '../../../shared/widgets/jobdecode_scaffold.dart';
import '../../../shared/widgets/ui_kit.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            JobTopBar(title: 'Premium', onBack: () => context.go('/')),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.workspace_premium_rounded,
                    color: AppColors.accent,
                    size: 34,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'JobSummary Premium',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'More translations, deeper insights, and saved jobs across devices.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: .86),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _PremiumFeature(
              icon: Icons.translate_rounded,
              color: AppColors.violet,
              title: 'English and Luganda explanations',
              text: 'Choose the language before reading the job breakdown.',
            ),
            const SizedBox(height: 12),
            const _PremiumFeature(
              icon: Icons.bookmark_rounded,
              color: AppColors.primary,
              title: 'Saved jobs everywhere',
              text: 'Open your saved jobs and history after signing in.',
            ),
            const SizedBox(height: 12),
            const _PremiumFeature(
              icon: Icons.auto_graph_rounded,
              color: AppColors.secondary,
              title: 'Better job-fit guidance',
              text:
                  'Understand skills, requirements, salary clues, and fit faster.',
            ),
            const SizedBox(height: 22),
            PrimaryAction(
              label: 'Continue',
              icon: Icons.arrow_forward_rounded,
              onPressed: () => context.go('/profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumFeature extends StatelessWidget {
  const _PremiumFeature({
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: icon, color: color, size: 44),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
