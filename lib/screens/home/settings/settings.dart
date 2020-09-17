import 'package:flutter/material.dart';
import 'package:nitwixt/widgets/forms/text_info.dart';
import 'package:package_info/package_info.dart';

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
        ],
      ),
    );
  }
}
