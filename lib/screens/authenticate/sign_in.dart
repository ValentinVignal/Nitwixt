import 'package:flutter/material.dart';
import 'package:nitwixt/services/auth/auth.dart';
import 'package:slider_button/slider_button.dart';

import 'package:nitwixt/shared/constants.dart';
import 'package:nitwixt/shared/loading.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;

  SignIn({this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthEmailPassword _authEmailPassword = AuthEmailPassword();
  final AuthGoogle _authGoogle = AuthGoogle();
  final AuthFacebook _authFacebook = AuthFacebook();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool _passwordVisible = false;

  // text filed state
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
//      backgroundColor: Colors.black12,
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
                      'Nitwixt',
                      style: TextStyle(color: Colors.blueAccent, fontSize: 25.0),
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
                      decoration: textInputDecoration.copyWith(
                        hintText: 'Password',
                        suffixIcon: Listener(
                          child: Icon(
                            _passwordVisible ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPointerDown: (_) {
                            setState(() {
                              _passwordVisible = true;
                            });
                          },
                          onPointerUp: (_) {
                            setState(() {
                              _passwordVisible = false;
                            });
                          },
                        ),
                      ),
                      validator: (val) => val.isEmpty ? 'Enter a password' : null,
                      obscureText: !_passwordVisible,
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
                    SizedBox(height: 12.0),
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
                          dynamic result = await _authEmailPassword.signInEmailPassword(email, password);
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
                      height: 20.0,
                    ),
                    Text(
                      'Sign in with',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () async {
                            setState(() => loading = true);
                            dynamic result = await _authGoogle.signInWithGoogle();
                            if (result == null) {
                              setState(() {
                                error = 'Could not sign in with google';
                                loading = false;
                              });
                            }
                          },
                          child: Image(
                            image: AssetImage('assets/images/google_logo.png'),
                            height: 35.0,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            setState(() => loading = true);
                            dynamic result = await _authFacebook.signInWithFacebook();
                            if (result == null) {
                              setState(() {
                                error = 'Could not sign in with Facebook';
                                loading = false;
                              });
                            }
                          },
                          child: Image(
                            image: AssetImage('assets/images/facebook_logo.png'),
                            height: 35.0,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        widget.toggleView();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 5.0,
                          horizontal: 20.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0,
                          ),
                        ),
                        child: Text(
                          'Register',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
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
