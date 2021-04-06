import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:firebase_database/firebase_database.dart';


class SignUp extends StatefulWidget {
  SignUp({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  final database = FirebaseDatabase.instance.reference();

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
  TextEditingController confirmController = new TextEditingController();

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
            onPressed: () async {
              print('Attempting to create account');
              if (passwordController.text == confirmController.text) {
                try {
                  UserCredential userCredential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                      email: emailController.text,
                      password: passwordController.text
                  );
                  print("account created successfully");
                  addData(emailController.text.split("@")[0]);
                  Navigator.pop(context);
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'weak-password') {
                    Alert(context: context, title: "Creation failed", desc: "Password too weak").show();
                    //print("password was too weak");
                  } else if (e.code == 'email-already-in-use') {
                    Alert(context: context, title: "Creation failed", desc: "That email is taken").show();
                    //print("An account exists for that email");
                  }
                }
              } else {
                Alert(context: context, title: "Creation failed", desc: "Confirm password does not match password").show();
                //print("password was not confirmed");
              }
              //Navigator.pop(context);
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
                        emailField,
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

  addData (String name) {
    var currChi = database.child('users').child(name);
    currChi.child("favorite").set("a1");

    var days = currChi.child("days");
    days.child("mon").set("0");
    days.child("tue").set("0");
    days.child("wed").set("0");
    days.child("thu").set("0");
    days.child("fri").set("0");
    days.child("sat").set("0");
    days.child("sun").set("0");

    currChi = currChi.child("schedules").child("a1");
    currChi.child("id").set("a1");
    currChi.child("name").set("example");

    currChi = currChi.child("nodes").child("a1");
    currChi.child("id").set("a1");
    currChi.child("name").set("first");
    currChi.child("colour").set("blue");
    currChi.child("start").set(4);
    currChi.child("duration").set(2);
    currChi.child("tags").child("a1").set("welcome");
  }
}