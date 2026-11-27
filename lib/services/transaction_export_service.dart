// ignore_for_file: require_trailing_commas

import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;

import '../ui/views/transactions/transactions_viewmodel.dart';

class TransactionExportService {
  const TransactionExportService();

  String buildCsv(List<TransactionListItem> items) {
    final rows = <List<String>>[
      ['Date', 'Type', 'Amount', 'Currency', 'Account', 'Category', 'Tags', 'Note'],
      for (final item in items)
        [
          item.transaction.transactionDate.toIso8601String().split('T').first,
          item.transaction.transactionType,
          (item.transaction.amountMinorUnits / 100).toStringAsFixed(2),
          item.transaction.currencyCode,
          item.accountName,
          item.categoryName ?? '',
          item.tagNames.join(', '),
          item.transaction.note ?? '',
        ],
    ];
    return '\uFEFF${rows.map((row) => row.map(_escapeCsv).join(',')).join('\r\n')}';
  }

  Future<Uint8List> buildPdf(List<TransactionListItem> items) async {
    final document = pw.Document();
    document.addPage(pw.MultiPage(build: (context) => [
      pw.Header(level: 0, child: pw.Text('Transaction report')),
      pw.Text('Generated: ${DateTime.now().toIso8601String().split('T').first}'),
      pw.SizedBox(height: 12),
      pw.TableHelper.fromTextArray(
        headers: ['Date', 'Type', 'Amount', 'Account', 'Category', 'Note'],
        data: [
          for (final item in items)
            [
              item.transaction.transactionDate.toIso8601String().split('T').first,
              item.transaction.transactionType,
              '${item.transaction.currencyCode} ${(item.transaction.amountMinorUnits / 100).toStringAsFixed(2)}',
              item.accountName,
              item.categoryName ?? '',
              item.transaction.note ?? '',
            ],
        ],
        headerStyle: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
        cellStyle: const pw.TextStyle(fontSize: 8),
        cellPadding: const pw.EdgeInsets.all(4),
      ),
      if (items.isEmpty) pw.Text('No transactions match the selected filters.'),
    ]));
    return document.save();
  }

  String _escapeCsv(String value) {
    final safe = RegExp(r'^[=+@-]').hasMatch(value) ? "'$value" : value;
    return '"${safe.replaceAll('"', '""')}"';
  }
}