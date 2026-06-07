// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [CourseDetailsPage]
class CourseDetailsRoute extends PageRouteInfo<CourseDetailsRouteArgs> {
  CourseDetailsRoute({
    Key? key,
    required String id,
    List<PageRouteInfo>? children,
  }) : super(
         CourseDetailsRoute.name,
         args: CourseDetailsRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'CourseDetailsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CourseDetailsRouteArgs>(
        orElse: () => CourseDetailsRouteArgs(id: pathParams.getString('id')),
      );
      return CourseDetailsPage(key: args.key, id: args.id);
    },
  );
}

class CourseDetailsRouteArgs {
  const CourseDetailsRouteArgs({this.key, required this.id});

  final Key? key;

  final String id;

  @override
  String toString() {
    return 'CourseDetailsRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CourseDetailsRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [CoursesPage]
class CoursesRoute extends PageRouteInfo<void> {
  const CoursesRoute({List<PageRouteInfo>? children})
    : super(CoursesRoute.name, initialChildren: children);

  static const String name = 'CoursesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CoursesPage();
    },
  );
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginPage();
    },
  );
}

/// generated route for
/// [MyCoursesPage]
class MyCoursesRoute extends PageRouteInfo<void> {
  const MyCoursesRoute({List<PageRouteInfo>? children})
    : super(MyCoursesRoute.name, initialChildren: children);

  static const String name = 'MyCoursesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MyCoursesPage();
    },
  );
}

/// generated route for
/// [NavBarPage]
class NavBarRoute extends PageRouteInfo<void> {
  const NavBarRoute({List<PageRouteInfo>? children})
    : super(NavBarRoute.name, initialChildren: children);

  static const String name = 'NavBarRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return NavBarPage();
    },
  );
}

/// generated route for
/// [ProfilePage]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfilePage();
    },
  );
}

/// generated route for
/// [RegisterPage]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RegisterPage();
    },
  );
}
