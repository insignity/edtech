/// The stages the backend reports while grading a retelling, in order.
///
/// The recording screen renders one checklist row per value.
enum AnalysisStep {
  uploaded('Uploaded'),
  transcription('Transcription'),
  metrics('Metrics'),
  analysis('AI analysis…');

  const AnalysisStep(this.label);

  final String label;
}
