class JobAnalysis {
  const JobAnalysis({
    required this.id,
    required this.jobUrl,
    required this.jobTitle,
    required this.company,
    required this.location,
    required this.datePosted,
    required this.industry,
    required this.employmentType,
    required this.requiredSkills,
    required this.requiredEducation,
    required this.requiredExperience,
    required this.otherRequirements,
    required this.jobSummary,
    required this.simpleEnglishExplanation,
    required this.simpleLugandaExplanation,
    required this.mainTasks,
    required this.suitableCandidates,
    required this.difficultyLevel,
    required this.salaryEstimate,
    required this.responsibilities,
    required this.qualifications,
    required this.benefits,
    required this.confidenceScore,
    required this.createdAt,
  });

  final String id;
  final String jobUrl;
  final String jobTitle;
  final String company;
  final String location;
  final String datePosted;
  final String industry;
  final String employmentType;
  final List<String> requiredSkills;
  final String requiredEducation;
  final String requiredExperience;
  final List<String> otherRequirements;
  final String jobSummary;
  final String simpleEnglishExplanation;
  final String simpleLugandaExplanation;
  final List<String> mainTasks;
  final List<String> suitableCandidates;
  final String difficultyLevel;
  final String salaryEstimate;
  final List<String> responsibilities;
  final List<String> qualifications;
  final List<String> benefits;
  final int confidenceScore;
  final DateTime createdAt;

  factory JobAnalysis.fromJson(Map<String, dynamic> json) {
    return JobAnalysis(
      id: _readString(json, ['id'], fallback: DateTime.now().toString()),
      jobUrl: _readString(json, ['jobUrl', 'job_url']),
      jobTitle: _readString(json, ['jobTitle', 'job_title']),
      company: _readString(json, ['company']),
      location: _readString(json, ['location']),
      datePosted: _readString(json, ['datePosted', 'date_posted']),
      industry: _readString(json, ['industry']),
      employmentType: _readString(json, ['employmentType', 'employment_type']),
      requiredSkills: _readList(
        json['requiredSkills'] ?? json['required_skills'],
      ),
      requiredEducation: _readString(json, [
        'requiredEducation',
        'required_education',
      ]),
      requiredExperience: _readString(json, [
        'requiredExperience',
        'required_experience',
      ]),
      otherRequirements: _readList(
        json['otherRequirements'] ?? json['other_requirements'],
      ),
      jobSummary: _readString(json, ['jobSummary', 'job_summary', 'summary']),
      simpleEnglishExplanation: _readString(json, [
        'simpleEnglishExplanation',
        'simple_english',
      ]),
      simpleLugandaExplanation: _readString(json, [
        'simpleLugandaExplanation',
        'simple_luganda',
      ]),
      mainTasks: _readList(json['mainTasks'] ?? json['main_tasks']),
      suitableCandidates: _readList(
        json['suitableCandidates'] ?? json['suitable_candidates'],
      ),
      difficultyLevel: _readString(json, [
        'difficultyLevel',
        'difficulty_level',
      ]),
      salaryEstimate: _readString(json, ['salaryEstimate', 'salary_estimate']),
      responsibilities: _readList(json['responsibilities']),
      qualifications: _readList(json['qualifications']),
      benefits: _readList(json['benefits']),
      confidenceScore: _readInt(
        json['confidenceScore'] ?? json['confidence_score'],
      ),
      createdAt: _readDate(json['createdAt'] ?? json['created_at']),
    );
  }

  factory JobAnalysis.fromDatabase(Map<String, dynamic> row) {
    final analysisJson = row['analysis_json'];
    final analysis = analysisJson is Map
        ? Map<String, dynamic>.from(analysisJson)
        : <String, dynamic>{};

    return JobAnalysis.fromJson({
      ...analysis,
      'id': row['id'],
      'job_url': row['job_url'],
      'job_title': row['job_title'],
      'company': row['company'],
      'location': row['location'],
      'industry': row['industry'],
      'employment_type': row['employment_type'],
      'required_experience': row['required_experience'],
      'required_education': row['required_education'],
      'summary': row['summary'],
      'simple_english': row['simple_english'],
      'simple_luganda': row['simple_luganda'],
      'created_at': row['created_at'],
    });
  }

