import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nitwixt/services/database/database.dart';
import 'fetch_preview.dart';

class LinkPreview extends StatelessWidget {
  String link;
  FetchPreview _fetchPreview = FetchPreview();

  LinkPreview({
    @required this.link,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Preview>(
      future: this._fetchPreview.fetch(this.link),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) {
          Preview preview = snapshot.data;
          print('\n\n\n\n');
          print('favIcon ${preview.favIcon}, appelIcon ${preview.appleIcon}');
          return Container(
            child: Stack(
              children: <Widget>[
                DatabaseFiles.imageFromUrl(preview.imageUrl),
                Column(
                  children: <Widget>[
                    Text(preview.title, style: TextStyle(color: Colors.red)),
                    Text(preview.description, style: TextStyle(color: Colors.blue)),
//                    DatabaseFiles.imageFromUrl(preview.favIcon),
                  ],
                ),
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
