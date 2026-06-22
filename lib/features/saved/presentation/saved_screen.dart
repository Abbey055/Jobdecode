import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../features/analysis/presentation/providers/analysis_providers.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/app_screen.dart';
import '../../../shared/widgets/jobdecode_scaffold.dart';
import '../../../shared/widgets/ui_kit.dart';

class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final savedJobsAsync = ref.watch(savedAnalysesProvider(_query));
    final isSignedIn = ref.watch(isSignedInProvider);

    return AppScreen(
      currentIndex: 2,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Saved',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 22),
            if (!isSignedIn) ...[
              const SignInRequiredCard(
                title: 'Sign in to view saved jobs',
                subtitle:
                    'Saved jobs are kept in your account so you can open them on any device.',
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              enabled: isSignedIn,
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'Search saved jobs...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 16),
            if (!isSignedIn)
              const SizedBox.shrink()
            else
              savedJobsAsync.when(
                loading: () => const LoadingJobList(),
                error: (error, stackTrace) => const EmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'Saved jobs unavailable',
                  subtitle:
                      'We could not load your saved jobs. Please try again.',
                ),
                data: (savedJobs) {
                  if (savedJobs.isEmpty) {
                    return EmptyState(
                      icon: Icons.bookmark_border_rounded,
                      title: _emptyTitle(isSignedIn),
                      subtitle: _emptySubtitle(isSignedIn),
                    );
                  }

                  return Column(
                    children: savedJobs
                        .map(
                          (job) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: JDCard(
                              onTap: () {
                                ref
                                    .read(currentAnalysisProvider.notifier)
                                    .setAnalysis(job);
                                context.go('/summary');
                              },
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const IconBadge(
                                    icon: Icons.bookmark_rounded,
                                    color: AppColors.primary,
                                    size: 52,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _displayText(
                                            job.jobTitle,
                                            fallback: 'Untitled job',
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(fontSize: 12.5),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _displayText(
                                            job.company,
                                            fallback: 'Unknown company',
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: AppColors.muted,
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  IconButton(
                                    tooltip: 'Remove saved job',
                                    onPressed: () =>
                                        _removeSaved(context, job.id),
                                    iconSize: 22,
                                    visualDensity: VisualDensity.compact,
                                    constraints: const BoxConstraints.tightFor(
                                      width: 34,
                                      height: 34,
                                    ),
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _emptyTitle(bool isSignedIn) {
    if (!AppConfig.hasSupabaseConfig) {
      return 'Saved jobs unavailable';
    }
    if (!isSignedIn) {
      return 'Sign in to view saved jobs';
    }
    return _query.isEmpty ? 'No saved jobs yet' : 'No saved jobs found';
  }

  String _emptySubtitle(bool isSignedIn) {
    if (!AppConfig.hasSupabaseConfig) {
      return 'Please try again later.';
    }
    if (!isSignedIn) {
      return 'Saved jobs will appear here after you sign in.';
    }
    return _query.isEmpty
        ? 'Save a job analysis and it will appear here.'
        : 'Try another keyword.';
  }

  Future<void> _removeSaved(BuildContext context, String id) async {
    try {
      await ref.read(jobAnalysisRepositoryProvider).unsaveJob(id);
      ref.invalidate(savedJobIdsProvider);
      ref.invalidate(savedAnalysesProvider);
      ref.invalidate(historyProvider);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('We could not remove this job.')),
      );
    }
  }

  String _displayText(String value, {required String fallback}) {
    final text = value.trim();
    return text.isEmpty ? fallback : text;
  }
}
