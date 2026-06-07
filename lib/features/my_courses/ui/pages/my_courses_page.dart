import 'package:auto_route/annotations.dart';
import 'package:edtech/core/theme/app_themes.dart';
import 'package:edtech/features/courses/ui/widgets/course_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/extensions/extensions.dart';
import '../bloc/my_courses_bloc.dart';

@RoutePage()
class MyCoursesPage extends StatefulWidget {
  const MyCoursesPage({super.key});

  @override
  State<MyCoursesPage> createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> {
  late final bloc = context.read<MyCoursesBloc>();

  @override
  void initState() {
    bloc.add(MyCoursesFetch());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Courses', style: context.text.headlineMedium),
                  const SizedBox(height: 4),
                  Text('Your enrolled courses', style: context.text.bodyMedium),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<MyCoursesBloc, MyCoursesState>(
                builder: (context, state) {
                  if (state is MyCoursesLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  if (state is MyCoursesError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.gray),
                            const SizedBox(height: 16),
                            Text(state.error, style: context.text.bodyMedium, textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () => bloc.add(MyCoursesFetch()),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try again'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is MyCoursesLoaded) {
                    final courses = state.courses.courses;

                    if (courses.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bookmark_border_rounded, size: 64, color: AppColors.gray),
                            const SizedBox(height: 16),
                            Text('No courses yet', style: context.text.bodyMedium),
                            const SizedBox(height: 8),
                            Text(
                              'Enroll in courses to see them here',
                              style: context.text.bodyMedium,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      itemCount: courses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => CourseTile(courses[index]),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
