import 'dart:convert';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../domain/job_analysis.dart';

class JobAnalysisException implements Exception {
  const JobAnalysisException(this.message);

  final String message;

  @override
  String toString() => message;
}

class JobAnalysisRepository {
  static const _localHistoryKey = 'jobdecode_local_history_v1';
  static const _localSavedIdsKey = 'jobdecode_local_saved_ids_v1';
  static const _genericAnalysisError =
      'We could not finish this analysis right now. Please try again in a moment.';

  bool get isSignedIn =>
      AppConfig.supabaseClientOrNull?.auth.currentUser != null;

  Stream<bool> watchSignedIn() async* {
    if (!await AppConfig.ensureSupabaseReady()) {
      yield false;
      return;
    }

    final client = AppConfig.supabaseClientOrNull;
    if (client == null) {
      yield false;
      return;
    }

    yield client.auth.currentUser != null;
    yield* client.auth.onAuthStateChange.map(
      (state) => state.session?.user != null,
    );
  }

  Future<JobAnalysis> analyzeUrl(String url) async {
    if (!await AppConfig.ensureSupabaseReady()) {
      throw const JobAnalysisException(
        'Job analysis is not available right now. Please try again later.',
      );
    }

    try {
      final response = await AppConfig.supabaseClientOrNull!.functions
          .invoke('analyze-job', body: {'jobUrl': url})
          .timeout(const Duration(seconds: 45));
      final payload = _extractAnalysisPayload(response.data);
      final analysis = JobAnalysis.fromJson({
        ...payload,
        'jobUrl': url,
        'createdAt': DateTime.now().toIso8601String(),
      });
      await _saveLocalAnalysis(analysis);
      return analysis;
    } on FunctionException catch (error) {
      throw JobAnalysisException(_messageFromFunctionException(error));
    } on TimeoutException {
      throw const JobAnalysisException(
        'This job is taking longer than expected. Please try again.',
      );
    } on JobAnalysisException {
      rethrow;
    } catch (_) {
      throw const JobAnalysisException(
        'We could not analyze this job right now. Please try another link.',
      );
    }
  }

  Future<List<JobAnalysis>> fetchHistory({
    String search = '',
    bool savedOnly = false,
  }) async {
    if (!await AppConfig.ensureSupabaseReady() || _currentUserId == null) {
      if (savedOnly) {
        return _filterAnalyses(await _fetchLocalSavedAnalyses(), search);
      }
      return _filterAnalyses(await _fetchLocalAnalyses(), search);
    }

    final remoteAnalyses = savedOnly
        ? await _fetchSavedAnalyses()
        : await _fetchUserAnalyses();
    final analyses = savedOnly
        ? remoteAnalyses
        : _mergeAnalyses(remoteAnalyses, await _fetchLocalAnalyses());

    return _filterAnalyses(analyses, search);
  }

  Future<List<JobAnalysis>> fetchSavedAnalyses({String search = ''}) async {
    if (!await AppConfig.ensureSupabaseReady() || _currentUserId == null) {
      return _filterAnalyses(await _fetchLocalSavedAnalyses(), search);
    }

    return _filterAnalyses(await _fetchSavedAnalyses(), search);
  }

  Future<Set<String>> fetchSavedJobIds() async {
    final localIds = await _fetchLocalSavedIds();

    if (!await AppConfig.ensureSupabaseReady() || _currentUserId == null) {
      return localIds;
    }

    final rows = await _client
        .from('saved_jobs')
        .select('job_analysis_id')
        .eq('user_id', _currentUserId!);

    return {
      ...localIds,
      ...rows.map<String>((row) => row['job_analysis_id'].toString()),
    };
  }

  Future<void> saveJob(String analysisId) async {
    final userId = await _requireUserId();
    await _client.from('saved_jobs').upsert({
      'user_id': userId,
      'job_analysis_id': analysisId,
    }, onConflict: 'user_id,job_analysis_id');
    await _addLocalSavedId(analysisId);
  }