  JobAnalysis copyWith({
    String? id,
    String? jobUrl,
    String? jobTitle,
    String? company,
    String? location,
    String? datePosted,
    String? industry,
    String? employmentType,
    List<String>? requiredSkills,
    String? requiredEducation,
    String? requiredExperience,
    List<String>? otherRequirements,
    String? jobSummary,
    String? simpleEnglishExplanation,
    String? simpleLugandaExplanation,
    List<String>? mainTasks,
    List<String>? suitableCandidates,
    String? difficultyLevel,
    String? salaryEstimate,
    List<String>? responsibilities,
    List<String>? qualifications,
    List<String>? benefits,
    int? confidenceScore,
    DateTime? createdAt,
  }) {
    return JobAnalysis(
      id: id ?? this.id,
      jobUrl: jobUrl ?? this.jobUrl,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      location: location ?? this.location,
      datePosted: datePosted ?? this.datePosted,
      industry: industry ?? this.industry,
      employmentType: employmentType ?? this.employmentType,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      requiredEducation: requiredEducation ?? this.requiredEducation,
      requiredExperience: requiredExperience ?? this.requiredExperience,
      otherRequirements: otherRequirements ?? this.otherRequirements,
      jobSummary: jobSummary ?? this.jobSummary,
      simpleEnglishExplanation:
          simpleEnglishExplanation ?? this.simpleEnglishExplanation,
      simpleLugandaExplanation:
          simpleLugandaExplanation ?? this.simpleLugandaExplanation,
      mainTasks: mainTasks ?? this.mainTasks,
      suitableCandidates: suitableCandidates ?? this.suitableCandidates,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      salaryEstimate: salaryEstimate ?? this.salaryEstimate,
      responsibilities: responsibilities ?? this.responsibilities,
      qualifications: qualifications ?? this.qualifications,
      benefits: benefits ?? this.benefits,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toDatabaseInsert({String? userId}) {
    return {
      'user_id': userId,
      'job_url': jobUrl,
      'job_title': jobTitle,
      'company': company,
      'location': location,
      'industry': industry,
      'employment_type': employmentType,
      'required_experience': requiredExperience,
      'required_education': requiredEducation,
      'summary': jobSummary,
      'simple_english': simpleEnglishExplanation,
      'simple_luganda': simpleLugandaExplanation,
      'analysis_json': {
        'jobTitle': jobTitle,
        'company': company,
        'location': location,
        'datePosted': datePosted,
        'industry': industry,
        'employmentType': employmentType,
        'requiredSkills': requiredSkills,
        'requiredEducation': requiredEducation,
        'requiredExperience': requiredExperience,
        'otherRequirements': otherRequirements,
        'jobSummary': jobSummary,
        'simpleEnglishExplanation': simpleEnglishExplanation,
        'simpleLugandaExplanation': simpleLugandaExplanation,
        'mainTasks': mainTasks,
        'suitableCandidates': suitableCandidates,
        'difficultyLevel': difficultyLevel,
        'salaryEstimate': salaryEstimate,
        'responsibilities': responsibilities,
        'qualifications': qualifications,
        'benefits': benefits,
        'confidenceScore': confidenceScore,
      },
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobUrl': jobUrl,
      'jobTitle': jobTitle,
      'company': company,
      'location': location,
      'datePosted': datePosted,
      'industry': industry,
      'employmentType': employmentType,
      'requiredSkills': requiredSkills,
      'requiredEducation': requiredEducation,
      'requiredExperience': requiredExperience,
      'otherRequirements': otherRequirements,
      'jobSummary': jobSummary,
      'simpleEnglishExplanation': simpleEnglishExplanation,
      'simpleLugandaExplanation': simpleLugandaExplanation,
      'mainTasks': mainTasks,
      'suitableCandidates': suitableCandidates,
      'difficultyLevel': difficultyLevel,
      'salaryEstimate': salaryEstimate,
      'responsibilities': responsibilities,
      'qualifications': qualifications,
      'benefits': benefits,
      'confidenceScore': confidenceScore,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static String _readString(
    Map<String, dynamic> json,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return fallback;
  }

  static List<String> _readList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return [value.trim()];
    }
    return const [];
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _readDate(dynamic value) {
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  }
}
