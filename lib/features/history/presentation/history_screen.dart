import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../features/analysis/domain/job_analysis.dart';
import '../../../features/analysis/presentation/providers/analysis_providers.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/app_screen.dart';
import '../../../shared/widgets/jobdecode_scaffold.dart';
import '../../../shared/widgets/ui_kit.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _query = '';
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(
      historyProvider((search: _query, filter: _filter)),
    );
    final savedIdsAsync = ref.watch(savedJobIdsProvider);
    final savedIds = savedIdsAsync.value ?? const <String>{};
    final isSignedIn = ref.watch(isSignedInProvider);

    return AppScreen(
      currentIndex: 1,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'History',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 22),
            TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'Search your history...',
                prefixIcon: Icon(Icons.search_rounded),
                suffixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: ['All', 'Saved', 'Analyzed'].indexed.map((entry) {
                final index = entry.$1;
                final label = entry.$2;
                final selected = _filter == label;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: index == 2 ? 0 : 8),
                    child: ChoiceChip(
                      selected: selected,
                      label: Center(child: Text(label)),
                      onSelected: (_) => setState(() => _filter = label),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : AppColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            historyAsync.when(
              loading: () => const LoadingJobList(),
              error: (error, stackTrace) => const EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'History unavailable',
                subtitle: 'We could not load your jobs. Please try again.',
              ),
              data: (history) {
                if (history.isEmpty) {
                  if (!isSignedIn) {
                    return const SignInRequiredCard(
                      title: 'Sign in to view history',
                      subtitle:
                          'Analyze jobs, save them, and open your history across devices.',
                    );
                  }
                  return EmptyState(
                    icon: Icons.history_rounded,
                    title: _emptyTitle(isSignedIn),
                    subtitle: _emptySubtitle(isSignedIn),
                  );
                }

                return Column(
                  children: history
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _HistoryCard(
                            analysis: item,
                            isSaved: savedIds.contains(item.id),
                            onOpen: () {
                              ref
                                  .read(currentAnalysisProvider.notifier)
                                  .setAnalysis(item);
                              context.go('/summary');
                            },
                            onSave: () => _toggleSaved(
                              context,
                              item.id,
                              savedIds.contains(item.id),
                            ),
                            onDelete: () => _deleteAnalysis(context, item.id),
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
      return 'History unavailable';
    }
    if (!isSignedIn) {
      return 'Sign in to view history';
    }
    return _query.isEmpty ? 'No analyses yet' : 'No jobs found';
  }

  String _emptySubtitle(bool isSignedIn) {
    if (!AppConfig.hasSupabaseConfig) {
      return 'Please try again later.';
    }
    if (!isSignedIn) {
      return 'Your analyzed and saved jobs will appear here.';
    }
    return _query.isEmpty
        ? 'Analyze a job link and it will appear here.'
        : 'Try another keyword or filter.';
  }

  Future<void> _toggleSaved(
    BuildContext context,
    String id,
    bool isSaved,
  ) async {
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

  Future<void> _deleteAnalysis(BuildContext context, String id) async {
    try {
      await ref.read(jobAnalysisRepositoryProvider).deleteAnalysis(id);
      ref.invalidate(historyProvider);
      ref.invalidate(savedJobIdsProvider);
      ref.invalidate(savedAnalysesProvider);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('We could not delete this job.')),
      );
    }
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.analysis,
    required this.isSaved,
    required this.onOpen,
    required this.onSave,
    required this.onDelete,
  });

  final JobAnalysis analysis;
  final bool isSaved;
  final VoidCallback onOpen;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.secondary,
      AppColors.primary,
      AppColors.accent,
      AppColors.violet,
    ];
    final color = colors[analysis.jobTitle.hashCode.abs() % colors.length];

    return JDCard(
      onTap: onOpen,
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconBadge(icon: Icons.analytics_rounded, color: color, size: 52),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayText(analysis.jobTitle, fallback: 'Untitled job'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: 12.5),
                ),
                const SizedBox(height: 4),
                Text(
                  _displayText(analysis.company, fallback: 'Unknown company'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      color: AppColors.secondary,
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _listDateLabel(analysis),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.muted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 72,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: isSaved ? 'Saved' : 'Save',
                  onPressed: onSave,
                  color: AppColors.primary,
                  iconSize: 22,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints.tightFor(
                    width: 34,
                    height: 34,
                  ),
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'More',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 34,
                    height: 34,
                  ),
                  icon: const Icon(Icons.more_vert_rounded, size: 22),
                  onSelected: (value) {
                    if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _listDateLabel(JobAnalysis analysis) {
    final raw = analysis.datePosted.trim();
    if (raw.isEmpty || raw.length > 26 || raw.contains('\n')) {
      return compactDate(analysis.createdAt);
    }
    return raw;
  }

  String _displayText(String value, {required String fallback}) {
    final text = value.trim();
    return text.isEmpty ? fallback : text;
  }
}
