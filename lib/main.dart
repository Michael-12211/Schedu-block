import 'package:flutter/material.dart';
import 'package:schedu_block/homePage.dart';
import 'package:schedu_block/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

void main() {
  runApp(MaterialApp(
    title: 'Schedu-block',
    home: LoginPage()
  ));
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {

  bool _initialized = false;
  bool _error = false;

  void initializeFlutterFire() async {
    try {
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _error = true;
      });
    }
  }

  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final emailField = TextField(
      controller: emailController,
      obscureText: false,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Email",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
      )
    );
    final passwordField = TextField(
      controller: passwordController,
        obscureText: true,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            hintText: "Password",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
        )
    );
    final loginButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        onPressed: () async {
          print('The user is ${emailController.text} with password ${passwordController.text}');
          try {
            UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: emailController.text,
                password: passwordController.text
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } on FirebaseAuthException catch (e) {
            if (e.code == 'user-not-found') {
              Alert(context: context, title: "login failed", desc: "There is no user with that email").show();
              //print('No user with that email');
            } else if (e.code == 'wrong-password') {
              Alert(context: context, title: "login failed", desc: "Incorrect password").show();
              //print('Wrong password');
            }
          }

        },
        child: Text("Login",
          textAlign: TextAlign.center,
        )
      )
    );
    final signUpButton = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30),
        color: Color(0xff01A0C7),
        child: MaterialButton(
            minWidth: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignUp()),
              );
            },
            child: Text("Sign up",
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
                SizedBox(
                  height: 155,
                  child: Image(image: AssetImage('images/Logo.PNG'))
                ),
                SizedBox(height: 45),
                emailField,
                SizedBox(height: 15),
                passwordField,
                SizedBox(height:15),
                loginButton,
                SizedBox(height: 15),
                signUpButton
              ],
            )

        )
        )
      )
    );
  }
}