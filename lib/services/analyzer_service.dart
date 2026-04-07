import '../models/resume_result.dart';

/// Rule-based ATS (Applicant Tracking System) analysis engine.
/// Scores a resume on a 0–100 scale based on keywords, sections, and formatting.
class AnalyzerService {
  // ─────────────────────────────────────────────────────────────
  // Keyword library (grouped by category)
  // ─────────────────────────────────────────────────────────────
  static const List<String> _programmingLanguages = [
    'python', 'java', 'javascript', 'typescript', 'dart', 'kotlin',
    'swift', 'c++', 'c#', 'go', 'rust', 'ruby', 'php', 'scala',
    'r', 'matlab', 'bash', 'shell',
  ];

  static const List<String> _frameworks = [
    'react', 'angular', 'vue', 'flutter', 'django', 'flask',
    'spring', 'node', 'express', 'fastapi', 'next.js', 'nuxt',
    'tensorflow', 'pytorch', 'keras', 'scikit-learn',
  ];

  static const List<String> _databases = [
    'sql', 'mysql', 'postgresql', 'mongodb', 'redis', 'firebase',
    'dynamodb', 'cassandra', 'elasticsearch', 'sqlite',
  ];

  static const List<String> _devOpsAndTools = [
    'git', 'docker', 'kubernetes', 'jenkins', 'ci/cd', 'aws',
    'azure', 'gcp', 'linux', 'terraform', 'ansible', 'github',
    'gitlab', 'jira', 'agile', 'scrum',
  ];

  static const List<String> _concepts = [
    'api', 'rest', 'graphql', 'microservices', 'machine learning',
    'deep learning', 'nlp', 'data structures', 'algorithms',
    'oop', 'design patterns', 'testing', 'unit test',
  ];

  // All keywords combined
  static List<String> get _allKeywords => [
        ..._programmingLanguages,
        ..._frameworks,
        ..._databases,
        ..._devOpsAndTools,
        ..._concepts,
      ];

  // Resume section headers to detect
  static const Map<String, List<String>> _sectionPatterns = {
    'Skills': ['skills', 'technical skills', 'core competencies', 'expertise'],
    'Experience': [
      'experience',
      'work experience',
      'employment',
      'professional experience'
    ],
    'Education': ['education', 'academic background', 'qualifications'],
    'Projects': ['projects', 'personal projects', 'academic projects', 'portfolio'],
    'Summary': ['summary', 'objective', 'profile', 'about me'],
    'Certifications': [
      'certifications',
      'certificates',
      'achievements',
      'awards'
    ],
  };

  // ─────────────────────────────────────────────────────────────
  // Main analysis method
  // ─────────────────────────────────────────────────────────────

