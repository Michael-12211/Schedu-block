import 'package:flutter/material.dart';
import 'package:schedu_block/dailyview.dart';
import 'package:firebase_database/firebase_database.dart';

class WeekView extends StatefulWidget {
  String uName;
  WeekView({Key key, this.title, @required this.uName}) : super(key: key);
  final String title;

  @override
  _WeekState createState() => _WeekState(uName);
}

class _WeekState extends State<WeekView>{

  final database = FirebaseDatabase.instance.reference();

  String user;

  TextEditingController nameController;

  _WeekState(String u) {
    user = u;
    //loadData(false);
  }

  @override
  Widget build(BuildContext context) {


    final backButton = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30),
        color: Color(0xff01A0C7),
        child: MaterialButton(
          /*minWidth: MediaQuery
                .of(context)
                .size
                .width,*/
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
                        Container(
                            height: MediaQuery.of(context).size.height * 0.7,
                            width: MediaQuery.of(context).size.width * 0.9,
                            margin: EdgeInsets.all(15.0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 2.0,
                                    color: Colors.black
                                )
                            ),
                            child: ListView(
                                physics: AlwaysScrollableScrollPhysics(),
                                /*children: [FutureBuilder<String>(
                                    future: _wait,
                                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                      if (snapshot.hasData) {
                                        return SpannableGrid(
                                            columns: 2,
                                            rows: 24,
                                            spacing: 2.0,
                                            rowHeight: 50,
                                            cells: schedData
                                        );
                                      } else {
                                        return CircularProgressIndicator();
                                      }
                                    }
                                )]*/
                            )
                        ),
                        backButton,
                      ],
                    )
                )
            )
        )
    );
  }
}