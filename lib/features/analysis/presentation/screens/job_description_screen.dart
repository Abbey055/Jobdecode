import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/app_screen.dart';
import '../../../../shared/widgets/illustrations.dart';
import '../../../../shared/widgets/jobdecode_scaffold.dart';
import '../../../../shared/widgets/ui_kit.dart';
import '../providers/analysis_providers.dart';

enum _DescriptionLanguage { english, luganda }

class JobDescriptionScreen extends ConsumerStatefulWidget {
  const JobDescriptionScreen({super.key});

  @override
  ConsumerState<JobDescriptionScreen> createState() =>
      _JobDescriptionScreenState();
}

class _JobDescriptionScreenState extends ConsumerState<JobDescriptionScreen> {
  _DescriptionLanguage _language = _DescriptionLanguage.english;

  @override
  Widget build(BuildContext context) {
    final analysis = ref.watch(currentAnalysisProvider);
    if (analysis == null) {
      return AppScreen(
        child: NoAnalysisSelected(onGoHome: () => context.go('/')),
      );
    }

    final explanation = _language == _DescriptionLanguage.english
        ? analysis.simpleEnglishExplanation
        : analysis.simpleLugandaExplanation.isEmpty
        ? 'Analyze a fresh job to see the Luganda version for this section.'
        : analysis.simpleLugandaExplanation;

    return AppScreen(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            JobTopBar(
              title: 'Job Description',
              onBack: () => context.go('/wants'),
            ),
            const SizedBox(height: 16),
            JDCard(
              backgroundColor: const Color(0xFFFBF7FF),
              borderColor: const Color(0xFFE9D5FF),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const JobSectionHeader(
                    icon: Icons.translate_rounded,
                    color: AppColors.violet,
                    title: 'Choose Language',
                  ),
                  const SizedBox(height: 14),
                  SegmentedButton<_DescriptionLanguage>(
                    segments: const [
                      ButtonSegment(
                        value: _DescriptionLanguage.english,
                        label: Text('Simple English'),
                        icon: Icon(Icons.language_rounded),
                      ),
                      ButtonSegment(
                        value: _DescriptionLanguage.luganda,
                        label: Text('Luganda'),
                        icon: Icon(Icons.record_voice_over_rounded),
                      ),
                    ],
                    selected: {_language},
                    onSelectionChanged: (selection) {
                      setState(() => _language = selection.first);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _language == _DescriptionLanguage.english
                        ? 'In Simple English'
                        : 'Mu Luganda',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(explanation),
                  const SizedBox(height: 16),
                  const InsightsIllustration(),
                ],
              ),
            ),
            const SizedBox(height: 14),
            JDCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const JobSectionHeader(
                    icon: Icons.task_alt_rounded,
                    color: AppColors.violet,
                    title: 'Main Tasks',
                  ),
                  const SizedBox(height: 10),
                  ...analysis.mainTasks.map(
                    (task) => CheckLine(
                      text: task,
                      color: AppColors.violet,
                      compact: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            PrimaryAction(
              label: 'Who Should Apply?',
              icon: Icons.arrow_forward_rounded,
              onPressed: () => context.go('/fit'),
            ),
          ],
        ),
      ),
    );
  }
}
