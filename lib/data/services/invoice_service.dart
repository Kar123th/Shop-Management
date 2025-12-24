import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shop_management_app/data/models/sale_model.dart';

class InvoiceService {
  static Future<void> generateAndShareInvoice(Sale sale) async {
    final pdf = pw.Document();
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(sale.createdAt);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TAX INVOICE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Jaikrishna Traders', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Bill To: ${sale.customerName ?? "Counter Sale"}'),
                      if (sale.customerPhone != null) pw.Text('Phone: ${sale.customerPhone}'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Invoice #: ${sale.id.substring(0, 8).toUpperCase()}'),
                      pw.Text('Date: $dateStr'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                border: pw.TableBorder.all(),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                headerHeight: 25,
                cellHeight: 20,
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1),
                },
                headers: ['Product', 'Qty', 'Rate', 'Total'],
                data: sale.items.map((item) => [
                  item.productName,
                  item.quantity.toString(),
                  '₹${item.unitPrice.toStringAsFixed(2)}',
                  '₹${item.total.toStringAsFixed(2)}',
                ]).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Subtotal: ₹${sale.subTotal.toStringAsFixed(2)}'),
                      pw.Text('Tax (GST): ₹${sale.taxAmount.toStringAsFixed(2)}'),
                      pw.Divider(),
                      pw.Text('Total Amount: ₹${sale.totalAmount.toStringAsFixed(2)}',
                          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Center(child: pw.Text('Thank you for your business!')),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'invoice_${sale.id.substring(0, 8)}.pdf');
  }
}
