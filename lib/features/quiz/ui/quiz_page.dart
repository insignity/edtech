import 'package:auto_route/auto_route.dart';
import 'package:edtech/core/theme/app_themes.dart';
import 'package:edtech/features/quiz/bloc/quiz_bloc.dart';
import 'package:edtech/shared/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class QuizPage extends StatefulWidget {
  final String lessonId;

  const QuizPage({
    super.key,
    @PathParam('lessonId') required this.lessonId,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late final QuizBloc _bloc;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<QuizBloc>();
    _bloc.add(QuizLoad(widget.lessonId));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text('Quiz'),
        leading: GestureDetector(
          onTap: () => context.router.pop(),
          child: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: BlocBuilder<QuizBloc, QuizState>(
        builder: (context, state) {
          if (state is QuizLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is QuizError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(state.error, textAlign: TextAlign.center, style: context.text.bodyMedium),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => _bloc.add(QuizLoad(widget.lessonId)),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is QuizResult) {
            return _QuizResultView(result: state.result);
          }

          final quiz = state is QuizLoaded ? state.quiz : (state as QuizSubmitting).quiz;
          final selectedAnswers = state is QuizLoaded
              ? state.selectedAnswers
              : (state as QuizSubmitting).selectedAnswers;
          final isSubmitting = state is QuizSubmitting;
          final allAnswered = state is QuizLoaded ? state.allAnswered : true;
          final answeredCount = state is QuizLoaded ? state.answeredCount : quiz.questions.length;

          return Column(
            children: [
              // Progress bar
              _QuizProgressBar(
                current: answeredCount,
                total: quiz.questions.length,
                currentPage: _currentPage,
              ),

              // Questions pager
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: quiz.questions.length,
                  itemBuilder: (context, index) {
                    final question = quiz.questions[index];
                    final selected = selectedAnswers[question.id];
                    return _QuestionCard(
                      index: index,
                      total: quiz.questions.length,
                      question: question.text,
                      options: question.options.map((o) => (id: o.id, text: o.text)).toList(),
                      selectedOptionId: selected,
                      onSelect: (optionId) {
                        _bloc.add(QuizSelectAnswer(question.id, optionId));
                        // Auto-advance to next question
                        if (index < quiz.questions.length - 1) {
                          Future.delayed(const Duration(milliseconds: 300), () {
                            _goToPage(index + 1);
                          });
                        }
                      },
                    );
                  },
                ),
              ),

              // Bottom bar
              Container(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                color: AppColors.white,
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _goToPage(_currentPage - 1),
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text('Back'),
                        ),
                      ),
                    if (_currentPage > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _currentPage < quiz.questions.length - 1
                          ? ElevatedButton.icon(
                              onPressed: () => _goToPage(_currentPage + 1),
                              icon: const Icon(Icons.arrow_forward_rounded),
                              label: const Text('Next'),
                              iconAlignment: IconAlignment.end,
                            )
                          : ElevatedButton.icon(
                              onPressed: isSubmitting || !allAnswered
                                  ? null
                                  : () => _bloc.add(QuizSubmit(quiz.id)),
                              icon: isSubmitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.check_rounded),
                              label: Text(isSubmitting
                                  ? 'Submitting...'
                                  : !allAnswered
                                      ? 'Answer all questions'
                                      : 'Submit'),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Progress bar ────────────────────────────────────────────────────────────

class _QuizProgressBar extends StatelessWidget {
  final int current;
  final int total;
  final int currentPage;

  const _QuizProgressBar({
    required this.current,
    required this.total,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${currentPage + 1} of $total',
                style: context.text.labelMedium,
              ),
              Text(
                '$current answered',
                style: context.text.labelMedium!.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : current / total,
              backgroundColor: AppColors.border,
              color: AppColors.primary,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Question card ────────────────────────────────────────────────────────────

class _QuestionCard extends StatelessWidget {
  final int index;
  final int total;
  final String question;
  final List<({String id, String text})> options;
  final String? selectedOptionId;
  final void Function(String optionId) onSelect;

  const _QuestionCard({
    required this.index,
    required this.total,
    required this.question,
    required this.options,
    required this.selectedOptionId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: context.text.titleMedium),
          const SizedBox(height: 20),
          ...options.map((option) {
            final isSelected = selectedOptionId == option.id;
            return GestureDetector(
              onTap: () => onSelect(option.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryLight : AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.gray,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(option.text, style: context.text.bodyLarge),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Result view ─────────────────────────────────────────────────────────────

class _QuizResultView extends StatelessWidget {
  final dynamic result;

  const _QuizResultView({required this.result});

  Color _levelColor(String level) {
    switch (level) {
      case 'A1':
      case 'A2':
        return const Color(0xFFEF5350);
      case 'B1':
      case 'B2':
        return const Color(0xFFFFA726);
      case 'C1':
      case 'C2':
        return const Color(0xFF66BB6A);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final levelColor = _levelColor(result.level as String);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Text('Your Result', style: context.text.titleMedium),
                const SizedBox(height: 16),
                // Level badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: levelColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    result.level as String,
                    style: context.text.headlineMedium!.copyWith(
                      color: levelColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${result.score}/${result.totalQuestions}',
                      style: context.text.headlineSmall,
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${result.percent}%',
                        style: context.text.labelLarge!.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          Text('Review Answers', style: context.text.titleMedium),
          const SizedBox(height: 12),

          // Answer review list
          ...(result.answers as List<dynamic>).map((answer) {
            final isCorrect = answer.isCorrect as bool;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCorrect ? AppColors.success : AppColors.error,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: isCorrect ? AppColors.success : AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          answer.question as String,
                          style: context.text.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (answer.selectedOption != null && !isCorrect)
                    _AnswerRow(
                      label: 'Your answer',
                      value: answer.selectedOption as String,
                      color: AppColors.error,
                    ),
                  if (answer.selectedOption == null && !isCorrect)
                    _AnswerRow(
                      label: 'Your answer',
                      value: 'Not answered',
                      color: AppColors.gray,
                    ),
                  _AnswerRow(
                    label: 'Correct',
                    value: answer.correctOption as String,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      answer.explanation as String,
                      style: context.text.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _AnswerRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label: ', style: context.text.labelMedium),
          Expanded(
            child: Text(
              value,
              style: context.text.labelMedium!.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
