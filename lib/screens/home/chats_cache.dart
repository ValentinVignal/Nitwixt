import 'package:flutter/material.dart';

import 'package:nitwixt/models/models.dart' as models;

class ChatsCache {
  ChatsCache();

  Map<String, models.Chat> chats = <String, models.Chat>{};
  Map<String, Widget> widgets = <String, Widget>{};

  bool get isEmpty => chats.isEmpty;

  bool get isNotEmpty => chats.isNotEmpty;

  void addChat(models.Chat chat, Widget widget) {
    if (!chats.containsKey(chat.id) || !chats[chat.id].equals(chat)) {
      chats[chat.id] = chat.copy();
      widgets[chat.id] = widget;
    }
  }

  void addChatList(List<models.Chat> chatList, List<Widget> widgetList) {
    for (int i = 0; i < chatList.length; i++) {
      addChat(chatList[i], widgetList[i]);
    }
  }

  List<models.Chat> get chatList {
    final List<models.Chat> list = chats.values.toList();
    list.sort((models.Chat chat1, models.Chat chat2) {
      return chat1.id.compareTo(chat2.id);
    });
    return list;
  }

  void empty() {
    chats = <String, models.Chat>{};
    widgets = <String, Widget>{};
  }
}

