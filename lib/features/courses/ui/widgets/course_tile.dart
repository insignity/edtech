import 'package:auto_route/auto_route.dart';
import 'package:edtech/core/theme/app_themes.dart';
import 'package:edtech/features/courses/models/course_model.dart';
import 'package:edtech/shared/extensions/extensions.dart';
import 'package:flutter/material.dart';

import '../../../../core/router/app_router.dart';

class CourseTile extends StatelessWidget {
  final CourseModel course;

  const CourseTile(this.course, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.router.push(CourseDetailsRoute(id: course.id)),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: course.previewUrl != null
                  ? Image.network(
                      course.previewUrl!,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imageFallback(),
                    )
                  : _imageFallback(),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.name,
                    style: context.text.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.router.push(CourseDetailsRoute(id: course.id)),
                      child: const Text('Learn more'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      height: 140,
      color: AppColors.primaryLight,
      child: const Center(
        child: Icon(Icons.school_rounded, size: 48, color: AppColors.primary),
      ),
    );
  }
}
