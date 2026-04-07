import 'package:flutter/material.dart';

/// Animated upload zone card with dashed border, file icon, and selected file display.
class UploadZone extends StatefulWidget {
  final String? selectedFileName;
  final VoidCallback onTap;
  final bool isLoading;

  const UploadZone({
    super.key,
    this.selectedFileName,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  State<UploadZone> createState() => _UploadZoneState();
}

class _UploadZoneState extends State<UploadZone>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = widget.selectedFileName != null;
    final accent = hasFile
        ? const Color(0xFF10B981)
        : const Color(0xFF2563EB);

    return GestureDetector(
      onTap: widget.isLoading ? null : widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: accent.withOpacity(hasFile ? 0.6 : 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.08),
              blurRadius: 20,
              spreadRadius: hasFile ? 4 : 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated icon
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) => Transform.scale(
                scale: widget.isLoading ? 1.0 : _pulseAnimation.value,
                child: child,
              ),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.12),
                  border: Border.all(color: accent.withOpacity(0.3)),
                ),
                child: Icon(
                  hasFile ? Icons.picture_as_pdf_rounded : Icons.upload_file_rounded,
                  color: accent,
                  size: 34,
                ),
              ),
            ),
            const SizedBox(height: 18),

            if (hasFile) ...[
              Text(
                widget.selectedFileName!,
                style: const TextStyle(
                  color: Color(0xFF059669),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 6),
              const Text(
                'Tap to change file',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
            ] else ...[
              const Text(
                'Upload Your Resume',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tap to select a PDF file',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13.5),
              ),
              const SizedBox(height: 14),
              // Supported format badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF2563EB).withOpacity(0.3),
                  ),
                ),
                child: const Text(
                  'PDF only',
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
