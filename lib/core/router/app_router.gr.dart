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
/// [ForgotPasswordPage]
class ForgotPasswordRoute extends PageRouteInfo<void> {
  const ForgotPasswordRoute({List<PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ForgotPasswordPage();
    },
  );
}

/// generated route for
/// [LessonPage]
class LessonRoute extends PageRouteInfo<LessonRouteArgs> {
  LessonRoute({
    Key? key,
    required String lessonId,
    List<PageRouteInfo>? children,
  }) : super(
         LessonRoute.name,
         args: LessonRouteArgs(key: key, lessonId: lessonId),
         rawPathParams: {'lessonId': lessonId},
         initialChildren: children,
       );

  static const String name = 'LessonRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<LessonRouteArgs>(
        orElse: () =>
            LessonRouteArgs(lessonId: pathParams.getString('lessonId')),
      );
      return LessonPage(key: args.key, lessonId: args.lessonId);
    },
  );
}

class LessonRouteArgs {
  const LessonRouteArgs({this.key, required this.lessonId});

  final Key? key;

  final String lessonId;

  @override
  String toString() {
    return 'LessonRouteArgs{key: $key, lessonId: $lessonId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LessonRouteArgs) return false;
    return key == other.key && lessonId == other.lessonId;
  }

  @override
  int get hashCode => key.hashCode ^ lessonId.hashCode;
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
/// [RecordingPage]
class RecordingRoute extends PageRouteInfo<RecordingRouteArgs> {
  RecordingRoute({
    Key? key,
    required String lessonId,
    String lessonTitle = 'Retelling',
    List<PageRouteInfo>? children,
  }) : super(
         RecordingRoute.name,
         args: RecordingRouteArgs(
           key: key,
           lessonId: lessonId,
           lessonTitle: lessonTitle,
         ),
         rawPathParams: {'lessonId': lessonId},
         initialChildren: children,
       );

  static const String name = 'RecordingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<RecordingRouteArgs>(
        orElse: () =>
            RecordingRouteArgs(lessonId: pathParams.getString('lessonId')),
      );
      return WrappedRoute(
        child: RecordingPage(
          key: args.key,
          lessonId: args.lessonId,
          lessonTitle: args.lessonTitle,
        ),
      );
    },
  );
}

class RecordingRouteArgs {
  const RecordingRouteArgs({
    this.key,
    required this.lessonId,
    this.lessonTitle = 'Retelling',
  });

  final Key? key;

  final String lessonId;

  final String lessonTitle;

  @override
  String toString() {
    return 'RecordingRouteArgs{key: $key, lessonId: $lessonId, lessonTitle: $lessonTitle}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RecordingRouteArgs) return false;
    return key == other.key &&
        lessonId == other.lessonId &&
        lessonTitle == other.lessonTitle;
  }

  @override
  int get hashCode => key.hashCode ^ lessonId.hashCode ^ lessonTitle.hashCode;
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

/// generated route for
/// [ResetPasswordPage]
class ResetPasswordRoute extends PageRouteInfo<ResetPasswordRouteArgs> {
  ResetPasswordRoute({
    Key? key,
    String uid = '',
    String token = '',
    List<PageRouteInfo>? children,
  }) : super(
         ResetPasswordRoute.name,
         args: ResetPasswordRouteArgs(key: key, uid: uid, token: token),
         rawQueryParams: {'uid': uid, 'token': token},
         initialChildren: children,
       );

  static const String name = 'ResetPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<ResetPasswordRouteArgs>(
        orElse: () => ResetPasswordRouteArgs(
          uid: queryParams.getString('uid', ''),
          token: queryParams.getString('token', ''),
        ),
      );
      return ResetPasswordPage(key: args.key, uid: args.uid, token: args.token);
    },
  );
}

class ResetPasswordRouteArgs {
  const ResetPasswordRouteArgs({this.key, this.uid = '', this.token = ''});

  final Key? key;

  final String uid;

  final String token;

  @override
  String toString() {
    return 'ResetPasswordRouteArgs{key: $key, uid: $uid, token: $token}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ResetPasswordRouteArgs) return false;
    return key == other.key && uid == other.uid && token == other.token;
  }

  @override
  int get hashCode => key.hashCode ^ uid.hashCode ^ token.hashCode;
}

/// generated route for
/// [ResultsPage]
class ResultsRoute extends PageRouteInfo<ResultsRouteArgs> {
  ResultsRoute({
    Key? key,
    required RetellingResult result,
    required String lessonId,
    String lessonTitle = 'Retelling',
    List<PageRouteInfo>? children,
  }) : super(
         ResultsRoute.name,
         args: ResultsRouteArgs(
           key: key,
           result: result,
           lessonId: lessonId,
           lessonTitle: lessonTitle,
         ),
         initialChildren: children,
       );

  static const String name = 'ResultsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ResultsRouteArgs>();
      return ResultsPage(
        key: args.key,
        result: args.result,
        lessonId: args.lessonId,
        lessonTitle: args.lessonTitle,
      );
    },
  );
}

class ResultsRouteArgs {
  const ResultsRouteArgs({
    this.key,
    required this.result,
    required this.lessonId,
    this.lessonTitle = 'Retelling',
  });

  final Key? key;

  final RetellingResult result;

  final String lessonId;

  final String lessonTitle;

  @override
  String toString() {
    return 'ResultsRouteArgs{key: $key, result: $result, lessonId: $lessonId, lessonTitle: $lessonTitle}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ResultsRouteArgs) return false;
    return key == other.key &&
        result == other.result &&
        lessonId == other.lessonId &&
        lessonTitle == other.lessonTitle;
  }

  @override
  int get hashCode =>
      key.hashCode ^ result.hashCode ^ lessonId.hashCode ^ lessonTitle.hashCode;
}

/// generated route for
/// [SpeakingHistoryPage]
class SpeakingHistoryRoute extends PageRouteInfo<void> {
  const SpeakingHistoryRoute({List<PageRouteInfo>? children})
    : super(SpeakingHistoryRoute.name, initialChildren: children);

  static const String name = 'SpeakingHistoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return WrappedRoute(child: const SpeakingHistoryPage());
    },
  );
}
