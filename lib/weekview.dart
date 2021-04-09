import 'package:flutter/material.dart';
import 'package:schedu_block/dailyview.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

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
    print ("Loading data");
    scheds.clear();

    database.once().then((DataSnapshot snapshot) {
      var map = snapshot.value as Map<dynamic, dynamic>;
      var nodes = map['users'][user];
      var d = nodes['days'];

      var now = DateTime.now();
      //print (now.day);
      int Today = now.day + 2;

      scheds.add (Container(
        height: MediaQuery.of(context).size.height * 0.03,
      ));

      int b = Today;
      b%=7;
      for (int i = 0; i < 7; i++){
        String tod = d[days[b]];

        Widget but;
        String disp = "Not Set";
        Color col = Colors.grey;

        int curB = b;
        if (tod != "0") { //if a schedule is set
          disp = nodes['schedules'][tod]['name'];

          col = Colors.blue;

          but = Row(
            children: [
              Material(
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
              ),
              SizedBox(
                width: 5,
              ),
              Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(30),
                  color: Color(0xff31A0C7),
                  child: MaterialButton(
                      padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                      minWidth: 10,
                      onPressed: () async {
                        removeThis(days[curB]);
                      },
                      child: Text("X",
                        textAlign: TextAlign.center,
                      )
                  )
              ),
              SizedBox(
                width: 5,
              ),
            ]
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
                    addSchedPopup (context, curB);
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
        b = b%7;
      }

      print ("Done loading");

      if (re) {
        setState(() {

        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    print ("making scaffold");

    return Scaffold(
        body: Center(
            child: Container(
                color: Colors.white,
                child: Padding(
                    padding: const EdgeInsets.all(36),
                    child: Column (
                    children: [
                      FutureBuilder<String>(
                        future: _wait,
                          key: UniqueKey(),
                        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                          if (snapshot.hasData) {
                            return Column (
                              children: scheds,
                            );
                          } else {
                            return CircularProgressIndicator();
                          }
                        }
                      ),
                      Material(
                          elevation: 5.0,
                          borderRadius: BorderRadius.circular(30),
                          color: Color(0xff01A0C7),
                          child: MaterialButton(
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("<",
                                textAlign: TextAlign.center,
                              )
                          )
                      )
                    ])
                )
            )
        )
    );
  }

  loadThis (BuildContext context, String cur) async {
    database.once().then((DataSnapshot snapshot) async {
      var map = snapshot.value as Map<dynamic, dynamic>;
      var nodes = map['users'][user];
      var id = nodes['schedules'][cur]['id'];
      var name = nodes['schedules'][cur]['name'];

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DailyView(oName: name, identifier: id, uName: user,)),
      );

      loadData(true);
    });
  }

  removeThis (String curDay) async {
    database.child('users').child(user).child('days').child(curDay).set("0");
    int d = 0;
    for (int i = 1; i < 50; i++){
      d++;
    }
    print (d);
    loadData(true);
  }

  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();

  Future<void> addSchedPopup(BuildContext context, int when) async {
    return await showDialog(
        context: context,
        builder: (context){
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              content: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        validator: (value) {
                          return value.isNotEmpty ? null : "Enter any text";
                        },
                        decoration: InputDecoration(hintText: "Enter block name"),
                      ),
                    ],
                  )
              ),
              title: Text("Add block"),
              actions: <Widget>[
                InkWell(
                  child: Text("ADD"),
                  onTap: () {
                    if (_formKey.currentState.validate()) {
                      addHere(context, _nameController.text, when);
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            );
          });
        }
    );
  }

  addHere (BuildContext context, String what, int when) {
    print ("yes");

    database.once().then((DataSnapshot snapshot) {
      var map = snapshot.value as Map<dynamic, dynamic>;
      var nodes = map['users'][user]['schedules'];

      bool miss = true;

      nodes.forEach((key, value) {
        print (value['name'] + " is there");
        if (value['name'] == what) {
          print ("match!");
          miss = false;
          print (when);
          database.child('users').child(user).child('days').child(days[when]).set(value['id']);
        }
      });

      if (miss){
        failPopup(context);
      }

      loadData(true);
    });
  }

  Future<void> failPopup(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context){
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              content: Form(
                  key: _formKey2,
                  child: Text("No schedule matches that name")
              ),
              title: Text("Add block"),
              actions: <Widget>[
                InkWell(
                  child: Text("OK"),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
        }
    );
  }
}