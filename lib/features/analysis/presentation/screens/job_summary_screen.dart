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
    final isSignedInAsync = ref.watch(isSignedInProvider);
    final isSignedIn = isSignedInAsync.value ?? false;
    final isAuthLoading =
        isSignedInAsync.isLoading && !isSignedInAsync.hasValue;

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
                onPressed: savedIdsAsync.isLoading || isAuthLoading
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
              padding: const EdgeInsets.all(16),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.work_rounded,
                      color: Color(0xFFFDE68A),
                      size: 38,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayValue(
                            analysis.jobTitle,
                            fallback: 'Untitled job',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _displayValue(
                            analysis.company,
                            fallback: 'Unknown company',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 16),
                        _HeaderMeta(
                          icon: Icons.location_on_outlined,
                          color: const Color(0xFFA7F3D0),
                          text: _displayValue(analysis.location),
                        ),
                        const SizedBox(height: 9),
                        _HeaderMeta(
                          icon: Icons.calendar_today_outlined,
                          color: const Color(0xFFFDE68A),
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
                    iconColor: AppColors.primary,
                    label: 'Experience',
                    value: analysis.requiredExperience.replaceAll(
                      ' of experience in data analysis or a related role.',
                      '',
                    ),
                  ),
                  const Divider(height: 1),
                  InfoRow(
                    icon: Icons.school_outlined,
                    iconColor: AppColors.violet,
                    label: 'Education',
                    value: analysis.requiredEducation,
                  ),
                  const Divider(height: 1),
                  InfoRow(
                    icon: Icons.badge_outlined,
                    iconColor: AppColors.accent,
                    label: 'Job Type',
                    value: analysis.employmentType,
                  ),
                  const Divider(height: 1),
                  InfoRow(
                    icon: Icons.apartment_outlined,
                    iconColor: AppColors.secondary,
                    label: 'Industry',
                    value: analysis.industry,
                  ),
                  const Divider(height: 1),
                  InfoRow(
                    icon: Icons.event_available_outlined,
                    iconColor: const Color(0xFFDC2626),
                    label: 'Deadline',
                    value: analysis.applicationDeadline,
                  ),
                  const Divider(height: 1),
                  InfoRow(
                    icon: Icons.campaign_outlined,
                    iconColor: const Color(0xFF0891B2),
                    label: 'Hiring Entity',
                    value: analysis.postedBy,
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

  String _displayValue(String value, {String fallback = 'Not listed'}) {
    final text = value.trim();
    return text.isEmpty ? fallback : text;
  }
}

class _HeaderMeta extends StatelessWidget {
  const _HeaderMeta({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
