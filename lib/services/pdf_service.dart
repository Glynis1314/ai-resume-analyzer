import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Service responsible for picking PDF files and extracting text from them.
class PdfService {
  /// Opens the system file picker filtered to PDF files only.
  /// Returns the selected [File] or null if cancelled.
  Future<File?> pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result == null || result.files.single.path == null) return null;
    return File(result.files.single.path!);
  }

  /// Extracts all readable text from the given PDF [file].
  /// Throws a [PdfException] if the file cannot be parsed.
  Future<String> extractText(File file) async {
    final bytes = await file.readAsBytes();
    final document = PdfDocument(inputBytes: bytes);

    try {
      final extractor = PdfTextExtractor(document);
      final text = extractor.extractText();
      return text.trim();
    } finally {
      document.dispose();
    }
  }

  /// Returns just the file name from a [File].
  String getFileName(File file) => file.path.split(Platform.pathSeparator).last;
}
