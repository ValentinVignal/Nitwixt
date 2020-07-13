import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:nitwixt/widgets/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nitwixt/shortcuts/shortcuts.dart' as shortcuts;

class MessageTile extends StatefulWidget {
  models.Message message;
  DateFormat format = DateFormat('HH:mm - d MMM');
  DateTime date;
  void Function(models.Message message) onLongPress;
  void Function(models.Message message) reactButtonOnTap;
  void Function(models.Message message) onAnswerDrag;

  MessageTile({
    @required this.message,
    this.onLongPress,
    this.reactButtonOnTap,
    this.onAnswerDrag,
  }) {
    date = message.date.toDate();
  }

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  bool _showInfo = false;
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<models.User>(context);
    final membersMap = Provider.of<Map<String, models.User>>(context);
    final chat = Provider.of<models.Chat>(context);
    final bool isOnlyEmojis = shortcuts.TextParser.hasOnlyEmoji(widget.message.text.trim().trimLeft());

    bool isMyMessage = user.id == widget.message.userid;

    Widget nameContainer = isMyMessage || membersMap.length <= 2
        ? Container(
            height: 0.0,
          )
        : Container(
            padding: EdgeInsets.only(left: 5.0),
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

    Widget dateContainer = Container(
      padding: EdgeInsets.only(
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

    Widget addReactButton = Container(
      alignment: Alignment.topCenter,
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
//          print('button pressed');
        },
        padding: EdgeInsets.all(2.0),
        constraints: BoxConstraints(
          maxHeight: 24.0,
        ),
//        alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      ),
    );

    Widget reacts = widget.message.reacts.isEmpty
        ? SizedBox(
            height: 0.0,
            width: 0.0,
          )
        : Container(
            child: Text(
              '${widget.message.reacts.reactList().join()} ${widget.message.reacts.length}',
              style: TextStyle(color: Colors.white),
            ),
          );

    Widget textWidget = Flexible(
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
        child: isOnlyEmojis
            ? Container(
                child: Text(
                  widget.message.text,
                  style: TextStyle(color: Colors.white, fontSize: 50.0),
                ),
              )
            : Container(
                padding: EdgeInsets.only(top: 7.0, bottom: 7.0, right: 8.0, left: 8.0),
                decoration: BoxDecoration(
                  color: isMyMessage ? Colors.grey[800] : Colors.black,
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      20.0,
                    ),
                  ),
                ),
                child: MarkdownBody(
                  data: widget.message.text,
                  selectable: false,
                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
                  onTapLink: (String url) => LinkPreview.launchUrl(context: context, url: url),
                ),
              ),
      ),
    );

    Widget messageAnswered = widget.message.previousMessageId.isNotEmpty
        ? FutureBuilder<models.Message>(
            future: widget.message.answersToMessage(chat.id),
            builder: (BuildContext context, AsyncSnapshot<models.Message> snapshot) {
              Widget content;

              if (snapshot.connectionState == ConnectionState.waiting) {
                content = LoadingDots(
                  color: Colors.grey,
                  fontSize: 13.0,
                );
              } else {
                if (snapshot.hasError) {
                  print('could not find the message ${widget.message.previousMessageId} in chat ${chat.id}');
                  content = SizedBox.shrink();
                } else {
                  content = Text(
                    snapshot.data.text.replaceAll('\n', ' '),
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  );
                }
              }
              return Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: isMyMessage ? 40.0 : 0,
                  ),
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
                      decoration: BoxDecoration(
                        color: Color(0xFF151515),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        ),
                      ),
                      child: content,
                    ),
                  ),
                ],
              );
            },
          )
        : SizedBox.shrink();

    List<Widget> messageActions = [
      IconSlideAction(
        caption: 'Reply',
        color: Color(0x00000000),
        icon: Icons.reply,
        foregroundColor: Colors.grey,
        onTap: () => widget.onAnswerDrag(widget.message),
      ),
    ];

    Widget profilePicture = isMyMessage || membersMap.length <= 2
        ? SizedBox.shrink()
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: UserPicture(
              user: membersMap[widget.message.userid],
            ),
          );

    RegExp regExpLink = new RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
    List<RegExpMatch> matches = regExpLink.allMatches(widget.message.text).toList();
    String linkToPreview;
    if (matches.isNotEmpty) {
      linkToPreview = widget.message.text.substring(matches[0].start, matches[0].end);
    }

    Widget preview = linkToPreview == null
        ? SizedBox.shrink()
        : Flexible(
            fit: FlexFit.tight,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(
                    20.0,
                  ),
                ),
              ),
              child: LinkPreview(
                link: linkToPreview,
              ),
            ),
          );

    // * --------------------------------------------------
    // * --------------------------------------------------
    // * --------------------------------------------------

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Container(
        margin: EdgeInsets.all(2.0),
        child: Column(
          crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            nameContainer,
            messageAnswered,
            Slidable(
              actionPane: SlidableStrechActionPane(),
              actions: messageActions,
              secondaryActions: messageActions,
              actionExtentRatio: 0.1,
              child: SizedBox(
                width: double.maxFinite,
                child: Align(
                  alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          profilePicture,
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                              children: <Widget>[
                                isMyMessage
                                    ? addReactButton
                                    : SizedBox(
                                        width: 0.0,
                                      ),
                                textWidget,
                                isMyMessage
                                    ? SizedBox(
                                        width: 0.0,
                                      )
                                    : addReactButton,
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            width: isMyMessage ? 40.0 : 0.0,
                          ),
                          reacts,
                          SizedBox(
                            width: isMyMessage ? 0.0 : 40.0,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(width: isMyMessage ? 40.0 : 0.0),
                preview,
                SizedBox(width: isMyMessage ? 0.0 : 40.0),
              ],
            ),
            _showInfo ? dateContainer : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
