import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:nitwixt/widgets/widgets.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/src/shortcuts/shortcuts.dart' as shortcuts;
import 'package:nitwixt/screens/home/chat/message/react_dialog.dart';

import 'delete_dialog.dart';

class MessageTile extends StatefulWidget {
  MessageTile({
    @required this.message,
    this.onLongPress,
    this.reactButtonOnTap,
    this.onAnswer,
    this.onEdit,
  }) {
    date = message.date.toDate();
  }

  final models.Message message;
  final DateFormat format = DateFormat('HH:mm - d MMM');
  DateTime date;
  final void Function(models.Message message) onLongPress;
  final void Function(models.Message message) reactButtonOnTap;
  final void Function(models.Message message) onAnswer;
  final void Function(models.Message message) onEdit;

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  bool _showInfo = false;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _deleteMessage() {
    showDialog<DeleteDialog>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext buildContext) {
          return DeleteDialog(
            chatId: widget.message.chatid,
            messageId: widget.message.id,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final models.User user = Provider.of<models.User>(context);
    final Map<String, models.User> membersMap = Provider.of<Map<String, models.User>>(context);
    final bool isOnlyEmojis = shortcuts.TextParser.hasOnlyEmoji(widget.message.text.trim().trimLeft());

    final bool isMyMessage = user.id == widget.message.userid;

    final Widget nameContainer = isMyMessage || membersMap.length <= 2
        ? Container(
            height: 0.0,
          )
        : Container(
            padding: const EdgeInsets.only(left: 5.0),
            alignment: Alignment.bottomLeft,
            height: 15.0,
            child: Text(
              membersMap[widget.message.userid].name,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12.0,
              ),
            ),
          );

    final Widget dateContainer = Container(
      padding: const EdgeInsets.only(
        left: 5.0,
        right: 5.0,
        top: 0.0,
        bottom: 1.0,
      ),
      alignment: isMyMessage ? Alignment.bottomRight : Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Text(
          widget.format.format(widget.date).toString(),
          style: TextStyle(color: Colors.grey[600], fontSize: 11.0),
        ),
      ),
    );

