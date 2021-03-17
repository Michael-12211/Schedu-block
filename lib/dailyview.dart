import 'package:flutter/material.dart';

class DailyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Daily View')
        ),
        body: Center(
            child: Column(
              children: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('<')
                )
              ],
            )
        )
    );
  }
}