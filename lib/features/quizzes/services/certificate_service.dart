import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class CertificateService {
  Future<Uint8List> generateCertificate({
    required String userName,
    required String quizTitle,
    required int score,
    required int total,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blue, width: 4),
            ),
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  "Certificat de Réussite",
                  style: pw.TextStyle(
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  "Ce certificat est décerné à",
                  style: pw.TextStyle(fontSize: 18),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  userName,
                  style: pw.TextStyle(
                    fontSize: 26,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  "Pour avoir complété le quiz : $quizTitle",
                  style: pw.TextStyle(fontSize: 16),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  "Score obtenu : $score / $total",
                  style: pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 30),
                pw.Text(
                  "Félicitations 🎉",
                  style: pw.TextStyle(fontSize: 20, color: PdfColors.green800),
                ),
                pw.Spacer(),
                pw.Text(
                  "Date : ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                  style: pw.TextStyle(fontSize: 14),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}
