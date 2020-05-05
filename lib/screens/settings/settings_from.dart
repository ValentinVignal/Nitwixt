import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:textwit/models/user.dart';
import 'package:textwit/services/database.dart';
import 'package:textwit/shared/constants.dart';
import 'package:textwit/shared/loading.dart';

class SettingsForm extends StatefulWidget {
  @override
  _SettingsFormState createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String> sugars = ['0', '1', '2', '3', '4'];

  // form values
  String _currentName;
  String _currentSugars;
  int _currentStrength;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserAuth>(context);

    return StreamBuilder<UserData>(
        stream: DatabaseUserData(uid: user.id).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {

            UserData userData = snapshot.data;

            return Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Text(
                    'Update your brew settings',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    initialValue: userData.name,
                    decoration: textInputDecoration,
                    validator: (val) => val.isEmpty ? 'Please enter a name' : null,
                    onChanged: (val) => setState(() => _currentName = val),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  // dropdown
                  DropdownButtonFormField(
                    decoration: textInputDecoration,
                    items: sugars.map((sugar) {
                      return DropdownMenuItem(
                        value: sugar,
                        child: Text('$sugar sugars'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _currentSugars = val),
                    value: _currentSugars ?? userData.sugars,
                  ),
                  // slider
                  Slider(
                    value: (_currentStrength ?? userData.strength).toDouble(),
                    activeColor: Colors.green[_currentStrength ?? userData.strength],
                    inactiveColor: Colors.green[_currentStrength ?? userData.strength],
                    min: 100.0,
                    max: 900.0,
                    divisions: 8,
                    onChanged: (val) => setState(() => _currentStrength = val.round()),
                  ),
                  RaisedButton(
                    color: Colors.pink[400],
                    child: Text('Update', style: TextStyle(color: Colors.white)),
                    onPressed: () async {
                      if(_formKey.currentState.validate()) {
                        await DatabaseUserData(uid: user.id).updateUserData(
                          _currentSugars ?? userData.sugars,
                          _currentName ?? userData.name,
                          _currentStrength ?? userData.strength,
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            );
          } else {
            return Loading();
          }
        });
  }
}
