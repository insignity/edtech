import 'package:edtech/features/recording/models/analysis_step.dart';
import 'package:edtech/features/recording/models/retelling_result.dart';

/// What the analysis stream reports back while grading a retelling.
sealed class AnalysisUpdate {
  const AnalysisUpdate();
}

/// A stage finished — the checklist ticks one row forward.
class AnalysisStepDone extends AnalysisUpdate {
  final AnalysisStep step;
  const AnalysisStepDone(this.step);
}

/// Grading finished and the score is in.
class AnalysisResultReady extends AnalysisUpdate {
  final RetellingResult result;
  const AnalysisResultReady(this.result);
}
