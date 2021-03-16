import 'package:flutter/material.dart';
import 'package:schedu_block/homePage.dart';

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
            ElevatedButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
                child: Text('Enter')
            )
          ],
        )
      )
    );
  }
}

