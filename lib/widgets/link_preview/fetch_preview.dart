import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';

class Preview {
  Preview({
    this.title = '',
    this.description = '',
    this.imageUrl = '',
    this.appleIcon = '',
    this.favIcon = '',
    this.link = '',
  });

  String title;
  String description;
  String imageUrl;
  String appleIcon;
  String favIcon;
  String link;

  static final RegExp regExpLink = RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');


  static bool _isEmpty(String str) {
    return str == null || str.isEmpty;
  }

  bool get hasTitle {
    return !_isEmpty(title);
  }

  bool get hasDescription {
    return !_isEmpty(description);
  }

  bool get hasImageUrl {
    return !_isEmpty(imageUrl);
  }

  bool get hasAppleIcon {
    return !_isEmpty(appleIcon);
  }

  bool get hasFavIcon {
    return !_isEmpty(favIcon);
  }

  bool get isEmpty {
    return !hasTitle && !hasDescription && !hasImageUrl && !hasAppleIcon && !hasFavIcon;
  }

  bool get isNotEmpty {
    return !isEmpty;
  }

  static Future<Preview> fetchPreview(String url) async {
    final Client client = Client();
    final Response response = await client.get(_validateUrl(url));
    final Document document = parse(response.body);

    String description, title, image, appleIcon, favIcon;

    final List<Element> elements = document.getElementsByTagName('meta');
    final List<Element> linkElements = document.getElementsByTagName('link');

    elements.forEach((Element tmp) {
      if (tmp.attributes['property'] == 'og:title') {
        //fetch seo title
        title = tmp.attributes['content'];
      }
      //if seo title is empty then fetch normal title
      if (title == null || title.isEmpty) {
        title = document.getElementsByTagName('title')[0].text;
      }

      //fetch seo description
      if (tmp.attributes['property'] == 'og:description') {
        description = tmp.attributes['content'];
      }
      //if seo description is empty then fetch normal description.
      if (description == null || description.isEmpty) {
        //fetch base title
        if (tmp.attributes['name'] == 'description') {
          description = tmp.attributes['content'];
        }
      }

      //fetch image
      if (tmp.attributes['property'] == 'og:image') {
        image = tmp.attributes['content'];
      }
    });

    linkElements.forEach((tmp) {
      if (tmp.attributes['rel'] == 'apple-touch-icon') {
        appleIcon = tmp.attributes['href'];
      }
      if (tmp.attributes['rel']?.contains('icon') == true) {
        favIcon = tmp.attributes['href'];
      }
    });

    return Preview(
      title: title,
      description: description,
      imageUrl: image,
      appleIcon: appleIcon,
      favIcon: favIcon,
      link: url,
    );
  }

  static String _validateUrl(String url) {
    if (url?.startsWith('http://') == true || url?.startsWith('https://') == true) {
      return url;
    } else {
      return 'http://$url';
    }
  }

  static String getFirstLink(String str) {
    final List<RegExpMatch> matches = regExpLink.allMatches(str).toList();
    String linkToPreview;
    if (matches.isNotEmpty) {
      return str.substring(matches[0].start, matches[0].end);
    } else {
      return '';
    }
  }




}
