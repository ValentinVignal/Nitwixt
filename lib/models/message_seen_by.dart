import 'package:cloud_firestore/cloud_firestore.dart';

class MessageSeenBy {
  MessageSeenBy({
    this.seenByMap,
  }) {
    seenByMap ??= <String, Timestamp>{};
  }

  MessageSeenBy.fromFirebaseObject(Map<String, dynamic> firebaseObject) {
    seenByMap = firebaseObject == null ? <String, Timestamp>{} : Map<String, Timestamp>.from(firebaseObject);
  }

  Map<String, Timestamp> seenByMap;

  Map<String, Object> toFirebaseObject() {
    return seenByMap;
  }

  bool containsKey(String userId) => seenByMap.containsKey(userId);

  Timestamp operator [](String userId) => seenByMap[userId];

  void operator []=(String userId, Timestamp date) => seenByMap[userId] = date;

  bool get isEmpty => seenByMap.isEmpty;

  bool get isNotEmpty => seenByMap.isNotEmpty;

  List<String> get keys => seenByMap.keys.toList();

  bool isReadBy(String userId) => seenByMap.containsKey(userId);

  bool isNotReadBy(String userId) => !isReadBy(userId);
}