  Future<void> unsaveJob(String analysisId) async {
    final userId = await _requireUserId();
    await _client
        .from('saved_jobs')
        .delete()
        .eq('user_id', userId)
        .eq('job_analysis_id', analysisId);
    await _removeLocalSavedId(analysisId);
  }

  Future<void> deleteAnalysis(String analysisId) async {
    if (!await AppConfig.ensureSupabaseReady()) {
      await _removeLocalAnalysis(analysisId);
      await _removeLocalSavedId(analysisId);
      return;
    }
    final userId = _currentUserId;
    if (userId == null) {
      await _removeLocalAnalysis(analysisId);
      await _removeLocalSavedId(analysisId);
      return;
    }
    await _client
        .from('job_analyses')
        .delete()
        .eq('id', analysisId)
        .eq('user_id', userId);
    await _removeLocalAnalysis(analysisId);
    await _removeLocalSavedId(analysisId);
  }

  SupabaseClient get _client {
    final client = AppConfig.supabaseClientOrNull;
    if (client == null) {
      throw const JobAnalysisException(
        'This action is not available right now. Please try again later.',
      );
    }
    return client;
  }

  String? get _currentUserId =>
      AppConfig.supabaseClientOrNull?.auth.currentUser?.id;

  Future<String> _requireUserId() async {
    await AppConfig.ensureSupabaseReady();
    final userId = _currentUserId;
    if (userId == null) {
      throw const JobAnalysisException('Sign in to save and track jobs.');
    }
    return userId;
  }

  Future<List<JobAnalysis>> _fetchUserAnalyses() async {
    final rows = await _client
        .from('job_analyses')
        .select()
        .eq('user_id', _currentUserId!)
        .order('created_at', ascending: false)
        .limit(100);

    return rows
        .map<JobAnalysis>(
          (row) => JobAnalysis.fromDatabase(Map<String, dynamic>.from(row)),
        )
        .toList();
  }

  Future<List<JobAnalysis>> _fetchSavedAnalyses() async {
    final localAnalyses = await _fetchLocalAnalyses();
    final localById = {
      for (final analysis in localAnalyses) analysis.id: analysis,
    };
    final localSavedIds = await _fetchLocalSavedIds();
    final savedRows = await _client
        .from('saved_jobs')
        .select('job_analysis_id')
        .eq('user_id', _currentUserId!)
        .order('saved_at', ascending: false)
        .limit(100);

    final remoteIds = savedRows
        .map<String>((row) => row['job_analysis_id'].toString())
        .toList();
    final orderedIds = [
      ...remoteIds,
      ...localSavedIds.where((id) => !remoteIds.contains(id)),
    ];

    if (orderedIds.isEmpty) {
      return const [];
    }

    final remoteLookupIds = orderedIds.where(_looksLikeUuid).toList();
    final rows = remoteLookupIds.isEmpty
        ? const []
        : await _client
              .from('job_analyses')
              .select()
              .inFilter('id', remoteLookupIds);

    final byId = {
      ...localById,
      for (final row in rows)
        row['id'].toString(): JobAnalysis.fromDatabase(
          Map<String, dynamic>.from(row),
        ),
    };

    return orderedIds.map((id) => byId[id]).whereType<JobAnalysis>().toList();
  }

  List<JobAnalysis> _filterAnalyses(List<JobAnalysis> analyses, String search) {
    final normalized = search.trim().toLowerCase();
    if (normalized.isEmpty) {
      return analyses;
    }

    return analyses.where((analysis) {
      final searchable = [
        analysis.jobTitle,
        analysis.company,
        analysis.location,
        analysis.applicationDeadline,
        analysis.postedBy,
        analysis.industry,
        analysis.employmentType,
        analysis.jobSummary,
        analysis.simpleEnglishExplanation,
        analysis.simpleLugandaExplanation,
        analysis.requiredExperience,
        analysis.requiredEducation,
        ...analysis.requiredSkills,
        ...analysis.mainTasks,
        ...analysis.suitableCandidates,
      ].join(' ').toLowerCase();
      return searchable.contains(normalized);
    }).toList();
  }

