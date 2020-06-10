import 'package:flutter/material.dart';
import 'package:nitwixt/services/auth/auth.dart';
import 'package:nitwixt/shared/loading.dart';
import 'package:slider_button/slider_button.dart';
import 'package:flutter_password_strength/flutter_password_strength.dart';
import 'package:nitwixt/widgets/widgets.dart' as widgets;

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
  final focus1 = FocusNode();
  final focus2 = FocusNode();

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
      body: Stack(children: <Widget>[
        Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF101040),
                Color(0xFF182050),
                Color(0xFF253060),
                Color(0xFF104070),
              ],
              stops: [0.1, 0.4, 0.7, 0.8],
            ),
          ),
        ),
        SingleChildScrollView(
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
                      'assets/images/logo.png',
                      scale: 8.0,
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'Register to Nitwixt',
                      style: TextStyle(color: Colors.blueAccent, fontSize: 25.0),
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      initialValue: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: textInputDecoration.copyWith(
                        hintText: 'Email',
                        labelText: 'Email',
                      ),
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
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (v){
                        FocusScope.of(context).requestFocus(focus1);
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      initialValue: _password1,
                      decoration: textInputDecoration.copyWith(
                        hintText: 'Password',
                        labelText: 'Password',
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
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (v){
                        FocusScope.of(context).requestFocus(focus2);
                      },
                      focusNode: focus1,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    FlutterPasswordStrength(
                      password: _password1,
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      initialValue: _password2,
                      decoration: textInputDecoration.copyWith(
                        hintText: 'Confirm password',
                        labelText: 'Confirm password',
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
                      focusNode: focus2,
                      textInputAction: TextInputAction.done,
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
                    widgets.ButtonSimple(
                      onTap: () {
                        widget.toggleView();
                      },
                      text: 'Sign In',
                      fontSize: 20.0,
                      horizontalPadding: 20.0,
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
      ]),
    );
  }
}
