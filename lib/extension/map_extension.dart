typedef FromString<T> = T Function(String);

typedef FromJson<T> = T Function(Map<String, dynamic>);

extension MapExtension on Map {
  bool get isEmptyFast => length < 1;

  bool get isNotEmptyFast => length > 0;

  int gInt(String key, [int def = 0]) {
    var value = this[key];
    if (value == null) {
      return def;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value) ?? def;
  }

  double gDouble(String key, [double def = 0]) {
    var value = this[key];
    if (value == null) {
      return def;
    }

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value) ?? def;
  }

  String gString(String key, [String def = '']) {
    var value = this[key];
    if (value == null) {
      return def;
    }

    if (value is String) {
      if (value.isEmpty) {
        return def;
      }

      return value;
    }

    return value.toString();
  }

  bool gBool(String key, [bool def = false]) {
    var value = this[key];
    if (value == null) {
      return def;
    }

    if (value is bool) {
      return value;
    }

    return bool.tryParse(value, caseSensitive: false) ?? def;
  }

  List<dynamic> gList(String key, [List<dynamic> def = const []]) {
    var value = this[key];
    if (value == null) {
      return def;
    }

    if (value is List<dynamic>) {
      return value;
    }

    return def;
  }

  List<T> gListObject<T>(String key, FromJson<T> fromJson) {
    return gList(key)
        .where((e) => e != null && e is Map<String, dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .map(fromJson)
        .toList();
  }

  List<String> gListString(String key) {
    return gList(key).where((e) => e != null).map((e) => e.toString()).toList();
  }

  Map<String, dynamic> gMap(String key, [Map<String, dynamic> def = const {}]) {
    var value = this[key];
    if (value == null) {
      return def;
    }

    if (value is Map<String, dynamic>) {
      return value;
    }

    return def;
  }

  Map<String, String> gMapString(
    String key, [
    Map<String, String> def = const {},
  ]) {
    Map<String, dynamic> map = gMap(key);
    if (map.isEmptyFast) {
      return def;
    }

    Map<String, String> result = {};
    for (MapEntry<String, dynamic> entry in map.entries) {
      if (entry.value == null) {
        continue;
      }

      result[entry.key] = entry.value.toString();
    }

    if (result.isEmptyFast) {
      return def;
    }

    return result;
  }

  Map<String, T> gMapObject<T>(String key, FromJson<T> fromJson) {
    Map<String, T> result = {};

    Map<String, dynamic> map = gMap(key);
    for (MapEntry<String, dynamic> entry in map.entries) {
      var value = entry.value;
      if (value == null || value is! Map<String, dynamic>) {
        continue;
      }

      result[entry.key] = fromJson(value);
    }

    return result;
  }

  T gObject<T>(String key, FromJson<T> fromJson) => fromJson(gMap(key));

  T gEnum<T>(String key, FromString<T> fromString) => fromString(gString(key));
}
