import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class CertificateService {
  Future<Uint8List> generateCertificate({
    required String userId,
    required String userName,
    required String quizTitle,
    required int score,
    required int total,
  }) async {
    final pdf = pw.Document();

    final date = DateTime.now();
    final formattedDate =
        "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    final ratio = ((score / total) * 100).toStringAsFixed(1);
    final certNumber = "CERT-${date.year}-$userId-${date.millisecond}";

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [
                  PdfColor.fromInt(0xFFE3F2FD),
                  PdfColor.fromInt(0xFFBBDEFB),
                ],
                begin: pw.Alignment.topLeft,
                end: pw.Alignment.bottomRight,
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Bande supérieure
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(vertical: 20),
                  decoration: pw.BoxDecoration(
                    gradient: pw.LinearGradient(
                      colors: [
                        PdfColor.fromInt(0xFF1976D2),
                        PdfColor.fromInt(0xFF0D47A1),
                      ],
                    ),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      "EduConnect",
                      style: pw.TextStyle(
                        fontSize: 32,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),

                pw.Spacer(flex: 1),

                // Badge doré
                pw.Container(
                  width: 60,
                  height: 60,
                  decoration: pw.BoxDecoration(
                    shape: pw.BoxShape.circle,
                    color: PdfColor.fromInt(0xFFFFD700),
                    boxShadow: [
                      pw.BoxShadow(color: PdfColors.grey600, blurRadius: 4),
                    ],
                  ),
                  child: pw.Center(
                    child: pw.Text("★", style: pw.TextStyle(fontSize: 28)),
                  ),
                ),
                pw.SizedBox(height: 12),

                // Cadre principal
                pw.Container(
                  margin: const pw.EdgeInsets.symmetric(horizontal: 40),
                  padding: const pw.EdgeInsets.all(32),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(20),
                    boxShadow: [
                      pw.BoxShadow(
                        color: PdfColor.fromInt(0x33000000),
                        blurRadius: 8,
                      ),
                    ],
                    border: pw.Border.all(
                      color: PdfColor.fromInt(0xFF1565C0),
                      width: 3,
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        "🏅 Certificat de Réussite",
                        style: pw.TextStyle(
                          fontSize: 28,
                          color: PdfColor.fromInt(0xFF1565C0),
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 16),
                      pw.Text(
                        "Décerné à",
                        style: pw.TextStyle(
                          fontSize: 16,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        userName,
                        style: pw.TextStyle(
                          fontSize: 26,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF0D47A1),
                        ),
                      ),
                      pw.SizedBox(height: 24),
                      pw.Text(
                        "Pour avoir complété avec succès le quiz :",
                        style: pw.TextStyle(
                          fontSize: 16,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        quizTitle,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 18,
                          color: PdfColors.indigo700,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 20),
                      pw.Text(
                        "Score obtenu : $score / $total  •  $ratio%",
                        style: pw.TextStyle(
                          fontSize: 15,
                          color: PdfColors.grey800,
                        ),
                      ),
                      pw.SizedBox(height: 30),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromInt(0xFFFFD54F),
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        child: pw.Text(
                          "Félicitations pour votre réussite sur EduConnect 🎉",
                          style: pw.TextStyle(
                            fontSize: 16,
                            color: PdfColors.brown900,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 40),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                "Date : $formattedDate",
                                style: pw.TextStyle(
                                  fontSize: 13,
                                  color: PdfColors.grey700,
                                ),
                              ),
                              pw.Text(
                                "ID utilisateur : $userId",
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  color: PdfColors.grey600,
                                ),
                              ),
                              pw.Text(
                                "Certificat N° : $certNumber",
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  color: PdfColors.grey500,
                                ),
                              ),
                            ],
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text(
                                "Équipe EduConnect",
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  color: PdfColors.blue900,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Container(
                                width: 120,
                                height: 1,
                                color: PdfColors.blue900,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.Spacer(flex: 2),

                // Bande inférieure
                pw.Container(
                  height: 30,
                  decoration: pw.BoxDecoration(
                    gradient: pw.LinearGradient(
                      colors: [
                        PdfColor.fromInt(0xFF1565C0),
                        PdfColor.fromInt(0xFF0D47A1),
                      ],
                    ),
                  ),
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
