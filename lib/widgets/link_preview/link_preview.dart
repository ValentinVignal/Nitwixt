import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nitwixt/services/database/database.dart';

import 'fetch_preview.dart';

class LinkPreview extends StatefulWidget {
  LinkPreview({
    this.link,
    this.preview,
    this.maxLineDescription = 3,
    this.maxHeight = 100.0,
  })  : assert((link == null) != (preview == null)),
        super() {
    preview ??= Preview.fetchPreview(link);
  }

  final String link;
  Future<Preview> preview;
  final int maxLineDescription;
  final double maxHeight;

  static void launchUrl({BuildContext context, String url}) {
    showDialog<void>(
      context: context,
      barrierDismissible: true, // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Do you want to launch this url ?'),
          content: Text(url),
          actions: <FlatButton>[
            FlatButton(
              child: const Text('Copy'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: url));
              },
            ),
            FlatButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss alert dialog
              },
            ),
            FlatButton(
              child: const Text('Launch'),
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
  _LinkPreviewState createState() => _LinkPreviewState();
}

class _LinkPreviewState extends State<LinkPreview> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Preview>(
      future: widget.preview,
      builder: (BuildContext context, AsyncSnapshot<Preview> snapshot) {
        if (
            snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError &&
            snapshot.hasData &&
            snapshot.data.isNotEmpty) {
          final Preview preview = snapshot.data;
          return GestureDetector(
            onTap: () => LinkPreview.launchUrl(context: context, url: preview.link),
            child: Container(
              constraints: preview.hasImageUrl
                  ? const BoxConstraints(
                      maxHeight: 100.0,
                    )
                  : null,
              decoration: const BoxDecoration(
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
                  if (preview.hasImageUrl)
                    Container(
                      child: DatabaseFiles.imageFromUrl(preview.imageUrl),
                    ),
                  const SizedBox(width: 5.0),
                  Flexible(
                    child: Container(
                      alignment: Alignment.topLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (preview.hasTitle)
                            Text(
                              preview.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          Text(
                            preview.link,
                            style: const TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (preview.hasDescription)
                            Text(
                              preview.description,
                              style: const TextStyle(color: Colors.grey),
                              maxLines: widget.maxLineDescription,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
