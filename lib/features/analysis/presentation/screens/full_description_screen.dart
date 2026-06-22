import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/app_screen.dart';
import '../../../../shared/widgets/jobdecode_scaffold.dart';
import '../../../../shared/widgets/ui_kit.dart';
import '../providers/analysis_providers.dart';

class FullDescriptionScreen extends ConsumerWidget {
  const FullDescriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = ref.watch(currentAnalysisProvider);
    if (analysis == null) {
      return AppScreen(
        child: NoAnalysisSelected(onGoHome: () => context.go('/')),
      );
    }

    final savedIdsAsync = ref.watch(savedJobIdsProvider);
    final savedIds = savedIdsAsync.value ?? const <String>{};
    final isSaved = savedIds.contains(analysis.id);
    final isSignedInAsync = ref.watch(isSignedInProvider);
    final isSignedIn = isSignedInAsync.value ?? false;
    final isAuthLoading =
        isSignedInAsync.isLoading && !isSignedInAsync.hasValue;

    return AppScreen(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            JobTopBar(
              title: 'Full Job Description',
              onBack: () => context.go('/fit'),
              trailing: IconButton(
                tooltip: 'Share',
                onPressed: () {
                  SharePlus.instance.share(
                    ShareParams(
                      text:
                          '${analysis.jobTitle} at ${analysis.company}\n${analysis.jobUrl}',
                    ),
                  );
                },
                icon: const Icon(Icons.ios_share_rounded),
              ),
            ),
            const SizedBox(height: 18),
            JDCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const JobSectionHeader(
                    icon: Icons.info_outline_rounded,
                    color: AppColors.primary,
                    title: 'About the Role',
                  ),
                  const SizedBox(height: 10),
                  Text(analysis.jobSummary),
                  const SizedBox(height: 18),
                  const Divider(),
                  const SizedBox(height: 10),
                  const JobSectionHeader(
                    icon: Icons.checklist_rounded,
                    color: AppColors.primary,
                    title: 'Responsibilities',
                  ),
                  const SizedBox(height: 8),
                  ...analysis.responsibilities.map(
                    (item) => BulletLine(text: item),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 10),
                  const JobSectionHeader(
                    icon: Icons.verified_rounded,
                    color: AppColors.primary,
                    title: 'What You Need',
                  ),
                  const SizedBox(height: 8),
                  ...analysis.qualifications.map(
                    (item) => BulletLine(text: item),
                  ),
                  if (analysis.benefits.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 10),
                    const JobSectionHeader(
                      icon: Icons.card_giftcard_rounded,
                      color: AppColors.secondary,
                      title: 'Benefits',
                    ),
                    const SizedBox(height: 8),
                    ...analysis.benefits.map((item) => BulletLine(text: item)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: savedIdsAsync.isLoading || isAuthLoading
                  ? null
                  : () => _toggleSaved(
                      context,
                      ref,
                      analysis.id,
                      isSaved,
                      isSignedIn,
                    ),
              icon: Icon(
                isSaved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
              ),
              label: Text(isSaved ? 'Saved' : 'Save Job'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleSaved(
    BuildContext context,
    WidgetRef ref,
    String id,
    bool isSaved,
    bool isSignedIn,
  ) async {
    if (!isSignedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sign in to save jobs.'),
          action: SnackBarAction(
            label: 'Sign In',
            onPressed: () => context.go('/profile'),
          ),
        ),
      );
      return;
    }

    try {
      final repository = ref.read(jobAnalysisRepositoryProvider);
      if (isSaved) {
        await repository.unsaveJob(id);
      } else {
        await repository.saveJob(id);
      }
      ref.invalidate(savedJobIdsProvider);
      ref.invalidate(savedAnalysesProvider);
      ref.invalidate(historyProvider);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('We could not update this job.')),
      );
    }
  }
}
