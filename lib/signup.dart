import 'package:flutter/material.dart';


class SignUp extends StatefulWidget {
  SignUp({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final usernameField = TextField(
        controller: usernameController,
        obscureText: false,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            hintText: "Username",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32.0))
        )
    );
    final passwordField = TextField(
        controller: passwordController,
        obscureText: true,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            hintText: "Password",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32.0))
        )
    );
    final confirmField = TextField(
        controller: confirmController,
        obscureText: true,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            hintText: "Confirm password",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32.0))
        )
    );
    final createButton = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30),
        color: Color(0xff01A0C7),
        child: MaterialButton(
            minWidth: MediaQuery
                .of(context)
                .size
                .width,
            padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            onPressed: () {
              print('Created an account');
              Navigator.pop(context);
            },
            child: Text("Create account",
              textAlign: TextAlign.center,
            )
        )
    );

    final backButton = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30),
        color: Color(0xff01A0C7),
        child: MaterialButton(
            minWidth: MediaQuery
                .of(context)
                .size
                .width,
            padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("<",
              textAlign: TextAlign.center,
            )
        )
    );

    return Scaffold(
        body: Center(
            child: Container(
                color: Colors.white,
                child: Padding(
                    padding: const EdgeInsets.all(36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        backButton,
                        SizedBox(height: 15),
                        usernameField,
                        SizedBox(height: 15),
                        passwordField,
                        SizedBox(height: 15),
                        confirmField,
                        SizedBox(height: 15),
                        createButton
                      ],
                    )
                )
            )
        )
    );
  }
}