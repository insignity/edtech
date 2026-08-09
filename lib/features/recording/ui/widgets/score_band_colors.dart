import 'package:edtech/core/theme/app_themes.dart';
import 'package:edtech/features/recording/models/retelling_result.dart';
import 'package:flutter/material.dart';

/// The one place a score band turns into a colour, so the results screen and
/// the history list can never drift apart.
Color bandColor(ScoreBand band) => switch (band) {
  ScoreBand.strong => AppColors.success,
  ScoreBand.fair => AppColors.warning,
  ScoreBand.weak => AppColors.error,
};

Color bandBackground(ScoreBand band) => switch (band) {
  ScoreBand.strong => AppColors.successLight,
  ScoreBand.fair => AppColors.warningLight,
  ScoreBand.weak => AppColors.errorLight,
};
