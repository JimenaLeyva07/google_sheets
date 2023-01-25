import 'dart:math';

import 'package:googleapis/sheets/v4.dart';

class GoogleSheetHelpers {
  static Map<String, String> wrap(List<String> keys, List<String> values) {
    return mapKeysToValues(keys, values, (_, val) => val ?? '');
  }

  static Map<String, V> mapKeysToValues<V>(
    List<String> keys,
    List<String> values,
    V Function(int index, dynamic value) wrap,
  ) {
    final map = <String, V>{};
    var index = 0;
    var length = values.length;
    for (final key in keys) {
      map[key] =
          index < length ? wrap(index, values[index]) : wrap(index, null);
      index++;
    }
    return map;
  }

  static T? get<T>(List<T> list, {int at = 0, T? or}) =>
      list.length > at ? list[at] : or;

  static List<Map<String, String>> getDataFormated(
    ValueRange getData, {
    int fromRow = 1,
    int fromColumn = 1,
    int length = -1,
    int count = -1,
    int mapTo = 1,
  }) {
    Map<String, dynamic> mapData = getData.toJson();
    List<List<String>> rows = [];

    for (var element in mapData["values"]) {
      rows.add(List<String>.from(element));
    }

    final maps = <Map<String, String>>[];
    final keys = rows.first;
    final start = min(fromRow - 1, rows.length);
    final end = count < 1 ? rows.length : min(start + count, rows.length);
    for (var i = start; i < end; i++) {
      if (i != mapTo - 1) {
        maps.add(GoogleSheetHelpers.wrap(keys, rows[i]));
      }
    }
    return maps;
  }
}
