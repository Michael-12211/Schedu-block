import 'package:flutter/material.dart';
import 'package:schedu_block/homePage.dart';
import 'package:schedu_block/signup.dart';

void main() {
  runApp(MaterialApp(
    title: 'Schedu-block',
    home: Login()
  ));
}

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Column(
          children: [
            Image(image: AssetImage('images/Logo.PNG')),
            ElevatedButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
                child: Text('Enter')
            ),
            ElevatedButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUp()),
                  );
                },
                child: Text('Sign up')
            )
          ],
        )
      )
    );
  }
}

