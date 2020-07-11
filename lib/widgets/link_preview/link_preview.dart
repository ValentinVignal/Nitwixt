import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nitwixt/services/database/database.dart';
import 'fetch_preview.dart';

class LinkPreview extends StatelessWidget {
  String link;

  LinkPreview({
    @required this.link,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Preview>(
      future: Preview.fetchPreview(this.link),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError && snapshot.hasData && snapshot.data.isNotEmpty) {
          Preview preview = snapshot.data;
          return Container(
            child: Stack(
              children: <Widget>[
                DatabaseFiles.imageFromUrl(preview.imageUrl),
//                Column(
//                  mainAxisAlignment: MainAxisAlignment.end,
//                  children: <Widget>[
//
//                    preview.hasTitle ? Text(preview.title, style: TextStyle(color: Colors.red)) : SizedBox.shrink(),
//                    preview.hasDescription ? Text(preview.description, style: TextStyle(color: Colors.blue)) : SizedBox.shrink(),
//                    preview.hasAppleIcon ? DatabaseFiles.imageFromUrl(preview.appleIcon) : SizedBox.shrink(),
//                    preview.hasFavIcon ? DatabaseFiles.imageFromUrl(preview.favIcon) : SizedBox.shrink(),
////                    DatabaseFiles.imageFromUrl(preview.favIcon),
//                  ],
//                ),
                Container(
                  alignment: Alignment.bottomLeft,
                  child: RichText(
                    text: TextSpan(children: <TextSpan>[
                      TextSpan(
                        text: preview.hasTitle ? preview.title + ' ' : '',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: preview.hasDescription ? preview.description : '',
                      ),
                    ]),
                  ),
                )
              ],
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