  Map<String, dynamic> _extractAnalysisPayload(dynamic data) {
    if (data is String) {
      final decoded = jsonDecode(data);
      return _extractAnalysisPayload(decoded);
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final analysis = map['analysis'] ?? map['data'];
      if (analysis is Map) {
        return Map<String, dynamic>.from(analysis);
      }
      return map;
    }

    throw const JobAnalysisException('The analysis response was not valid.');
  }

  Future<List<JobAnalysis>> _fetchLocalAnalyses() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getStringList(_localHistoryKey) ?? const [];
    final analyses = encoded
        .map((item) {
          try {
            final decoded = jsonDecode(item);
            if (decoded is Map) {
              return JobAnalysis.fromJson(Map<String, dynamic>.from(decoded));
            }
          } catch (_) {
            return null;
          }
          return null;
        })
        .whereType<JobAnalysis>()
        .toList();

    analyses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return analyses;
  }

  Future<void> _saveLocalAnalysis(JobAnalysis analysis) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await _fetchLocalAnalyses();
    final deduped = [
      analysis,
      ...existing.where(
        (item) => item.id != analysis.id && item.jobUrl != analysis.jobUrl,
      ),
    ].take(50);

    await prefs.setStringList(
      _localHistoryKey,
      deduped.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  Future<void> _removeLocalAnalysis(String analysisId) async {
    final prefs = await SharedPreferences.getInstance();
    final remaining = (await _fetchLocalAnalyses())
        .where((item) => item.id != analysisId)
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    await prefs.setStringList(_localHistoryKey, remaining);
  }

  Future<List<JobAnalysis>> _fetchLocalSavedAnalyses() async {
    final savedIds = await _fetchLocalSavedIds();
    if (savedIds.isEmpty) {
      return const [];
    }

    return (await _fetchLocalAnalyses())
        .where((analysis) => savedIds.contains(analysis.id))
        .toList();
  }

  Future<Set<String>> _fetchLocalSavedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_localSavedIdsKey) ?? const [])
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  Future<void> _addLocalSavedId(String analysisId) async {
    final prefs = await SharedPreferences.getInstance();
    final savedIds = await _fetchLocalSavedIds();
    savedIds.add(analysisId);
    await prefs.setStringList(_localSavedIdsKey, savedIds.toList());
  }

  Future<void> _removeLocalSavedId(String analysisId) async {
    final prefs = await SharedPreferences.getInstance();
    final savedIds = await _fetchLocalSavedIds();
    savedIds.remove(analysisId);
    await prefs.setStringList(_localSavedIdsKey, savedIds.toList());
  }

  bool _looksLikeUuid(String value) {
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(value);
  }

  List<JobAnalysis> _mergeAnalyses(
    List<JobAnalysis> remote,
    List<JobAnalysis> local,
  ) {
    final seen = <String>{};
    final merged = <JobAnalysis>[];

    for (final item in [...remote, ...local]) {
      final key = item.id.isNotEmpty ? item.id : item.jobUrl;
      if (seen.add(key)) {
        merged.add(item);
      }
    }

    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return merged;
  }

  String _messageFromFunctionException(FunctionException error) {
    final details = error.details;

    if (error.status == 404 &&
        details is Map &&
        details['code'] == 'NOT_FOUND') {
      return _genericAnalysisError;
    }

    if (details is Map) {
      final message = details['error'] ?? details['message'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return _userSafeAnalysisMessage(message.toString());
      }
    }

    if (details is String && details.trim().isNotEmpty) {
      return _userSafeAnalysisMessage(details);
    }

    return _userSafeAnalysisMessage(error.reasonPhrase);
  }

  String _userSafeAnalysisMessage(String? message) {
    final cleaned = message?.trim() ?? '';
    if (cleaned.isEmpty) {
      return _genericAnalysisError;
    }

    final normalized = cleaned.toLowerCase();
    final technicalTerms = [
      'api',
      'bad request',
      'configured',
      'edge function',
      'function',
      'gemini',
      'invalid response',
      'json',
      'not deployed',
      'requested function',
      'supabase',
    ];

    if (technicalTerms.any(normalized.contains)) {
      return _genericAnalysisError;
    }

    return cleaned;
  }
}
