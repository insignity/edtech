import 'package:auto_route/auto_route.dart';
import 'package:edtech/core/router/app_router.dart';
import 'package:edtech/core/theme/app_themes.dart';
import 'package:flutter/material.dart';

import '../../../../shared/extensions/extensions.dart';
import '../../models/retelling_result.dart';
import '../widgets/retelling_result_view.dart';

@RoutePage()
class ResultsPage extends StatelessWidget {
  final RetellingResult result;
  final String lessonId;
  final String lessonTitle;

  const ResultsPage({
    super.key,
    required this.result,
    required this.lessonId,
    this.lessonTitle = 'Retelling',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(child: RetellingResultView(result: result)),
            _Actions(lessonId: lessonId, lessonTitle: lessonTitle),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.grayLight)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.router.maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: AppColors.darkText,
          ),
          Text('Results', style: context.text.titleLarge),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  final String lessonId;
  final String lessonTitle;

  const _Actions({required this.lessonId, required this.lessonTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.grayLight)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              // Replace so Back from a fresh take does not land on stale results.
              onPressed: () => context.router.replace(
                RecordingRoute(lessonId: lessonId, lessonTitle: lessonTitle),
              ),
              child: const Text('Try again'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.router.replaceAll([NavBarRoute()]),
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}
