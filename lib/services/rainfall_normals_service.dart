import 'dart:convert';

import 'package:flutter/services.dart';

class RainfallNormalsService {
  static const String _assetPath = 'lib/constants/rainfall_normals.json';
  static const List<String> _monthKeys = <String>[
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];

  static Map<String, dynamic>? _cached;

  static Future<Map<String, dynamic>> getNormalsForLocation({
    required String state,
    required String district,
  }) async {
    final root = await _loadRoot();
    final rows = (root['data'] as List?) ?? const <dynamic>[];

    final districtNorm = _normalize(district);
    final stateNorm = _normalize(state);

    List<dynamic> districtMatches =
        rows.where((row) {
          if (row is! List || row.length < 15) return false;
          final rowState = _normalize(row[0]?.toString() ?? '');
          final rowDistrict = _normalize(row[1]?.toString() ?? '');
          return rowState == stateNorm && rowDistrict == districtNorm;
        }).toList();

    if (districtMatches.isEmpty) {
      districtMatches =
          rows.where((row) {
            if (row is! List || row.length < 15) return false;
            final rowState = _normalize(row[0]?.toString() ?? '');
            final rowDistrict = _normalize(row[1]?.toString() ?? '');
            return rowState == stateNorm && rowDistrict.contains(districtNorm);
          }).toList();
    }

    dynamic selected;
    if (districtMatches.isNotEmpty) {
      selected = districtMatches.first;
    } else {
      final stateMatches =
          rows.where((row) {
            if (row is! List || row.length < 15) return false;
            final rowState = _normalize(row[0]?.toString() ?? '');
            return rowState == stateNorm;
          }).toList();

      if (stateMatches.isNotEmpty) {
        selected = _averageRows(stateMatches);
      }
    }

    if (selected == null) {
      return {
        'source': 'rainfall_normals',
        'matched_state': state,
        'matched_district': district,
        'match_level': 'none',
        'monthly_mm': _emptyMonthly(),
        'annual_mm': 0.0,
      };
    }

    final asList = selected is List ? selected : <dynamic>[];
    final monthly = <String, double>{};
    for (var i = 0; i < _monthKeys.length; i++) {
      monthly[_monthKeys[i]] = _toDouble(asList[i + 2]);
    }

    final annual = _toDouble(asList[14]);

    return {
      'source': 'rainfall_normals',
      'matched_state': asList.isNotEmpty ? asList[0] : state,
      'matched_district': asList.length > 1 ? asList[1] : district,
      'match_level': districtMatches.isNotEmpty ? 'district' : 'state_average',
      'monthly_mm': monthly,
      'annual_mm': annual,
    };
  }

  static String _normalize(String raw) {
    return raw
        .toUpperCase()
        .replaceAll('&', 'AND')
        .replaceAll(RegExp(r'[^A-Z0-9 ]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static Future<Map<String, dynamic>> _loadRoot() async {
    if (_cached != null) return _cached!;
    final raw = await rootBundle.loadString(_assetPath);
    _cached = jsonDecode(raw) as Map<String, dynamic>;
    return _cached!;
  }

  static List<dynamic> _averageRows(List<dynamic> rows) {
    final avg = List<dynamic>.filled(19, 0.0);
    avg[0] = rows.first[0];
    avg[1] = 'STATE_AVG';

    for (var idx = 2; idx <= 18; idx++) {
      double sum = 0;
      for (final row in rows) {
        if (row is! List || row.length <= idx) continue;
        sum += _toDouble(row[idx]);
      }
      avg[idx] = rows.isEmpty ? 0.0 : (sum / rows.length);
    }
    return avg;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim()) ?? 0.0;
    return 0.0;
  }

  static Map<String, double> _emptyMonthly() {
    return <String, double>{for (final m in _monthKeys) m: 0.0};
  }
}
