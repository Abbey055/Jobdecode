import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/job_analysis_repository.dart';
import '../../domain/job_analysis.dart';

final jobAnalysisRepositoryProvider = Provider<JobAnalysisRepository>((ref) {
  return JobAnalysisRepository();
});

final currentAnalysisProvider =
    NotifierProvider<CurrentAnalysisNotifier, JobAnalysis?>(
      CurrentAnalysisNotifier.new,
    );

typedef AnalysisListQuery = ({String search, String filter});

final historyProvider = FutureProvider.autoDispose
    .family<List<JobAnalysis>, AnalysisListQuery>((ref, query) async {
      final repository = ref.watch(jobAnalysisRepositoryProvider);
      return repository.fetchHistory(
        search: query.search,
        savedOnly: query.filter == 'Saved',
      );
    });

final savedAnalysesProvider = FutureProvider.autoDispose
    .family<List<JobAnalysis>, String>((ref, search) async {
      final repository = ref.watch(jobAnalysisRepositoryProvider);
      return repository.fetchSavedAnalyses(search: search);
    });

final savedJobIdsProvider = FutureProvider.autoDispose<Set<String>>((ref) {
  final repository = ref.watch(jobAnalysisRepositoryProvider);
  return repository.fetchSavedJobIds();
});

final isSignedInProvider = StreamProvider<bool>((ref) {
  final repository = ref.watch(jobAnalysisRepositoryProvider);
  return repository.watchSignedIn();
});

class CurrentAnalysisNotifier extends Notifier<JobAnalysis?> {
  @override
  JobAnalysis? build() {
    return null;
  }

  void setAnalysis(JobAnalysis analysis) {
    state = analysis;
  }
}
