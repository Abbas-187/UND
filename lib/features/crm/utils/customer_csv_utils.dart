import 'dart:convert';
import '../models/customer.dart';

class CustomerCsvUtils {
  static String exportToCsv(List<Customer> customers) {
    final headers = [
      'id',
      'name',
      'email',
      'phone',
      'address',
      'createdAt',
      'updatedAt',
      'tags'
    ];
    final rows = customers.map((c) => [
          c.id,
          c.name,
          c.email,
          c.phone,
          c.address,
          c.createdAt.toIso8601String(),
          c.updatedAt?.toIso8601String() ?? '',
          c.tags.join('|'),
        ]);
    final csv = StringBuffer();
    csv.writeln(headers.join(','));
    for (final row in rows) {
      csv.writeln(
          row.map((e) => '"${e.toString().replaceAll('"', '""')}"').join(','));
    }
    return csv.toString();
  }

  static List<Customer> importFromCsv(String csvContent) {
    final lines = LineSplitter.split(csvContent).toList();
    if (lines.length < 2) return [];
    final headers = lines[0].split(',');
    return lines.skip(1).where((line) => line.trim().isNotEmpty).map((line) {
      final values = _parseCsvLine(line);
      return Customer(
        id: values[0],
        name: values[1],
        email: values[2],
        phone: values[3],
        address: values[4],
        createdAt: DateTime.parse(values[5]),
        updatedAt: values[6].isNotEmpty ? DateTime.parse(values[6]) : null,
        tags: values[7].isNotEmpty ? values[7].split('|') : [],
      );
    }).toList();
  }

  static List<String> _parseCsvLine(String line) {
    final regex = RegExp(r'"([^"]*)"|([^,]+)');
    final matches = regex.allMatches(line);
    return matches.map((m) => m.group(1) ?? m.group(2) ?? '').toList();
  }
}
