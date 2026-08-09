import 'package:auto_route/auto_route.dart';
import 'package:edtech/core/sl/injection.dart';
import 'package:edtech/core/theme/app_themes.dart';
import 'package:edtech/features/speaking_history/ui/widgets/history_lesson_card.dart';
import 'package:edtech/shared/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/speaking_history_bloc.dart';

@RoutePage()
class SpeakingHistoryPage extends StatefulWidget implements AutoRouteWrapper {
  const SpeakingHistoryPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
    create: (_) => sl<SpeakingHistoryBloc>()..add(SpeakingHistoryFetch()),
    child: this,
  );

  @override
  State<SpeakingHistoryPage> createState() => _SpeakingHistoryPageState();
}

class _SpeakingHistoryPageState extends State<SpeakingHistoryPage> {
  final _scrollController = ScrollController();

  /// How close to the bottom the list gets before the next page is asked for.
  static const double _loadMoreThreshold = 300;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      // The bloc drops this unless there is a page left and none is in flight.
      context.read<SpeakingHistoryBloc>().add(SpeakingHistoryLoadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Speaking History')),
      body: SafeArea(
        child: BlocBuilder<SpeakingHistoryBloc, SpeakingHistoryState>(
          builder: (context, state) => switch (state) {
            SpeakingHistoryInitial() || SpeakingHistoryLoading() => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            SpeakingHistoryError() => _Error(message: state.error),
            SpeakingHistoryLoaded() when state.lessons.isEmpty => const _Empty(),
            SpeakingHistoryLoaded() => _List(
              state: state,
              controller: _scrollController,
            ),
          },
        ),
      ),
    );
  }
}

class _List extends StatelessWidget {
  final SpeakingHistoryLoaded state;
  final ScrollController controller;

  const _List({required this.state, required this.controller});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async =>
          context.read<SpeakingHistoryBloc>().add(SpeakingHistoryFetch()),
      child: ListView.separated(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        // One extra row carries the paging spinner.
        itemCount: state.lessons.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= state.lessons.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          }
          return HistoryLessonCard(state.lessons[index]);
        },
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mic_none_rounded, size: 64, color: AppColors.gray),
            const SizedBox(height: 16),
            Text('No recordings yet', style: context.text.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Finish a speaking task and your results will appear here.',
              style: context.text.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  final String message;

  const _Error({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.gray),
            const SizedBox(height: 16),
            Text(
              message,
              style: context.text.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.read<SpeakingHistoryBloc>().add(
                SpeakingHistoryFetch(),
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