  /// Analyzes [resumeText] and returns a [ResumeResult] with full scoring breakdown.
  ResumeResult analyze(String resumeText) {
    final text = resumeText.toLowerCase();

    // 1. Keyword matching
    final matched = _allKeywords.where((kw) => text.contains(kw)).toList();
    final keywordScore = _calculateKeywordScore(matched.length);

    // 2. Section detection
    final sections = _detectSections(text);
    final sectionScore = _calculateSectionScore(sections);

    // 3. Achievement / metric detection
    final hasQuantified = _hasQuantifiedAchievements(text);
    final achievementScore = hasQuantified ? 15 : 0;

    // 4. Content length / depth bonus
    final depthScore = _calculateDepthScore(resumeText.length);

    // 5. Aggregate (weights sum to 100)
    int total = keywordScore + sectionScore + achievementScore + depthScore;
    total = total.clamp(0, 100);

    // 6. Build strengths / weaknesses / suggestions
    final strengths = _buildStrengths(matched, sections, hasQuantified);
    final weaknesses = _buildWeaknesses(matched, sections, hasQuantified);
    final suggestions = _buildSuggestions(matched, sections, hasQuantified);

    return ResumeResult(
      atsScore: total,
      strengths: strengths,
      weaknesses: weaknesses,
      suggestions: suggestions,
      detectedSections: sections,
      matchedKeywords: matched,
      keywordMatchCount: matched.length,
      hasQuantifiedAchievements: hasQuantified,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Scoring helpers
  // ─────────────────────────────────────────────────────────────

  int _calculateKeywordScore(int matchCount) {
    // Max 40 points: ~1 point per 2 keywords, capped at 40
    return (matchCount * 2).clamp(0, 40);
  }

  int _calculateSectionScore(List<String> sections) {
    // Max 35 points: each important section is worth points
    const weights = {
      'Experience': 10,
      'Skills': 8,
      'Education': 7,
      'Projects': 7,
      'Summary': 4,
      'Certifications': 4,
    };
    int score = 0;
    for (final section in sections) {
      score += weights[section] ?? 2;
    }
    return score.clamp(0, 35);
  }

  int _calculateDepthScore(int charCount) {
    // Max 10 points for content length / depth
    if (charCount > 2000) return 10;
    if (charCount > 1000) return 6;
    if (charCount > 500) return 3;
    return 0;
  }

  bool _hasQuantifiedAchievements(String text) {
    // Look for patterns like "30%", "3x", "reduced by 50", "led a team of 10"
    return RegExp(
      r'\d+\s*%|\d+x|\d+\+|increased|decreased|reduced|improved|led\s+\d+|team\s+of\s+\d+',
    ).hasMatch(text);
  }

  List<String> _detectSections(String text) {
    final found = <String>[];
    for (final entry in _sectionPatterns.entries) {
      for (final pattern in entry.value) {
        if (text.contains(pattern)) {
          found.add(entry.key);
          break;
        }
      }
    }
    return found;
  }

  // ─────────────────────────────────────────────────────────────
  // Feedback builders
  // ─────────────────────────────────────────────────────────────

  List<String> _buildStrengths(
    List<String> keywords,
    List<String> sections,
    bool hasQuantified,
  ) {
    final list = <String>[];
    if (keywords.length >= 8) {
      list.add('Strong technical keyword density (${keywords.length} matches)');
    } else if (keywords.length >= 4) {
      list.add('Decent technical keywords present (${keywords.length} matches)');
    }
    if (sections.contains('Experience')) {
      list.add('Work experience section is present');
    }
    if (sections.contains('Projects')) {
      list.add('Project portfolio is included');
    }
    if (sections.contains('Skills')) {
      list.add('Dedicated skills section improves ATS parsing');
    }
    if (sections.contains('Education')) {
      list.add('Education credentials are clearly listed');
    }
    if (hasQuantified) {
      list.add('Quantified achievements demonstrate measurable impact');
    }
    if (sections.contains('Certifications')) {
      list.add('Certifications add credibility to your profile');
    }
    return list.isEmpty ? ['Upload a stronger resume to see strengths'] : list;
  }

  List<String> _buildWeaknesses(
    List<String> keywords,
    List<String> sections,
    bool hasQuantified,
  ) {
    final list = <String>[];
    if (keywords.length < 4) {
      list.add('Very few technical keywords detected — ATS may filter this out');
    }
    if (!sections.contains('Experience')) {
      list.add('No work experience section found');
    }
    if (!sections.contains('Skills')) {
      list.add('Missing a dedicated Skills section');
    }
    if (!sections.contains('Projects')) {
      list.add('No projects section — missed opportunity to showcase work');
    }
    if (!hasQuantified) {
      list.add('No measurable achievements or metrics found');
    }
    if (!sections.contains('Summary')) {
      list.add('No professional summary or objective statement');
    }
    return list.isEmpty ? ['No major weaknesses found — great resume!'] : list;
  }

  List<String> _buildSuggestions(
    List<String> keywords,
    List<String> sections,
    bool hasQuantified,
  ) {
    final list = <String>[];
    if (!hasQuantified) {
      list.add('Add quantified impact: e.g. "Reduced load time by 40%"');
    }
    if (keywords.length < 6) {
      list.add('Include more industry-relevant keywords (check the job description)');
    }
    if (!sections.contains('Summary')) {
      list.add('Add a 2–3 line professional summary at the top');
    }
    if (!sections.contains('Projects')) {
      list.add('Add a Projects section with GitHub links or live demos');
    }
    if (!sections.contains('Certifications')) {
      list.add('List any certifications (Google, AWS, Coursera, etc.)');
    }
    if (!sections.contains('Skills')) {
      list.add('Create a dedicated Skills section for better ATS parsing');
    }
    list.add('Tailor your resume keywords to each specific job posting');
    list.add('Keep resume to 1 page unless you have 5+ years of experience');
    return list;
  }
}
