bool listEquals(List<dynamic> list1, List<dynamic> list2) {
  if (identical(list1, list2)) {
    return true;
  }
  if (list1 == null || list2 == null) {
      return false;
  }
  final int length = list1.length;
  if (length != list2.length) {
    return false;
  }
  for (int index=0; index<length; index++)  {
    if (list1[index] != list2[index]) {
      return false;
    }
  }
  return true;
}