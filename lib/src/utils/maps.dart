bool mapEquals(Map<dynamic, dynamic> map1, Map<dynamic, dynamic> map2) {
  print('map1');
  print(map1);
  print('map2');
  print(map2);
  if (identical(map1, map2)) {
    return true;
  }
  if (map1 == null || map2 ==null) {
    return false;
  }
  final int length = map1.length;
  if (length != map2.length) {
    return false;
  }
  for (final dynamic key in map1.keys) {
    if (!map2.containsKey(key) || map1[key] != map2[key]) {
      return false;
    }
  }
  return true;
}
