import 'dart:convert';

import 'package:flutter_emoji/flutter_emoji.dart';

class TextParser {
  static final EmojiParser _emojiParser = EmojiParser();
  static final RegExp _onlyEmojiRegexp = RegExp(r'^(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])*$');
  static final SmileyParser _smileyParser = SmileyParser();

  static String parse(String text) {
    text = SmileyParser.smileyfy(text);
    text = _emojiParser.emojify(text);
    text = text.replaceAll('️', '');

    return text;
  }

  static bool hasOnlyEmoji(String text) {
    return _onlyEmojiRegexp.hasMatch(text);
  }
}

class SmileyParser {
  static final Map<String, String> _smileyMap = {
    'blush': r':\)',
    'stuck_out_tongue': r':p',
    'smiley': r':D',
    'satisfied': r'x(D|\))',
    'persevere': r'x\(',
    'confounded': r'x\$',
    'flushed': r'O_o',
    'wink': r';\)',
    'stuck_out_tongue_winking_eye': r';p',
    'stuck_out_tongue_closed_eyes': r'xP',
    'open_mouth': r':o',
    'confused': r':\/',
    'expressionless': r'(-_-|-.-)',
    'kissing_heart': r':\*',
    'sweat_smile': r"\^\^\'",
    'grin': r'\^\^',
    'disappointed': r":\(",
    'cry': r":\'\(",
    'sob': r"T_T",
    'angry': r">:\(",
    'innocent': r'O:\)',
    'smiling_imp': r"3:\)",
    'sunglasses': r'B\)',
    'heart': r'<3',
    'grimacing': r':\$',
    'sleeping': r':z',
    'scream': r':O',
    'smiley_cat': r':3',
    'broken_heart': r'<(\\|\/)3',

  };

  static String smileyfy(String text) {
    _smileyMap.forEach((String key, String value) {
      text = text.replaceAll(RegExp(r'((^| )' + value + r'($| ))'), ' :$key: ');
    });
    return text;
  }
}