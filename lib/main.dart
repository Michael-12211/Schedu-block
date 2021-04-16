import 'package:flutter/material.dart';
import 'package:schedu_block/homePage.dart';
import 'package:schedu_block/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  //code to connect to firebase. Taken from firebase sources
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

  //necessary controllers
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();

    //persistent login
    autoLogin();
  }

  @override
  Widget build(BuildContext context) {
    final emailField = TextField( //defining the email text field
      controller: emailController, //setting the controller
      obscureText: false, //visible
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Email",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
      )
    );
    final passwordField = TextField( //defining the password text field
      controller: passwordController, //setting the controller
        obscureText: true, //not visible
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            hintText: "Password",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
        )
    );
    final loginButton = Material( //login button
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width, //cover the whole width
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        onPressed: () async {
          print('The user is ${emailController.text} with password ${passwordController.text}'); //logging
          try {
            UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: emailController.text,
                password: passwordController.text
            );
            savePref(emailController.text); //if successful, keep them logged in
            Navigator.push( //enter the home page
              context,
              MaterialPageRoute(builder: (context) => HomePage(emailController.text.split("@")[0])),
            );
          } on FirebaseAuthException catch (e) { //user not found
            if (e.code == 'user-not-found') {
              Alert(context: context, title: "login failed", desc: "There is no user with that email").show();
              //print('No user with that email');
            } else if (e.code == 'wrong-password') { //wrong password
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
    final signUpButton = Material( //sign up button
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30),
        color: Color(0xff01A0C7),
        child: MaterialButton(
            minWidth: MediaQuery.of(context).size.width, //takeup entire width
            padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            onPressed: () {
              Navigator.push( //navigate to sign up page
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
            child: Column( //display elements vertically
              crossAxisAlignment: CrossAxisAlignment.center, //center elements
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox( //set image size
                  height: 155,
                  child: Image(image: AssetImage('images/Logo.PNG')) //app logo with text
                ),
                //load sections with spacing
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

  void savePref (String username) async { //save shared preference so user can stay logged in
    final prefs = await SharedPreferences.getInstance(); //get shared preferences

    prefs.setString('schedu_block_user', username); //set who is saved

    print ("saved " + username); //logging
  }

  void autoLogin () async { //auto log in if the user has logged in before
    final prefs = await SharedPreferences.getInstance(); //get shared preferences

    String saved = prefs.getString('schedu_block_user') ?? "not logged in"; //get the required shared preference

    if (saved != "not logged in") { //if the user has logged in
      print (saved + "was automatically logged in!"); //logging

      Navigator.push( //navigate to the home page
        context,
        MaterialPageRoute(builder: (context) => HomePage(saved.split("@")[0])),
      );
    }
  }
}