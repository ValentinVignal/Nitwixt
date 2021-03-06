import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/services/auth/auth.dart' as auth;
import 'package:nitwixt/widgets/widgets.dart';
import 'package:nitwixt/widgets/widgets.dart' as widgets;

class VerifyEmail extends StatefulWidget {
  @override
  _VerifyEmailState createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  TextStyle textStyle = const TextStyle(
    fontSize: 20.0,
  );

  String buttonMessage = 'Send email';
  bool result;
  bool isProcessing = false;
  bool isEmailSent = false;

  final auth.AuthService _auth = auth.AuthService();

  @override
  Widget build(BuildContext context) {
    final models.UserAuth userAuth = Provider.of<models.UserAuth>(context);

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[800],
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => _auth.signOut(),
        ),
        title: const Text('Verify your email'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 50.0),
            Text(
              'To use Nitwixt, you must verify you email address.\n\nPress the button to send a confirmation email to:\n\n${userAuth.email}',
              style: textStyle.copyWith(color: Colors.grey[300]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 30.0,
            ),
            widgets.ButtonSimple(
              onTap: () async {
                setState(() {
                  isProcessing = true;
                  result = null;
                });
                final bool res =await auth.AuthEmailPassword().sendConfirmationEmail();
                setState(() {
                  isProcessing = false;
                });
                if (res) {
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
            const SizedBox(
              height: 20.0,
            ),
            if (result) Text(
                    'An email has been sent',
                    style: textStyle.copyWith(color: Colors.green),
                    textAlign: TextAlign.center,
                  ) ,
            if (result) const Icon(
                    Icons.check,
                    color: Colors.green,
                  ),
            if (!result) Text('We couldn\'t send an email...', style: textStyle.copyWith(color: Colors.red)),
            if (!result) const Icon(
                    Icons.clear,
                    color: Colors.red,
                  ),
            const SizedBox(
              height: 20.0,
            ),
            if (isEmailSent) widgets.ButtonSimple(
                    onTap: () => _auth.signOut(),
                    color: Colors.green,
                    text: 'I have verified my email',
                    icon: Icons.done,
                  ),
            SizedBox(
              height: isEmailSent ? 20.0 : 0.0,
            ),
            if (isProcessing) LoadingCircle(),
          ],
        ),
      ),
    );
  }
}
