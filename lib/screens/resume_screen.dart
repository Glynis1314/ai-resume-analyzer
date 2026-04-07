import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/resume_provider.dart';
import '../widgets/score_circle.dart';
import '../widgets/result_card.dart';
import '../widgets/upload_zone.dart';
import '../widgets/ai_insights_card.dart';

/// The main screen of the AI Resume Analyzer app.
/// Displays the upload zone, triggers analysis, and shows results.
class ResumeScreen extends StatelessWidget {
  const ResumeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Consumer<ResumeProvider>(
              builder: (context, provider, _) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Upload zone
                      UploadZone(
                        selectedFileName: provider.selectedFileName,
                        isLoading: provider.isLoading,
                        onTap: () => provider.pickAndAnalyze(),
                      ),
                      const SizedBox(height: 20),

                      // Analyze button
                      _buildAnalyzeButton(provider),

                      const SizedBox(height: 28),

                      // Loading state
                      if (_isProcessing(provider)) ...[
                        _buildLoadingState(provider),
                        const SizedBox(height: 40),
                      ],

                      // Error state
                      if (provider.state == AnalysisState.error) ...[
                        _buildErrorCard(provider),
                        const SizedBox(height: 20),
                      ],

                      // Results
                      if (provider.hasResult) ...[
                        _buildResults(provider),
                      ],

                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── App Bar ─────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF10B981)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.psychology_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'AI Resume Analyzer',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEAF2FF), Color(0xFFF4F8FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // Decorative background dots
              Positioned(
                right: 30,
                top: 20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2563EB).withOpacity(0.12),
                  ),
                ),
              ),
              Positioned(
                right: 60,
                top: 50,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF10B981).withOpacity(0.12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Consumer<ResumeProvider>(
          builder: (context, provider, _) => provider.hasResult
              ? IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B)),
                  tooltip: 'Reset',
                  onPressed: () => provider.reset(),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ─── Analyze Button ───────────────────────────────────────────

  Widget _buildAnalyzeButton(ResumeProvider provider) {
    final isReady = provider.selectedFileName != null && !provider.isLoading;

    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      child: SizedBox(
        width: double.infinity,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: isReady
                ? const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  )
                : null,
            color: isReady ? null : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(14),
            boxShadow: isReady
                ? [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    )
                  ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: isReady ? () => provider.pickAndAnalyze() : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: provider.isLoading
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Analyzing...',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.analytics_rounded,
                              color: isReady ? Colors.white : const Color(0xFF64748B),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              provider.selectedFileName != null
                                  ? 'Re-analyze Resume'
                                  : 'Select a PDF first',
                              style: TextStyle(
                                color: isReady ? Colors.white : const Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Loading State ────────────────────────────────────────────

  bool _isProcessing(ResumeProvider provider) {
    return provider.state == AnalysisState.loadingPdf ||
        provider.state == AnalysisState.analyzing;
  }

  Widget _buildLoadingState(ResumeProvider provider) {
    final message = provider.state == AnalysisState.loadingPdf
        ? 'Extracting text from PDF...'
        : 'Running ATS analysis...';

    return Column(
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Color(0xFF2563EB)),
          strokeWidth: 3,
        ),
        const SizedBox(height: 16),
        Text(
          message,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
      ],
    );
  }

  // ─── Error State ──────────────────────────────────────────────

  Widget _buildErrorCard(ResumeProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B6B).withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFF6B6B).withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFFF6B6B), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              provider.errorMessage ?? 'An error occurred.',
              style: const TextStyle(
                color: Color(0xFFB91C1C),
                fontSize: 13.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Results ──────────────────────────────────────────────────

  Widget _buildResults(ResumeProvider provider) {
    final result = provider.result!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Divider with label
        Row(
          children: [
            Expanded(child: Divider(color: const Color(0xFF94A3B8).withOpacity(0.25))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Analysis Results',
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ),
            Expanded(child: Divider(color: const Color(0xFF94A3B8).withOpacity(0.25))),
          ],
        ),
        const SizedBox(height: 28),

        // Animated score circle
        ScoreCircle(score: result.atsScore),
        const SizedBox(height: 32),

        // Detected sections chips
        if (result.detectedSections.isNotEmpty) ...[
          ResultCard(
            title: 'Detected Sections',
            icon: Icons.view_module_rounded,
            accentColor: const Color(0xFF0EA5E9),
            items: result.detectedSections,
            useChips: true,
          ),
        ],

        // Matched keywords
        if (result.matchedKeywords.isNotEmpty) ...[
          ResultCard(
            title: 'Matched Keywords (${result.matchedKeywords.length})',
            icon: Icons.key_rounded,
            accentColor: const Color(0xFF2563EB),
            items: result.matchedKeywords,
            useChips: true,
          ),
        ],

        // Strengths
        ResultCard(
          title: 'Strengths',
          icon: Icons.thumb_up_alt_rounded,
          accentColor: const Color(0xFF00C896),
          items: result.strengths,
        ),

        // Weaknesses
        ResultCard(
          title: 'Weaknesses',
          icon: Icons.warning_amber_rounded,
          accentColor: const Color(0xFFFF6B6B),
          items: result.weaknesses,
        ),

        // Suggestions
        ResultCard(
          title: 'Suggestions',
          icon: Icons.tips_and_updates_rounded,
          accentColor: const Color(0xFFFFB347),
          items: result.suggestions,
        ),

        // AI Insights card
        AiInsightsCard(
          result: result,
          isLoading: provider.isAiLoading,
        ),
      ],
    );
  }
}
