import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:edtech/core/router/app_router.dart';
import 'package:edtech/core/theme/app_themes.dart';
import 'package:edtech/shared/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/course_details/course_details_bloc.dart';

@RoutePage()
class CourseDetailsPage extends StatefulWidget {
  final String id;

  const CourseDetailsPage({super.key, @PathParam('id') required this.id});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  late final bloc = context.read<CourseDetailsBloc>();

  @override
  void initState() {
    bloc.add(CourseDetailsFetch(widget.id));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<CourseDetailsBloc, CourseDetailsState>(
        builder: (context, state) {
          if (state is CourseDetailsLoading || state is CourseDetailsInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is CourseDetailsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(state.error, style: context.text.bodyMedium, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => bloc.add(CourseDetailsFetch(widget.id)),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final loaded = state as CourseDetailsLoaded;
          final course = loaded.course;
          final lessons = loaded.lessons;

          return CustomScrollView(
            slivers: [
              // App bar with image
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                backgroundColor: AppColors.white,
                leading: GestureDetector(
                  onTap: () => context.router.pop(),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_back_rounded, color: AppColors.darkText),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: course.previewUrl != null
                      ? Image.network(
                          course.previewUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imageFallback(),
                        )
                      : _imageFallback(),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text(course.name, style: context.text.headlineSmall),
                      const SizedBox(height: 16),

                      if (course.description != null) ...[
                        Text('About this course', style: context.text.titleMedium),
                        const SizedBox(height: 8),
                        Text(
                          course.description!,
                          style: context.text.bodyLarge,
                        ),
                      ],

                      // Lessons section
                      if (lessons.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        Text('Lessons', style: context.text.titleMedium),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                  ),
                ),
              ),

              // Lesson tiles
              if (lessons.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final lesson = lessons[index];
                      final isLast = index == lessons.length - 1;
                      return Padding(
                        padding: EdgeInsets.fromLTRB(24, 0, 24, isLast ? 80 : 8),
                        child: _LessonTile(
                          number: index + 1,
                          lesson: lesson,
                          onTap: () => context.router.push(LessonRoute(lessonId: lesson.id)),
                        ),
                      );
                    },
                    childCount: lessons.length,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: AppColors.primaryLight,
      child: const Center(
        child: Icon(Icons.school_rounded, size: 64, color: AppColors.primary),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final int number;
  final dynamic lesson;
  final VoidCallback onTap;

  const _LessonTile({
    required this.number,
    required this.lesson,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: context.text.labelLarge!.copyWith(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.name as String,
                    style: context.text.bodyLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (lesson.isCompleted as bool) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text('Completed', style: context.text.labelSmall!.copyWith(color: AppColors.success)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.play_circle_outline_rounded, color: AppColors.primary, size: 28),
          ],
        ),
      ),
    );
  }
}
