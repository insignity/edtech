import 'package:auto_route/auto_route.dart';
import 'package:edtech/features/courses/models/course_model.dart';
import 'package:edtech/features/courses/ui/widgets/subscribed_tile.dart';
import 'package:edtech/shared/extensions/extensions.dart';
import 'package:edtech/shared/widgets/boxes.dart';
import 'package:flutter/material.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_themes.dart';

class CourseTile extends StatelessWidget {
  final CourseModel course;

  const CourseTile(this.course, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (course.previewUrl != null)
            Image.network(
              course.previewUrl!,
              fit: BoxFit.fitHeight,
              alignment: Alignment.centerRight,
              width: 150,
            ),
          const WBox(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  course.name,
                  style: context.text.titleLarge! + Colors.black,
                ),
                if (course.isSubscribed) SubscribedTile(),
                ElevatedButton(
                  onPressed: () {
                    context.router.push(CourseDetailsRoute(id: course.id));
                  },
                  child: const Text("Learn more"),
                ),
              ],
            ),
          ),
          const WBox(8),
        ],
      ),
    );
  }
}
