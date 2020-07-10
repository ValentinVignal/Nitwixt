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
          return DatabaseFiles.imageFromUrl(snapshot.data.imageUrl);
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
