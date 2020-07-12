import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nitwixt/services/database/database.dart';
import 'fetch_preview.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkPreview extends StatelessWidget {
  String link;
  int maxLineDescription;
  double maxHeight;

  LinkPreview({
    @required this.link,
    this.maxLineDescription = 3,
    this.maxHeight=100.0,
  }) : super();

  static void launchUrl({BuildContext context, String url}) {
    showDialog<void>(
      context: context,
      barrierDismissible: true, // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Do you want to launch this url ?'),
          content: Text(url),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss alert dialog
              },
            ),
            FlatButton(
              child: Text('Launch'),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Dismiss alert dialog
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  print('Could not launch url $url');
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrl(context: context, url: this.link),
      child: FutureBuilder<Preview>(
        future: Preview.fetchPreview(this.link),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError && snapshot.hasData && snapshot.data.isNotEmpty) {
            Preview preview = snapshot.data;
            return Container(
              constraints: preview.hasImageUrl ? BoxConstraints(
                maxHeight: 100.0,
              ) : null,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(
                  Radius.circular(
                    20.0,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  preview.hasImageUrl ? Container(
                    child: DatabaseFiles.imageFromUrl(preview.imageUrl),
                  ) : SizedBox.shrink(),
                  SizedBox(width: 5.0),
                  Flexible(
                    child: Container(
                      alignment: Alignment.topLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          preview.hasTitle
                              ? Text(
                                  preview.title,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )
                              : SizedBox.shrink(),
                          Text(
                            link,
                            style: TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                          preview.hasDescription
                              ? Text(
                                  preview.description,
                                  style: TextStyle(color: Colors.grey),
                                  maxLines: this.maxLineDescription,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : SizedBox.shrink(),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }
}
