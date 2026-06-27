import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class PdfService {
  static const String companyName = 'BK COLLECTION';
  static const String companyAddress = '123 Fashion Street, Mumbai - 400001';
  static const String companyPhone = '+91 98765 43210';

  static Future<void> generateBill({
    required String billNumber,
    required String customerName,
    required DateTime date,
    required List<Map<String, dynamic>> items, // name, qty, price
    required double total,
    required double paid,
    required double pending,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        build: (context) => [
          pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Column(
              children: [
                pw.Text(companyName,
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(companyAddress,
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                pw.Text(companyPhone,
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                pw.SizedBox(height: 10),
                pw.Divider(),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Bill No: $billNumber',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Date: ${_formatDate(date)}',
                      style: pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Customer: $customerName',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: pw.FlexColumnWidth(3),
              1: pw.FlexColumnWidth(1),
              2: pw.FlexColumnWidth(1),
              3: pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Item', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Price', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                ],
              ),
              for (var item in items)
                pw.TableRow(
                  children: [
                    pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(item['name'])),
                    pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(item['qty'].toString(), textAlign: pw.TextAlign.center)),
                    pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Rs.${item['price'].toStringAsFixed(2)}', textAlign: pw.TextAlign.right)),
                    pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Rs.${(item['price'] * item['qty']).toStringAsFixed(2)}', textAlign: pw.TextAlign.right)),
                  ],
                ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Container(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Total: Rs.${total.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text('Paid: Rs.${paid.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontSize: 12)),
                pw.Text('Pending: Rs.${pending.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontSize: 12,
                        color: pending > 0 ? PdfColors.red : PdfColors.green)),
              ],
            ),
          ),
          pw.SizedBox(height: 30),
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text('Thank you for shopping with BK COLLECTION',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/bill_$billNumber.pdf');
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}