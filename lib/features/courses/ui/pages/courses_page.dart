import 'package:auto_route/auto_route.dart';
import 'package:edtech/core/theme/app_themes.dart';
import 'package:edtech/features/courses/ui/widgets/course_tile.dart';
import 'package:edtech/shared/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/courses/courses_bloc.dart';

@RoutePage()
class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  late final bloc = context.read<CoursesBloc>();

  @override
  void initState() {
    bloc.add(CoursesFetchAll());
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
                  Text('Explore', style: context.text.headlineMedium),
                  const SizedBox(height: 4),
                  Text('Find your next course', style: context.text.bodyMedium),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<CoursesBloc, CoursesState>(
                builder: (context, state) {
                  if (state is CoursesLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  if (state is CoursesError) {
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
                              onPressed: () => bloc.add(CoursesFetchAll()),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try again'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is CoursesLoaded) {
                    final courses = state.courses.courses;

                    if (courses.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.school_outlined, size: 48, color: AppColors.gray),
                            const SizedBox(height: 16),
                            Text('No courses yet', style: context.text.bodyMedium),
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
