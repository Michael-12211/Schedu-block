import 'package:flutter/material.dart';


class DailyView extends StatefulWidget {
  DailyView({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _DayState createState() => _DayState();
}

class _DayState extends State<DailyView> {
  TextEditingController nameController = new TextEditingController(text: 'Blank');

  @override
  Widget build(BuildContext context) {
    final nameField = TextField(
        controller: nameController,
        obscureText: false,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            hintText: "Schedule name",

            border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
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
                    children: [
                      nameField,
                      backButton
                    ],
                  )
              )
          )
        )
    );
  }
}