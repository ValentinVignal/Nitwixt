import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:textwit/models/models.dart' as models;
import 'package:textwit/services/auth.dart' as auth;
import 'package:textwit/shared/loading.dart';

class VerifyEmail extends StatefulWidget {
  @override
  _VerifyEmailState createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  TextStyle textStyle = TextStyle(
    fontSize: 20.0,
  );

  String buttonMessage = 'Send email';
  bool result;
  bool isProcessing = false;
  bool isEmailSent = false;

  auth.AuthService _auth = auth.AuthService();

  @override
  Widget build(BuildContext context) {
    final models.UserAuth userAuth = Provider.of<models.UserAuth>(context);

    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => _auth.signOut(),
        ),
        title: Text('Verify your email'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50),
        child: Column(
          children: <Widget>[
            SizedBox(height: 100.0),
            Text(
              'To use Textwit, you must verify you email address.\n\nPress the button to send a confirmation email to:\n\n${userAuth.email}',
              style: textStyle.copyWith(color: Colors.blue[900]),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 50.0,
            ),
            RaisedButton.icon(
              onPressed: () async {
                setState(() {
                  isProcessing = true;
                  result = null;
                });
                Object res = await auth.AuthEmailPassword().sendConfirmationEmail();
                setState(() {
                  isProcessing = false;
                });
                if (res == null) {
                  // Everything is fine
                  setState(() {
                    buttonMessage = 'Send email again';
                    result = true;
                    isEmailSent = true;
                  });
                } else {
                  setState(() {
                    buttonMessage = 'Try again';
                    result = false;
                  });
                }
              },
              icon: Icon(Icons.email, color: Colors.white),
              label: Text(buttonMessage, style: TextStyle(color: Colors.white)),
              color: Colors.blue,
            ),
            SizedBox(
              height: 20.0,
            ),
            result == true
                ? Text(
                    'An email has been sent',
                    style: textStyle.copyWith(color: Colors.green),
                    textAlign: TextAlign.center,
                  )
                : Container(
                    height: 0.0,
                  ),
            result == true
                ? Icon(
                    Icons.check,
                    color: Colors.green,
                  )
                : Container(
                    height: 0.0,
                  ),
            result == false
                ? Text('We couldn\'t send an email...', style: textStyle.copyWith(color: Colors.red))
                : Container(
                    height: 0.0,
                  ),
            result == false
                ? Icon(
                    Icons.clear,
                    color: Colors.red,
                  )
                : Container(
                    height: 0.0,
                  ),
            SizedBox(
              height: 20.0,
            ),
            isEmailSent
                ? RaisedButton.icon(
                    onPressed: () => _auth.signOut(),
                    icon: Icon(Icons.done, color: Colors.white),
                    label: Text(
                      'I have verified my email',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.green,
                  )
                : Container(
                    height: 0.0,
                  ),
            SizedBox(
              height: isEmailSent ? 20.0 : 0.0,
            ),
            isProcessing
                ? Loading()
                : Container(
                    height: 0.0,
                  ),
          ],
        ),
      ),
    );
  }
}