    final Widget addReactButton = Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: isMyMessage ? 15.0 : 0.0, right: isMyMessage ? 0.0 : 15.0),
      child: IconButton(
        icon: Icon(
          Icons.insert_emoticon,
          color: Colors.grey[700],
        ),
        onPressed: () {
          if (widget.reactButtonOnTap != null) {
            widget.reactButtonOnTap(widget.message);
          }
        },
        padding: const EdgeInsets.all(2.0),
        constraints: const BoxConstraints(
          maxHeight: 24.0,
        ),
//        alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      ),
    );

    final Widget reacts = widget.message.reacts.isEmpty
        ? const SizedBox.shrink()
        : GestureDetector(
            onTap: () => ReactsDialog.showReactsDialog(
              context: context,
              message: widget.message,
              membersMap: membersMap,
            ),
            child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                '${widget.message.reacts.reactList().join()} ${widget.message.reacts.length}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );

    final Widget imageWidget = widget.message.images.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: FutureBuilder<String>(
              future: widget.message.imageUrl(),
              builder: (BuildContext buildContext, AsyncSnapshot<String> asyncSnapshot) {
                if (asyncSnapshot.connectionState == ConnectionState.done &&
                    !asyncSnapshot.hasError &&
                    asyncSnapshot.hasData &&
                    asyncSnapshot.data.isNotEmpty) {
                  return Image.network(
                    asyncSnapshot.data,
                    width: 200.0,
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          )
        : const SizedBox.shrink();

    Color colorContainerText = const Color(0x00000000);
    if (widget.message.text.isNotEmpty) {
      colorContainerText = isMyMessage ? Colors.grey[800] : Colors.black;
    }

    final Widget textWidget = Flexible(
      child: GestureDetector(
        onLongPress: () {
          if (widget.onLongPress != null) {
            widget.onLongPress(widget.message);
          }
        },
        onTap: () {
          setState(() {
            _showInfo = !_showInfo;
          });
        },
        child: isOnlyEmojis && widget.message.images.isEmpty
            ? Container(
                child: Text(
                  widget.message.text,
                  style: const TextStyle(color: Colors.white, fontSize: 50.0),
                ),
              )
            : Container(
                padding: const EdgeInsets.only(top: 7.0, bottom: 7.0, right: 8.0, left: 8.0),
                decoration: BoxDecoration(
                  color: colorContainerText,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(
                      20.0,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    MarkdownBody(
                      data: widget.message.text,
                      selectable: false,
                      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
                      onTapLink: (String url) => LinkPreview.launchUrl(context: context, url: url),
                    ),
//                    imageWidget,
                  ],
                ),
              ),
      ),
    );

    final Widget messageAnswered = widget.message.previousMessageId.isEmpty
        ? const SizedBox.shrink()
        : FutureBuilder<models.Message>(
            future: widget.message.previousMessage,
            builder: (BuildContext context, AsyncSnapshot<models.Message> snapshot) {
              Widget content;
              if (snapshot.connectionState == ConnectionState.waiting) {
                content = LoadingDots(
                  color: Colors.grey,
                  fontSize: 13.0,
                );
              } else {
                if (snapshot.hasError || snapshot.data == null) {
                  return const SizedBox.shrink();
                } else {
                  content = Text(
                    snapshot.data.text.replaceAll('\n', ' '),
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.left,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  );
                }
              }
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
                decoration: const BoxDecoration(
                  color: Color(0xFF151515),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  ),
                ),
                child: content,
              );
            },
          );

    final List<IconSlideAction> messageActions = <IconSlideAction>[
      if (widget.onAnswer != null)
        IconSlideAction(
          caption: 'Reply',
          color: const Color(0x00000000),
          icon: Icons.reply,
          foregroundColor: Colors.grey,
          onTap: () => widget.onAnswer(widget.message),
        ),
      if (widget.message.text != null && widget.message.text.isNotEmpty)
        IconSlideAction(
          caption: 'Copy',
          color: const Color(0x00000000),
          icon: Icons.content_copy,
          foregroundColor: Colors.grey,
          onTap: () => Clipboard.setData(ClipboardData(text: widget.message.text)),
        ),
    ];
    if (isMyMessage) {
      messageActions.addAll(<IconSlideAction>[
        if (widget.onEdit != null)
          IconSlideAction(
            caption: 'Edit',
            color: const Color(0x00000000),
            icon: Icons.edit,
            foregroundColor: Colors.grey,
            onTap: () => widget.onEdit(widget.message),
          ),
        IconSlideAction(
          caption: 'Delete',
          color: const Color(0x00000000),
          icon: Icons.delete,
          foregroundColor: Colors.grey,
          onTap: _deleteMessage,
        ),
      ]);
    }

    final Widget profilePicture = isMyMessage || membersMap.length <= 2
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: UserPicture(
              user: membersMap[widget.message.userid],
            ),
          );

    final RegExp regExpLink = RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
    final List<RegExpMatch> matches = regExpLink.allMatches(widget.message.text).toList();
    String linkToPreview;
    if (matches.isNotEmpty) {
      linkToPreview = widget.message.text.substring(matches[0].start, matches[0].end);
    }

    final Widget preview = linkToPreview == null
        ? const SizedBox.shrink()
        : Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  20.0,
                ),
              ),
            ),
            child: LinkPreview(
//            link: linkToPreview,
              preview: widget.message.preview,
            ),
          );

    // * --------------------------------------------------
    // * --------------------------------------------------
    // * --------------------------------------------------

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Container(
        margin: const EdgeInsets.all(2.0),
        child: Column(
          crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            nameContainer,
            Slidable(
              actionPane: const SlidableStrechActionPane(),
              actions: messageActions.reversed.toList(),
              secondaryActions: messageActions,
              actionExtentRatio: 0.1,
              child: SizedBox(
                width: double.maxFinite,
                child: Align(
                  alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    // TODO(Valentin): Replace with IntrinsicHeight when it works (solution to center add react button vertically)
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        profilePicture,
                        if (isMyMessage) addReactButton,
                        Flexible(
                          child: IntrinsicWidth(
                            child: Column(
                              crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                messageAnswered,
                                textWidget,
                                preview,
                                imageWidget,
                                reacts,
                              ],
                            ),
                          ),
                        ),
                        if (!isMyMessage) addReactButton,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_showInfo) dateContainer,
          ],
        ),
      ),
    );
  }
}
