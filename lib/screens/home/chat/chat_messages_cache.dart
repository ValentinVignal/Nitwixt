import 'package:flutter/material.dart';

import 'package:nitwixt/models/models.dart' as models;

class ChatMessagesCache {
  ChatMessagesCache();

  final Map<String, models.Message> messages = <String, models.Message>{};
  final Map<String, Widget> widgets = <String, Widget>{};

  bool get isEmpty => messages.isEmpty;

  bool get isNotEmpty => messages.isNotEmpty;

  void addMessage(models.Message message, Widget widget) {
    if (!messages.containsKey(message.id) || !messages[message.id].equals(message)) {
      messages[message.id] = message.copy();
      widgets[message.id] = widget;
    }
  }

  void addMessageList(List<models.Message> messageList, List<Widget> widgetList) {
    for (int i = 0; i < messageList.length; i++) {
      addMessage(messageList[i], widgetList[i]);
    }
    _removeOthers(messageList);
  }

  List<models.Message> get messageList {
    final List<models.Message> list = messages.values.toList();
    list.sort((models.Message message1, models.Message message2) {
      return message2.date.compareTo(message1.date);
    });
    return list;
  }

  void _removeOthers(List<models.Message> messageList) {
    final List<String> existingIds = messageList.map<String>((models.Message message) {
      return message.id;
    }).toList();
    messages.removeWhere((String key, models.Message value) => !existingIds.contains(key));
  }
}

