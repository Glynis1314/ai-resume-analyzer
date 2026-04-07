import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ResumeScreen(),
    );
  }
}

class ResumeScreen extends StatefulWidget {
  const ResumeScreen({super.key});

  @override
  State<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> {
  String resultText = "Upload a resume to analyze";
  bool isLoading = false;

  // 🧠 IMPROVED ATS LOGIC
  Future<void> analyzeResume(String text) async {
    text = text.toLowerCase();

    int score = 0;

    // 🔑 TECH KEYWORDS
    List<String> keywords = [
      "react", "node", "mongodb", "python", "java",
      "sql", "firebase", "git", "api", "docker"
    ];

    int keywordMatches = 0;
    for (var word in keywords) {
      if (text.contains(word)) keywordMatches++;
    }

    // 📊 SCORING BREAKDOWN
    score += (keywordMatches * 4); // max ~40

    bool hasProjects = text.contains("project");
    bool hasExperience = text.contains("experience");
    bool hasEducation = text.contains("education");
    bool hasSkills = text.contains("skills");

    if (hasProjects) score += 15;
    if (hasExperience) score += 20;
    if (hasEducation) score += 10;
    if (hasSkills) score += 10;

    // 📈 measurable impact
    bool hasNumbers = RegExp(r'\d+%?').hasMatch(text);
    if (hasNumbers) score += 10;

    // 📄 formatting bonus
    if (text.length > 300) score += 5;

    if (score > 100) score = 100;

    // 🟢 STRENGTHS
    String strengths = "";
    if (keywordMatches >= 5) strengths += "✔ Strong technical skills\n";
    if (hasProjects) strengths += "✔ Good project experience\n";
    if (hasExperience) strengths += "✔ Work experience present\n";
    if (hasNumbers) strengths += "✔ Quantified achievements\n";

    // 🔴 WEAKNESSES
    String weaknesses = "";
    if (!hasExperience) weaknesses += "✖ No work experience\n";
    if (keywordMatches < 3) weaknesses += "✖ Low skill keywords\n";
    if (!hasNumbers) weaknesses += "✖ No measurable results\n";
    if (!hasSkills) weaknesses += "✖ Missing skills section\n";

    // 💡 SUGGESTIONS
    String suggestions = "";
    if (!hasExperience) {
      suggestions += "• Add internships or real-world experience\n";
    }
    if (!hasNumbers) {
      suggestions += "• Add metrics (e.g. improved speed by 30%)\n";
    }
    if (keywordMatches < 5) {
      suggestions += "• Add more relevant tech skills\n";
    }
    if (!hasSkills) {
      suggestions += "• Add a dedicated skills section\n";
    }

    setState(() {
      resultText = """
ATS Score: $score

Strengths:
$strengths

Weaknesses:
$weaknesses

Suggestions:
$suggestions
""";
    });
  }

  // 📄 FILE PICKER
  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.single.path != null) {
        String path = result.files.single.path!;

        if (!path.endsWith(".pdf")) {
          setState(() {
            resultText = "Please select a PDF file";
          });
          return;
        }

        setState(() {
          isLoading = true;
        });

        File file = File(path);
        List<int> bytes = await file.readAsBytes();

        PdfDocument document = PdfDocument(inputBytes: bytes);
        String text = PdfTextExtractor(document).extractText();
        document.dispose();

        await analyzeResume(text);

        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          resultText = "No file selected";
        });
      }
    } catch (e) {
      setState(() {
        resultText = "Error: $e";
        isLoading = false;
      });
    }
  }

  // 🎨 UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Resume Analyzer"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickFile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 15),
              ),
              child: const Text("Upload Resume"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(child: buildResultUI()),
            ),
          ],
        ),
      ),
    );
  }

  // 📊 RESULT UI
  Widget buildResultUI() {
    if (!resultText.contains("ATS Score")) {
      return Center(child: Text(resultText));
    }

    final scoreMatch =
        RegExp(r'ATS Score: (\d+)').firstMatch(resultText);
    final score = scoreMatch != null
        ? int.parse(scoreMatch.group(1)!)
        : 0;

    Color scoreColor = Colors.red;
    if (score > 70) scoreColor = Colors.green;
    else if (score > 40) scoreColor = Colors.orange;

    return Column(
      children: [
        // 🎯 SCORE
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 120,
              width: 120,
              child: CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 10,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation(scoreColor),
              ),
            ),
            Text(
              "$score",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: scoreColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        buildSection("Strengths", Colors.green),
        buildSection("Weaknesses", Colors.red),
        buildSection("Suggestions", Colors.orange),
      ],
    );
  }

  Widget buildSection(String title, Color color) {
    final match = RegExp('$title:\\n([\\s\\S]*?)(\\n\\n|\\\$)')
        .firstMatch(resultText);

    String content =
        match != null ? match.group(1)! : "Not available";

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }
}