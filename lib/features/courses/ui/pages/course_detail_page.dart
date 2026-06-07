import 'package:auto_route/annotations.dart';
import 'package:edtech/features/courses/ui/widgets/subscribed_tile.dart';
import 'package:edtech/shared/extensions/extensions.dart';
import 'package:edtech/shared/widgets/boxes.dart';
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: BlocBuilder<CourseDetailsBloc, CourseDetailsState>(
            builder: (context, state) {
              if (state is CourseDetailsInitial) {
                return SizedBox.shrink();
              } else if (state is CourseDetailsLoading) {
                return CircularProgressIndicator();
              } else if (state is CourseDetailsError) {
                return Center(child: Text(state.error));
              } else {
                final old = state as CourseDetailsLoaded;
                final course = old.course;
                final height = MediaQuery.of(context).size.height / 3;
                // state is CourseDetailsLoaded
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (course.previewUrl != null)
                        Image.network(course.previewUrl!),
                      HBox(16),
                      Text(
                        course.name,
                        textAlign: TextAlign.center,
                        style: context.text.titleLarge,
                      ),
                      if (course.description != null)
                        SizedBox(
                          height: height,
                          child: SingleChildScrollView(
                            child: Text(
                              course.description!,
                              style: context.text.bodyLarge,
                            ),
                          ),
                        ),
                      if (course.isSubscribed) SubscribedTile(),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: ElevatedButton(
                          onPressed: () {
                            bloc.add(
                              course.isSubscribed
                                  ? CourseDetailsUnsubscribe()
                                  : CourseDetailsSubscribe(),
                            );
                          },
                          child: Text(
                            course.isSubscribed ? "Unsubscribe" : "Subscribe",
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
