import 'package:auto_route/auto_route.dart';
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
      body: SafeArea(
        child: Column(
          children: [
            Text("All courses", style: context.text.titleLarge),
            BlocBuilder<CoursesBloc, CoursesState>(
              builder: (context, state) {
                if (state is CoursesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CoursesError) {
                  return Center(child: Text(state.error));
                } else if (state is CoursesLoaded) {
                  final courses = state.courses.courses;

                  return Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];

                        return CourseTile(course);
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
