import 'package:auto_route/auto_route.dart';
import 'package:edtech/core/router/app_router.dart';
import 'package:edtech/core/sl/injection.dart';
import 'package:edtech/core/theme/app_themes.dart';
import 'package:edtech/features/recording/ui/widgets/retelling_result_view.dart';
import 'package:edtech/shared/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/attempt_details_bloc.dart';

/// A past result, opened from the history list.
///
/// Shows the same breakdown as the screen after a recording, minus the "Next"
/// action — leaving here means going back to history, not out of the flow.
@RoutePage()
class AttemptDetailsPage extends StatelessWidget implements AutoRouteWrapper {
  final String attemptId;
  final String lessonId;
  final String lessonTitle;
  final int attemptNumber;
  final int? delta;

  const AttemptDetailsPage({
    super.key,
    required this.attemptId,
    required this.lessonId,
    required this.lessonTitle,
    required this.attemptNumber,
    this.delta,
  });

  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
    create: (_) =>
        sl<AttemptDetailsBloc>()..add(AttemptDetailsFetch(attemptId, delta: delta)),
    child: this,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(title: lessonTitle, attemptNumber: attemptNumber),
            Expanded(
              child: BlocBuilder<AttemptDetailsBloc, AttemptDetailsState>(
                builder: (context, state) => switch (state) {
                  AttemptDetailsInitial() || AttemptDetailsLoading() =>
                    const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  AttemptDetailsError() => _Error(
                    message: state.error,
                    attemptId: attemptId,
                    delta: delta,
                  ),
                  AttemptDetailsLoaded() => RetellingResultView(
                    result: state.result,
                    showDelta: state.showDelta,
                  ),
                },
              ),
            ),
            _Actions(lessonId: lessonId, lessonTitle: lessonTitle),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final int attemptNumber;

  const _Header({required this.title, required this.attemptNumber});

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.text.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Attempt $attemptNumber',
                  style: context.text.labelMedium! + AppColors.gray,
                ),
              ],
            ),
          ),
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
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          // Push, not replace: Back should return to this result, and then to
          // the history it was opened from.
          onPressed: () => context.router.push(
            RecordingRoute(lessonId: lessonId, lessonTitle: lessonTitle),
          ),
          child: const Text('Practise again'),
        ),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  final String message;
  final String attemptId;
  final int? delta;

  const _Error({
    required this.message,
    required this.attemptId,
    required this.delta,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.gray,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: context.text.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.read<AttemptDetailsBloc>().add(
                AttemptDetailsFetch(attemptId, delta: delta),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
