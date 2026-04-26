
part of 'app_themes.dart';

class AppInputDecorationTheme {
  static final borderRadius = BorderRadius.circular(44);

  static final mobile = InputDecorationTheme(
    labelStyle: TextStyle(color: AppColors.gray),
    enabledBorder: StadiumInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: AppColors.gray),
    ),
    disabledBorder: StadiumInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: AppColors.gray),
    ),
    focusedBorder: StadiumInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: AppColors.primary),
    ),
    errorBorder: StadiumInputBorder(
      borderRadius: borderRadius,
      borderSide: const BorderSide(color: AppColors.red),
    ),
    focusedErrorBorder: StadiumInputBorder(
      borderRadius: borderRadius,
      borderSide: const BorderSide(color: AppColors.red),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 6,
    ),
  );
}

class StadiumInputBorder extends InputBorder {
  const StadiumInputBorder({
    super.borderSide = const BorderSide(),
    this.borderRadius = const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    ),
  });

  final BorderRadius borderRadius;

  @override
  bool get isOutline => false;

  @override
  StadiumInputBorder copyWith({ BorderSide? borderSide, BorderRadius? borderRadius }) {
    return StadiumInputBorder(
      borderSide: borderSide ?? this.borderSide,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.all(borderSide.width);
  }

  @override
  StadiumInputBorder scale(double t) {
    return StadiumInputBorder(borderSide: borderSide.scale(t));
  }

  @override
  Path getInnerPath(Rect rect, { TextDirection? textDirection }) {
    return Path()
      ..addRRect(borderRadius.resolve(textDirection).toRRect(rect).deflate(borderSide.width));
  }

  @override
  Path getOuterPath(Rect rect, { TextDirection? textDirection }) {
    return Path()
      ..addRRect(borderRadius.resolve(textDirection).toRRect(rect));
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is StadiumInputBorder) {
      return StadiumInputBorder(
        borderSide: BorderSide.lerp(a.borderSide, borderSide, t),
        borderRadius: BorderRadius.lerp(a.borderRadius, borderRadius, t)!,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is StadiumInputBorder) {
      return StadiumInputBorder(
        borderSide: BorderSide.lerp(borderSide, b.borderSide, t),
        borderRadius: BorderRadius.lerp(borderRadius, b.borderRadius, t)!,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  void paint(
      Canvas canvas,
      Rect rect, {
        double? gapStart,
        double gapExtent = 0.0,
        double gapPercentage = 0.0,
        TextDirection? textDirection,
      }) {
    canvas.drawPath(getInnerPath(rect, textDirection: textDirection), borderSide.toPaint());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is InputBorder
        && other.borderSide == borderSide;
  }

  @override
  int get hashCode => borderSide.hashCode;
}
