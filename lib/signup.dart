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

  void initializeFlutterFire() async { //accessing firebase authentication
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

  //controllers
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
    final emailField = TextField( //email tex field
        controller: emailController,
        obscureText: false,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            hintText: "Email",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32.0))
        )
    );
    final passwordField = TextField( //password text field
        controller: passwordController,
        obscureText: true,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            hintText: "Password",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32.0))
        )
    );
    final confirmField = TextField( //confirm password
        controller: confirmController,
        obscureText: true,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            hintText: "Confirm password",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32.0))
        )
    );
    final createButton = Material( //create button
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
              if (passwordController.text == confirmController.text) { //if password is confirmed
                try {
                  UserCredential userCredential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                      email: emailController.text,
                      password: passwordController.text
                  );
                  print("account created successfully"); //logging
                  addData(emailController.text.split("@")[0]); //turn email into savable username
                  //inform user account was created successfully
                  Alert al = Alert(context: context, title: "Creation successfull", desc: "Enjoy the app",
                  buttons: [
                    DialogButton(child: Text("Continue"), onPressed: () => Navigator.pop(context))
                  ]
                  );
                  await al.show();
                  Navigator.pop(context); //return to sign in page
                } on FirebaseAuthException catch (e) { //weak password
                  if (e.code == 'weak-password') {
                    Alert(context: context, title: "Creation failed", desc: "Password too weak").show();
                    //print("password was too weak");
                  } else if (e.code == 'email-already-in-use') { //email in use
                    Alert(context: context, title: "Creation failed", desc: "That email is taken").show();
                    //print("An account exists for that email");
                  }
                }
              } else { //if password was not confirmed
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

    final backButton = Material( //back button
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30),
        color: Color(0xff01A0C7),
        child: MaterialButton(
            minWidth: MediaQuery
                .of(context)
                .size
                .width,
            padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            onPressed: () { //returns to sign in page
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
                      crossAxisAlignment: CrossAxisAlignment.center, //center elements
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text ("Sign up", style: TextStyle(fontSize: 30)),
                        SizedBox(height: 15),
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

  addData (String name) { //adds default data for users to get familiar with the application
    var currChi = database.child('users').child(name); //access user's account
    currChi.child("favorite").set("a1");

    //default data
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