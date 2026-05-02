import 'package:pdf/pdf.dart';            // ✅ for PdfColor
// ✅ for UI widgets

PdfColor getPdfColor(String status) {
  switch (status) {
    case "P":
      return PdfColors.green200;
    case "L":
      return PdfColors.orange200;
    case "AB":
      return PdfColors.red200;
    default:
      return PdfColors.white;
  }
}