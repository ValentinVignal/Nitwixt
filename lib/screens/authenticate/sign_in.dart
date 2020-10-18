import 'package:flutter/material.dart';
import 'package:nitwixt/models/models.dart';
import 'package:nitwixt/services/auth/auth.dart';
import 'package:slider_button/slider_button.dart';

import 'package:nitwixt/shared/constants.dart';
import 'package:nitwixt/widgets/widgets.dart';
import 'package:nitwixt/widgets/widgets.dart' as widgets;

class SignIn extends StatefulWidget {

  const SignIn({this.toggleView,});

  final Function toggleView;

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthEmailPassword _authEmailPassword = AuthEmailPassword();
  final AuthGoogle _authGoogle = AuthGoogle();
  final AuthFacebook _authFacebook = AuthFacebook();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool _passwordVisible = false;
  final FocusNode focus = FocusNode();


  // text filed state
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
//      backgroundColor: Colors.black12,
      body: Stack(children: <Widget>[
        Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0xFF101040),
                Color(0xFF182050),
                Color(0xFF253060),
                Color(0xFF104070),
              ],
              stops: <double>[0.1, 0.4, 0.7, 0.8],
            ),
          ),
        ),
        SingleChildScrollView(
          child: SizedBox(
            height: height,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 10.0),
                    Image.asset(
                      'assets/images/logo.png',
                      scale: 8.0,
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Nitwixt',
                      style: TextStyle(color: Colors.blueAccent, fontSize: 25.0),
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      initialValue: email,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.emailAddress,
                      decoration: textInputDecoration.copyWith(
                        hintText: 'Email',
                        labelText: 'Email',
                      ),
                      validator: (String val) {
                        if (val.isEmpty) {
                          return 'Enter an email';
                        } else if (!validateEmail(val)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                      onChanged: (String val) {
                        setState(() => email = val);
                      },
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (String val){
                        FocusScope.of(context).requestFocus(focus);
                      },
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      initialValue: password,
                      style: const TextStyle(color: Colors.white),
                      decoration: textInputDecoration.copyWith(
                        hintText: 'Password',
                        labelText: 'Password',
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
                      validator: (String val) => val.isEmpty ? 'Enter a password' : null,
                      obscureText: !_passwordVisible,
                      onChanged: (String val) {
                        setState(() => password = val);
                      },
                      focusNode: focus,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      error,
                      style: const TextStyle(color: Colors.red, fontSize: 14.0),
                    ),
                    if (loading) LoadingCircle(),
                    Expanded(child: Container()),
                    const SizedBox(height: 12.0),
                    SliderButton(
                      label: const Text(
                        'Sign in',
                        style: TextStyle(color: Colors.black),
                      ),
                      icon: const Center(
                        child: Icon(Icons.arrow_forward_ios),
                      ),
                      height: 55.0,
                      buttonSize: 50.0,
                      action: () async {
                        if (_formKey.currentState.validate()) {
                          setState(() => loading = true);
                          final UserAuth result = await _authEmailPassword.signInEmailPassword(email, password);
                          if (result == null) {
                            setState(() {
                              error = 'Email or wrong password';
                              loading = false;
                            });
                          }
                        }
                      },
                      dismissible: false,
                      alignLabel: const Alignment(0.0, 0.0),
                      vibrationFlag: false,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    const Text(
                      'Sign in with',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () async {
                            setState(() => loading = true);
                            final UserAuth result = await _authGoogle.signInWithGoogle();
                            if (result == null) {
                              setState(() {
                                error = 'Could not sign in with google';
                                loading = false;
                              });
                            }
                          },
                          child: const Image(
                            image: AssetImage('assets/images/google_logo.png'),
                            height: 35.0,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            setState(() => loading = true);
                            final UserAuth result = await _authFacebook.signInWithFacebook();
                            if (result == null) {
                              setState(() {
                                error = 'Could not sign in with Facebook';
                                loading = false;
                              });
                            }
                          },
                          child: const Image(
                            image: AssetImage('assets/images/facebook_logo.png'),
                            height: 35.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    widgets.ButtonSimple(
                      onTap: () {
                        widget.toggleView();
                      },
                      text: 'Register',
                      fontSize: 20.0,
                      horizontalPadding: 20.0,
                    ),
                    const SizedBox(
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
