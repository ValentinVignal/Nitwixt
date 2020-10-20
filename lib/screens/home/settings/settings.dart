import 'package:flutter/material.dart';
import 'package:nitwixt/widgets/link_preview/link_preview.dart';
import 'package:package_info/package_info.dart';
import 'package:new_version/new_version.dart';
import 'package:nitwixt/widgets/forms/text_info.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  PackageInfo _packageInfo;

  @override
  void initState() {
    super.initState();
  }

  Future<PackageInfo> getPackageInfo() async {
    _packageInfo ??= await PackageInfo.fromPlatform();
    return _packageInfo;
  }

  Widget getNewVersionWidget(BuildContext context) {
    final NewVersion newVersion = NewVersion(androidId: 'com.valentinvignal.nitwixt', context: context);
    return FutureBuilder<VersionStatus>(
      future: newVersion.getVersionStatus(),
      builder: (BuildContext context, AsyncSnapshot<VersionStatus> snapshot) {
        String message = '';
        IconData icon;
        Color iconColor;
        void Function() onTap;
        final List<InlineSpan> spans = <InlineSpan>[];
        if (!snapshot.hasError && snapshot.hasData) {
          final VersionStatus versionStatus = snapshot.data;
          if (versionStatus.canUpdate) {
            message = 'Nitwixt ${versionStatus.storeVersion} is available  ';
            icon = Icons.warning_outlined;
            iconColor = Colors.orange;
            onTap = () {
              LinkPreview.launchUrl(
                context: context,
                url: versionStatus.appStoreLink,
              );
            };
          } else {
            message = 'Your app is up to date  ';
            icon = Icons.check;
            iconColor = Colors.green;
          }
        }
        spans.add(TextSpan(
          text: message,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ));
        if (icon != null) {
          spans.add(WidgetSpan(
            child: Icon(
              icon,
              color: iconColor,
              size: 17,
            ),
          ));
        }
        return GestureDetector(
          onTap: onTap,
          child: RichText(
            text: TextSpan(children: spans),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget versionWidget = FutureBuilder<PackageInfo>(
      future: getPackageInfo(),
      builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
        String version = '';
        if (!snapshot.hasError && snapshot.hasData) {
          version = snapshot.data.version;
        }
        return TextInfo(
          title: 'Version',
          value: version,
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 50.0,
        ),
        children: <Widget>[
          versionWidget,
          const SizedBox(
            height: 2.0,
          ),
          Center(
            // padding: const EdgeInsets.only(left: 0),
            child: getNewVersionWidget(context),
          ),
        ],
      ),
    );
  }
}
