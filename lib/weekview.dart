import 'package:flutter/material.dart';
import 'package:schedu_block/dailyview.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:spannable_grid/spannable_grid.dart';

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

  List<String> days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

  //List<SpannableGridCellData> schedData = List();
  List<Widget> scheds = List();

  _WeekState(String u) {
    user = u;
    loadData(false);
  }

  final Future<String> _wait = Future<String>.delayed(
      Duration(milliseconds: 500),
          () => 'Data Loaded'
  );

  loadData (bool re) {
    //schedData.clear();
    scheds.clear();

    database.once().then((DataSnapshot snapshot) {
      var map = snapshot.value as Map<dynamic, dynamic>;
      var nodes = map['users'][user];
      var d = nodes['days'];

      int Today = 0;

      scheds.add (Container(
        height: MediaQuery.of(context).size.height * 0.03,
      ));

      int b = Today;
      for (int i = 0; i < 7; i++){
        String tod = d[days[b]];

        Widget but;
        String disp = "Not Set";
        Color col = Colors.grey;

        if (tod != "0") { //if a schedule is set
          disp = nodes['schedules'][tod]['name'];

          col = Colors.blue;

          but = Material(
              elevation: 5.0,
              borderRadius: BorderRadius.circular(30),
              color: Color(0xff31A0C7),
              child: MaterialButton(
                  padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                  minWidth: 10,
                  onPressed: () async {
                    loadThis(context, tod);
                  },
                  child: Text("i",
                    textAlign: TextAlign.center,
                  )
              )
          );
        } else { //if no schedule is set
          but = Material(
              elevation: 5.0,
              borderRadius: BorderRadius.circular(30),
              color: Color(0xff31A0C7),
              child: MaterialButton(
                  padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                  minWidth: 10,
                  onPressed: () async {
                    //await addBlockPopup(context);
                  },
                  child: Text("+",
                    textAlign: TextAlign.center,
                  )
              )
          );
        }

        scheds.add (Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.1,
          color: col,
          child: Column (
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(days[b]),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(disp),
                  //Text("b")
                  but
                ],
              )
            ],
          )
        ));
        scheds.add (Container(
          height: MediaQuery.of(context).size.height * 0.01,
        ));

        b++;
        b%=7;
      }

      scheds.add(Material(
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
        )
      );
    });
  }

  @override
  Widget build(BuildContext context) {



    return Scaffold(
        body: Center(
            child: Container(
                color: Colors.white,
                child: Padding(
                    padding: const EdgeInsets.all(36),
                    child: FutureBuilder<String>(
                      future: _wait,
                      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.hasData) {
                          return Column (
                            children: scheds,
                          );
                        } else {
                          return CircularProgressIndicator();
                        }
                      }
                    )
                )
            )
        )
    );
  }

  loadThis (BuildContext context, String cur) {
    database.once().then((DataSnapshot snapshot) {
      var map = snapshot.value as Map<dynamic, dynamic>;
      var nodes = map['users'][user];
      var id = nodes['schedules'][cur]['id'];
      var name = nodes['schedules'][cur]['name'];

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DailyView(oName: name, identifier: id, uName: user,)),
      );
    });
  }
}