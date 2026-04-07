/// Data model representing the complete analysis result of a resume.
class ResumeResult {
  final int atsScore;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> suggestions;
  final List<String> detectedSections;
  final List<String> matchedKeywords;
  final int keywordMatchCount;
  final bool hasQuantifiedAchievements;

  // AI-generated fields (nullable — populated after async AI call)
  final String? aiSummary;
  final int? aiJobFitScore;
  final List<String>? aiSuggestions;

  const ResumeResult({
    required this.atsScore,
    required this.strengths,
    required this.weaknesses,
    required this.suggestions,
    required this.detectedSections,
    required this.matchedKeywords,
    required this.keywordMatchCount,
    required this.hasQuantifiedAchievements,
    this.aiSummary,
    this.aiJobFitScore,
    this.aiSuggestions,
  });

  /// Creates a copy of this result with updated AI fields.
  ResumeResult copyWithAI({
    String? aiSummary,
    int? aiJobFitScore,
    List<String>? aiSuggestions,
  }) {
    return ResumeResult(
      atsScore: atsScore,
      strengths: strengths,
      weaknesses: weaknesses,
      suggestions: suggestions,
      detectedSections: detectedSections,
      matchedKeywords: matchedKeywords,
      keywordMatchCount: keywordMatchCount,
      hasQuantifiedAchievements: hasQuantifiedAchievements,
      aiSummary: aiSummary ?? this.aiSummary,
      aiJobFitScore: aiJobFitScore ?? this.aiJobFitScore,
      aiSuggestions: aiSuggestions ?? this.aiSuggestions,
    );
  }

  /// Score category label for display
  String get scoreLabel {
    if (atsScore >= 75) return 'Excellent';
    if (atsScore >= 55) return 'Good';
    if (atsScore >= 35) return 'Fair';
    return 'Needs Work';
  }
}
