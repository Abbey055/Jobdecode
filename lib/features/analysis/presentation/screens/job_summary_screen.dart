import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/app_screen.dart';
import '../../../../shared/widgets/jobdecode_scaffold.dart';
import '../../../../shared/widgets/ui_kit.dart';
import '../providers/analysis_providers.dart';

class JobSummaryScreen extends ConsumerWidget {
  const JobSummaryScreen({super.key});

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
    final isSignedIn = ref.watch(isSignedInProvider);

    return AppScreen(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            JobTopBar(
              title: 'Job Summary',
              onBack: () => context.go('/'),
              trailing: IconButton(
                tooltip: isSaved ? 'Unsave job' : 'Save job',
                onPressed: savedIdsAsync.isLoading
                    ? null
                    : () => _toggleSaved(
                        context,
                        ref,
                        analysis.id,
                        isSaved,
                        isSignedIn,
                      ),
                color: AppColors.primary,
                icon: Icon(
                  isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: .26),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.work_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          analysis.jobTitle,
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          analysis.company,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 16),
                        _HeaderMeta(
                          icon: Icons.location_on_outlined,
                          text: analysis.location,
                        ),
                        const SizedBox(height: 9),
                        _HeaderMeta(
                          icon: Icons.calendar_today_outlined,
                          text: analysis.datePosted.isEmpty
                              ? compactDate(analysis.createdAt)
                              : analysis.datePosted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            JDCard(
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.business_center_outlined,
                    label: 'Experience',
                    value: analysis.requiredExperience.replaceAll(
                      ' of experience in data analysis or a related role.',
                      '',
                    ),
                  ),
                  const Divider(height: 1),
                  InfoRow(
                    icon: Icons.school_outlined,
                    label: 'Education',
                    value: analysis.requiredEducation.contains("Bachelor")
                        ? "Bachelor's Degree"
                        : analysis.requiredEducation,
                  ),
                  const Divider(height: 1),
                  InfoRow(
                    icon: Icons.badge_outlined,
                    label: 'Job Type',
                    value: analysis.employmentType,
                  ),
                  const Divider(height: 1),
                  InfoRow(
                    icon: Icons.apartment_outlined,
                    label: 'Industry',
                    value: analysis.industry,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            JDCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overview',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(analysis.jobSummary),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => context.go('/description'),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    label: const Text('Read more'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            PrimaryAction(
              label: 'See Full Details',
              icon: Icons.arrow_downward_rounded,
              onPressed: () => context.go('/wants'),
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

class _HeaderMeta extends StatelessWidget {
  const _HeaderMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
