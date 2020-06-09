import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/services/auth/auth.dart' as auth;
import 'package:nitwixt/shared/loading.dart';
import 'package:nitwixt/widgets/widgets.dart' as widgets;

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
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[800],
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
            SizedBox(height: 50.0),
            Text(
              'To use Nitwixt, you must verify you email address.\n\nPress the button to send a confirmation email to:\n\n${userAuth.email}',
              style: textStyle.copyWith(color: Colors.grey[300]),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 30.0,
            ),
            widgets.ButtonSimple(
              onTap: () async {
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
              text: buttonMessage,
              color: Colors.cyan[200],
              icon: Icons.email,
            ),
//            GestureDetector(
//              onTap: () async {
//                setState(() {
//                  isProcessing = true;
//                  result = null;
//                });
//                Object res = await auth.AuthEmailPassword().sendConfirmationEmail();
//                setState(() {
//                  isProcessing = false;
//                });
//                if (res == null) {
//                  // Everything is fine
//                  setState(() {
//                    buttonMessage = 'Send email again';
//                    result = true;
//                    isEmailSent = true;
//                  });
//                } else {
//                  setState(() {
//                    buttonMessage = 'Try again';
//                    result = false;
//                  });
//                }
//              },
//              child: Container(
//                padding: EdgeInsets.symmetric(
//                  vertical: 5.0,
//                  horizontal: 10.0,
//                ),
//                decoration: BoxDecoration(
//                  borderRadius: BorderRadius.circular(20),
//                  border: Border.all(
//                    color: Colors.cyan[200],
//                    width: 2.0,
//                  ),
//                ),
//                child: Row(
//                  mainAxisSize: MainAxisSize.min,
//                  mainAxisAlignment: MainAxisAlignment.center,
//                  children: <Widget>[
//                    Icon(
//                      Icons.email,
//                      color: Colors.cyan[200],
//                    ),
//                    SizedBox(
//                      width: 5.0,
//                    ),
//                    Text(
//                      buttonMessage,
//                      style: TextStyle(color: Colors.cyan[200], fontSize: 18),
//                    ),
//                  ],
//                ),
//              ),
//            ),
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
                ? GestureDetector(
                    onTap: () => _auth.signOut(),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 5.0,
                        horizontal: 10.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.green,
                          width: 2.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.done,
                            color: Colors.green,
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          Text(
                            'I have verified my email',
                            style: TextStyle(color: Colors.green, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
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
