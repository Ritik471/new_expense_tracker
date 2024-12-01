import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart'; 
import '../../models/database_provider.dart';
import '../../models/expense.dart';
import 'package:permission_handler/permission_handler.dart'; 

class PdfScreen extends StatefulWidget {
  const PdfScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PdfScreenState createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  String? previewPath; 
  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();
    _generatePdfPreview(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Export'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading) ...[
              const Center(child: CircularProgressIndicator()),
            ] else if (previewPath != null) ...[
              const Text('PDF Preview:', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0), 
                  child: PDFView(
                    filePath: previewPath!, 
                  ),
                ),
              ),
            ] else ...[
              const Center(child: Text('No PDF generated yet')),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _generateAndSavePdf(context); 
              },
              child: const Text('Generate and Save PDF'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generatePdfPreview(BuildContext context) async {
    try {
      final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
      final List<Expense> expenses = await dbProvider.fetchAllExpenses();

      final pdf = pw.Document();

      final pw.TextStyle regularTextStyle = pw.TextStyle(
        font: pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf')),
      );
      final pw.TextStyle boldTextStyle = pw.TextStyle(
        font: pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Bold.ttf')),
      );

      final List<pw.TableRow> expenseRows = [
        pw.TableRow(
          children: [
            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Text('Title', style: boldTextStyle.copyWith(fontSize: 14.0)),
            ),
            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Text('Amount', style: boldTextStyle.copyWith(fontSize: 14.0)),
            ),
            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Text('Date', style: boldTextStyle.copyWith(fontSize: 14.0)),
            ),
            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Text('Category', style: boldTextStyle.copyWith(fontSize: 14.0)),
            ),
          ],
        ),
        for (var expense in expenses) ...[
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(expense.title, style: regularTextStyle.copyWith(fontSize: 12.0)),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(expense.amount.toString(), style: regularTextStyle.copyWith(fontSize: 12.0)),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(expense.date.toString(), style: regularTextStyle.copyWith(fontSize: 12.0)),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(expense.category, style: regularTextStyle.copyWith(fontSize: 12.0)),
              ),
            ],
          ),
        ],
      ];

      final DateTime now = DateTime.now();
      final String formattedDate = DateFormat('dd-MM-yyyy').format(now);

      // Add widgets to a list
      List<pw.Widget> pdfContent = [
        pw.Text('Expense Report', style: boldTextStyle.copyWith(fontSize: 16.0)),
        pw.Table(
          border: pw.TableBorder.all(),
          children: expenseRows,
        ),
        pw.SizedBox(height: 10),
        pw.Text('Date Printed: $formattedDate', style: const pw.TextStyle(fontSize: 10)),
      ];

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Padding(
            padding: const pw.EdgeInsets.all(16.0), 
            child: pw.Column(
              children: pdfContent,
            ),
          ),
        ),
      );

      final bytes = await pdf.save();
      final directory = await getApplicationDocumentsDirectory(); 
      final file = File('${directory.path}/preview_expenses_report.pdf');
      await file.writeAsBytes(bytes);

      setState(() {
        previewPath = file.path; 
        _isLoading = false; 
      });
    } catch (e) {
      print('Error generating PDF preview: $e');
      setState(() {
        _isLoading = false; 
      });
    }
  }

  Future<void> _generateAndSavePdf(BuildContext context) async {
    try {
      final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
      final List<Expense> expenses = await dbProvider.fetchAllExpenses();

      final pdf = pw.Document();

      final pw.TextStyle regularTextStyle = pw.TextStyle(
        font: pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf')),
      );
      final pw.TextStyle boldTextStyle = pw.TextStyle(
        font: pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Bold.ttf')),
      );

      final List<pw.TableRow> expenseRows = [
        pw.TableRow(
          children: [
            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Text('Title', style: boldTextStyle.copyWith(fontSize: 14.0)),
            ),
            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Text('Amount', style: boldTextStyle.copyWith(fontSize: 14.0)),
            ),
            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Text('Date', style: boldTextStyle.copyWith(fontSize: 14.0)),
            ),
            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Text('Category', style: boldTextStyle.copyWith(fontSize: 14.0)),
            ),
          ],
        ),
        for (var expense in expenses) ...[
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(expense.title, style: regularTextStyle.copyWith(fontSize: 12.0)),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(expense.amount.toString(), style: regularTextStyle.copyWith(fontSize: 12.0)),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(expense.date.toString(), style: regularTextStyle.copyWith(fontSize: 12.0)),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(expense.category, style: regularTextStyle.copyWith(fontSize: 12.0)),
              ),
            ],
          ),
        ],
      ];

      final DateTime now = DateTime.now();
      final String formattedDate = DateFormat('dd-MM-yyyy').format(now);

      List<pw.Widget> pdfContent = [
        pw.Text('Expense Report', style: boldTextStyle.copyWith(fontSize: 16.0)),
        pw.Table(
          border: pw.TableBorder.all(),
          children: expenseRows,
        ),
        pw.SizedBox(height: 10),
        pw.Text('Date Printed: $formattedDate', style: const pw.TextStyle(fontSize: 10)),
      ];

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Padding(
            padding: const pw.EdgeInsets.all(16.0),
            child: pw.Column(children: pdfContent),
          ),
        ),
      );

      final bytes = await pdf.save();

      // Request storage permission
      if (await _requestPermission(Permission.storage)) {
        // Let user pick directory to save the file
        String? outputDir = await FilePicker.platform.getDirectoryPath();

        if (outputDir != null) {
          final file = File('$outputDir/expenses_report.pdf');
          await file.writeAsBytes(bytes);

          // Show success dialog
          _showSuccessDialog(context, 'PDF Saved', 'Expenses report PDF saved to $outputDir.');
        }
      }
    } catch (e) {
      print('Error generating PDF: $e');
    }
  }

  // Function to request storage permission
  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      final result = await permission.request();
      return result == PermissionStatus.granted;
    }
  }

  // Show success dialog
  void _showSuccessDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
