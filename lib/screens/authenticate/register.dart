import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:textwit/services/auth.dart';
import 'package:textwit/shared/loading.dart';
import 'package:slider_button/slider_button.dart';
import 'package:flutter_password_strength/flutter_password_strength.dart';

import '../../shared/constants.dart';

class Register extends StatefulWidget {
  final Function toggleView;

  Register({this.toggleView});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthEmailPassword _auth = AuthEmailPassword();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool _passwordVisible1 = false;
  bool _passwordVisible2 = false;

  // text field state
  String email = '';
  String _password1 = '';
  String _password2 = '';
  String error = '';

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white70,
      body: SingleChildScrollView(
        child: SizedBox(
          height: height,
          child: Container(
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
                    'Register to Textwit',
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
                    initialValue: _password1,
                    decoration: textInputDecoration.copyWith(
                      hintText: 'Password',
                      suffixIcon: Listener(
                        child: Icon(
                          _passwordVisible1 ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPointerDown: (_) {
                          setState(() {
                            _passwordVisible1 = true;
                          });
                        },
                        onPointerUp: (_) {
                          setState(() {
                            _passwordVisible1 = false;
                          });
                        },
                      ),
                    ),
                    validator: (val) {
                      if (val.isEmpty) {
                        return 'Enter a password';
                      } else if (val.length < 8) {
                        return 'Password should be at least 8 caracters';
                      }
                      return null;
                    },
                    obscureText: !_passwordVisible1,
                    onChanged: (val) {
                      setState(() => _password1 = val);
                    },
                  ),
                  SizedBox(height: 10.0,),
                  FlutterPasswordStrength(
                    password: _password1,
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    initialValue: _password2,
                    decoration: textInputDecoration.copyWith(
                      hintText: 'Confirm password',
                      suffixIcon: Listener(
                        child: Icon(
                          _passwordVisible2 ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPointerDown: (_) {
                          setState(() {
                            _passwordVisible2 = true;
                          });
                        },
                        onPointerUp: (_) {
                          setState(() {
                            _passwordVisible2 = false;
                          });
                        },
                      ),
                    ),
                    validator: (val) {
                      if (val.isEmpty) {
                        return 'Enter a password';
                      } else if (val != _password1) {
                        return 'The passwords are different';
                      }
                      return null;
                    },
                    obscureText: !_passwordVisible2,
                    onChanged: (val) {
                      setState(() => _password2 = val);
                    },
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  loading ? Loading() : Container(),
                  Spacer(),
                  SliderButton(
                    label: Text(
                      'Register',
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
                        dynamic result = await _auth.registerEmailPassword(email, _password1);
                        if (result == null) {
                          setState(() {
                            error = 'Please supply a valid email';
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
                  Text(
                    error,
                    style: TextStyle(color: Colors.red, fontSize: 14.0),
                  ),
                  RaisedButton.icon(
                    onPressed: () {
                      widget.toggleView();
                    },
                    icon: Icon(
                      Icons.account_circle,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Sign in',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.blue,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
