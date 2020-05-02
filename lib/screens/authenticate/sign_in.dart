import 'package:flutter/material.dart';
import 'package:textwit/services/auth.dart';
import 'package:slider_button/slider_button.dart';

import 'package:textwit/shared/constants.dart';
import 'package:textwit/shared/loading.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;

  SignIn({this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  // text filed state
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
//      appBar: AppBar(
//        backgroundColor: Colors.blueGrey,
//        elevation: 0.0,
//        title: Text('Sign in to Textwit'),
//        actions: <Widget>[
//          FlatButton.icon(
//            icon: Icon(Icons.person),
//            label: Text('Register'),
//            onPressed: () {
//              widget.toggleView();
//            },
//          ),
//        ],
//      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(height: 10.0),
              Image.asset(
                'assets/images/T.png',
                scale: 10,
              ),
              SizedBox(height: 10.0),
              Text(
                'Textwit',
                style: TextStyle(color: Colors.blue[900], fontSize: 25.0),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                initialValue: email,
                keyboardType: TextInputType.emailAddress,
                decoration: textInputDecoration.copyWith(hintText: 'Email'),
                validator: (val) {
                  if (val.isEmpty) {
                    return 'Enter an email';
                  } else if (!validateEmail(val)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
                onChanged: (val) {
                  setState(() => email = val);
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                initialValue: password,
                decoration: textInputDecoration.copyWith(hintText: 'Password'),
                validator: (val) => val.isEmpty ? 'Enter a password' : null,
                obscureText: true,
                onChanged: (val) {
                  setState(() => password = val);
                },
              ),
              SizedBox(
                height: 20.0,
              ),
              SizedBox(height: 12.0),
              Text(
                error,
                style: TextStyle(color: Colors.red, fontSize: 14.0),
              ),
              loading ? Loading() : Container(),
              Expanded(child: Container()),
              SliderButton(
                label: Text(
                  'Sign in',
                  style: TextStyle(color: Colors.black),
                ),
                icon: Center(
                  child: Icon(Icons.arrow_forward_ios),
                ),
                height: 55.0,
                buttonSize: 50.0,
                action: () async {
                  if (_formKey.currentState.validate()) {
                    setState(() => loading = true);
                    dynamic result = await _auth.signInEmailPassword(email, password);
                    if (result == null) {
                      setState(() {
                        error = 'Email or wrong password';
                        loading = false;
                      });
                    }
                  }
                },
                dismissible: false,
                alignLabel: Alignment(0.0, 0.0),
                vibrationFlag: false,
              ),
              SizedBox(
                height: 10.0,
              ),
              RaisedButton.icon(
                onPressed: () {
                  widget.toggleView();
                },
                icon: Icon(Icons.account_circle, color: Colors.white,),
                label: Text('Register', style: TextStyle(color: Colors.white),),
                color: Colors.blue,
                ),
              SizedBox(
                height: 10.0,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
