import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/resume_result.dart';
import '../services/pdf_service.dart';
import '../services/analyzer_service.dart';
import '../services/ai_service.dart';

/// Enum representing the current state of the resume analysis.
enum AnalysisState { idle, loadingPdf, analyzing, loadingAI, loaded, error }

/// Central state provider for the resume analysis workflow.
/// Manages file picking, PDF parsing, ATS scoring, and AI insights.
class ResumeProvider extends ChangeNotifier {
  final PdfService _pdfService;
  final AnalyzerService _analyzerService;
  final AiService _aiService;

  ResumeProvider({
    PdfService? pdfService,
    AnalyzerService? analyzerService,
    AiService? aiService,
  })  : _pdfService = pdfService ?? PdfService(),
        _analyzerService = analyzerService ?? AnalyzerService(),
        _aiService = aiService ?? AiService();

  // ─── State ───────────────────────────────────────────────────
  AnalysisState _state = AnalysisState.idle;
  ResumeResult? _result;
  String? _errorMessage;
  String? _selectedFileName;
  String _extractedText = '';

  // ─── Getters ─────────────────────────────────────────────────
  AnalysisState get state => _state;
  ResumeResult? get result => _result;
  String? get errorMessage => _errorMessage;
  String? get selectedFileName => _selectedFileName;
  bool get isIdle => _state == AnalysisState.idle;
  bool get isLoading => _state == AnalysisState.loadingPdf ||
      _state == AnalysisState.analyzing ||
      _state == AnalysisState.loadingAI;
  bool get hasResult => _result != null;
  bool get isAiLoading => _state == AnalysisState.loadingAI;

  // ─── Main workflow ────────────────────────────────────────────

  /// Full analysis pipeline: pick → extract → analyze → AI insights
  Future<void> pickAndAnalyze() async {
    try {
      // Step 1: Pick file
      _setState(AnalysisState.loadingPdf);
      final File? file = await _pdfService.pickPdfFile();

      if (file == null) {
        _setState(AnalysisState.idle);
        return;
      }

      _selectedFileName = _pdfService.getFileName(file);
      notifyListeners();

      // Step 2: Extract text
      _extractedText = await _pdfService.extractText(file);

      if (_extractedText.isEmpty) {
        _setError('Could not extract text from this PDF. Try a text-based PDF.');
        return;
      }

      // Step 3: ATS analysis (synchronous, fast)
      _setState(AnalysisState.analyzing);
      await Future.delayed(const Duration(milliseconds: 300)); // UX breathing room
      _result = _analyzerService.analyze(_extractedText);
      _setState(AnalysisState.loadingAI);

      // Step 4: AI insights (async, independent)
      await _fetchAIInsights();
    } catch (e) {
      _setError('An unexpected error occurred: $e');
    }
  }

  /// Fetches AI insights independently — called after basic analysis is done.
  /// UI already shows results; AI section shows its own loading state.
  Future<void> _fetchAIInsights() async {
    final aiData = await _aiService.analyzeWithAI(_extractedText);

    if (aiData == null) {
      // AI disabled — just show result without AI fields
      _setState(AnalysisState.loaded);
      return;
    }

    if (aiData.containsKey('error')) {
      // AI errored but don't fail whole flow — show result without AI
      _result = _result?.copyWithAI(
        aiSummary: 'AI analysis unavailable: ${aiData['error']}',
      );
      _setState(AnalysisState.loaded);
      return;
    }

    try {
      final suggestions = (aiData['suggestions'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList();

      _result = _result?.copyWithAI(
        aiSummary: aiData['summary']?.toString(),
        aiJobFitScore: aiData['job_fit_score'] as int?,
        aiSuggestions: suggestions,
      );
    } catch (_) {
      // Parsing failed — still show result without AI
    }

    _setState(AnalysisState.loaded);
  }

  /// Resets the provider back to the initial idle state.
  void reset() {
    _state = AnalysisState.idle;
    _result = null;
    _errorMessage = null;
    _selectedFileName = null;
    _extractedText = '';
    notifyListeners();
  }

  // ─── Helpers ─────────────────────────────────────────────────
  void _setState(AnalysisState s) {
    _state = s;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = AnalysisState.error;
    notifyListeners();
  }
}
