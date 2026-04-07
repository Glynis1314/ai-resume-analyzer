import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/resume_result.dart';

/// Card displaying AI-powered insights from the Gemini API.
/// Shows a shimmer-style loading state while waiting for the AI response.
class AiInsightsCard extends StatelessWidget {
  final ResumeResult? result;
  final bool isLoading;

  const AiInsightsCard({
    super.key,
    this.result,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show if AI is disabled and no result yet
    if (!AppConfig.isAiEnabled && result?.aiSummary == null) {
      return _buildDisabledCard();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF5F3FF), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF7C3AED).withOpacity(0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF7C3AED).withOpacity(0.3),
                    const Color(0xFF7C3AED).withOpacity(0.05),
                  ],
                ),
                border: const Border(
                  left: BorderSide(color: Color(0xFF7C3AED), width: 3),
                ),
              ),
              child: Row(
                children: [
                  _buildGeminiIcon(),
                  const SizedBox(width: 10),
                  const Text(
                    'AI Insights',
                    style: TextStyle(
                      color: Color(0xFF6D28D9),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Gemini',
                      style: TextStyle(
                        color: Color(0xFF6D28D9),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Color(0xFF7C3AED)),
                      ),
                    ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: isLoading ? _buildShimmer() : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeminiIcon() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
    );
  }

  Widget _buildContent() {
    final aiSummary = result?.aiSummary;
    final jobFitScore = result?.aiJobFitScore;
    final aiSuggestions = result?.aiSuggestions ?? [];

    if (aiSummary == null && !isLoading) {
      return const Text(
        'AI analysis not available.',
        style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Job Fit Score badge
        if (jobFitScore != null) ...[
          Row(
            children: [
              const Text(
                'Job Fit Score',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$jobFitScore / 100',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],

        // Summary
        if (aiSummary != null) ...[
          const Text(
            'Summary',
            style: TextStyle(
              color: Color(0xFF6D28D9),
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            aiSummary,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 13.5,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // AI Suggestions
        if (aiSuggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6D28D9).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF6D28D9).withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb, color: Color(0xFF6D28D9), size: 16),
                    SizedBox(width: 8),
                    Text(
                      'How to Improve Your Resume',
                      style: TextStyle(
                        color: Color(0xFF6D28D9),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...aiSuggestions.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final suggestion = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6D28D9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              '$idx',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            suggestion,
                            style: const TextStyle(
                              color: Color(0xFF334155),
                              fontSize: 13,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _shimmerBar(0.4),
        const SizedBox(height: 10),
        _shimmerBar(1.0),
        const SizedBox(height: 6),
        _shimmerBar(0.85),
        const SizedBox(height: 6),
        _shimmerBar(0.7),
        const SizedBox(height: 16),
        _shimmerBar(0.3),
        const SizedBox(height: 8),
        _shimmerBar(0.9),
        const SizedBox(height: 6),
        _shimmerBar(0.75),
      ],
    );
  }

  Widget _shimmerBar(double widthFactor) {
    return LayoutBuilder(builder: (context, constraints) {
      return _ShimmerWidget(
        child: Container(
          width: constraints.maxWidth * widthFactor,
          height: 12,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      );
    });
  }

  Widget _buildDisabledCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Color(0xFF94A3B8), size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'AI Insights (Disabled)',
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Add your Gemini API key in lib/config/app_config.dart to enable AI analysis.',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple shimmer animation widget.
class _ShimmerWidget extends StatefulWidget {
  final Widget child;
  const _ShimmerWidget({required this.child});

  @override
  State<_ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<_ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.8).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, child) => Opacity(opacity: _animation.value, child: child),
      child: widget.child,
    );
  }
}
