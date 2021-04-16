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

  final database = FirebaseDatabase.instance.reference(); //accessing the database

  String user; //username

  List<String> days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']; //turns ints to day names

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

  loadData (bool re) { //loads the data. RE determines whether UI should be updated
    //schedData.clear();
    print ("Loading data");
    scheds.clear(); //clears previous data

    database.once().then((DataSnapshot snapshot) { //loads database
      var map = snapshot.value as Map<dynamic, dynamic>; //mapping data
      var nodes = map['users'][user]; //access user
      var d = nodes['days']; //accessing days

      var now = DateTime.now(); //getting current day
      //print (now.day);
      int Today = now.day + 2; //compensating for error

      scheds.add (Container( //add empty space
        height: MediaQuery.of(context).size.height * 0.03,
      ));

      int b = Today; //prevents logical errors
      b%=7; //account for overflow
      for (int i = 0; i < 7; i++){ //for each day
        String tod = d[days[b]]; //get the current day's name

        //defaults
        Widget but;
        String disp = "Not Set";
        Color col = Colors.grey;
        double size = 15;

        int curB = b; //fixes logical errors
        if (tod != "0") { //if a schedule is set
          disp = nodes['schedules'][tod]['name']; //accessing the name
          size = 25; //enlarged text

          col = Colors.blue; //blue for further distinction

          but = Row( //define multiple elements
            children: [
              Material( //info button
                elevation: 5.0,
                borderRadius: BorderRadius.circular(30),
                color: Color(0xff31A0C7),
                child: MaterialButton(
                  padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                  minWidth: 10,
                  onPressed: () async {
                    loadThis(context, tod); //loads the schedule
                  },
                  child: Text("i",
                    textAlign: TextAlign.center,
                  )
                )
              ),
              /*SizedBox(
                width: 5,
              ),*/
              Material( //delete button
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(30),
                  color: Color(0xff31A0C7),
                  child: MaterialButton(
                      padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                      minWidth: 10,
                      onPressed: () async {
                        removeThis(days[curB]); //removes the schedule from that day
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

          but = Material( //add button
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

        scheds.add (Container( //the column contents
          width: MediaQuery.of(context).size.width * 0.7, //most of the screen's width
          height: MediaQuery.of(context).size.height * 0.1, //1/10th the hieght
          color: col, //set colour
          child: Column (
            crossAxisAlignment: CrossAxisAlignment.center, //center the elements
            children: [
              Text(days[b]), //day name
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, //appear on either side
                children: [
                  Text(disp,
                    style: TextStyle(fontSize: size),
                  ),
                  //Text("b")
                  but //buttons
                ],
              )
            ],
          )
        ));
        scheds.add (Container( //empty space
          height: MediaQuery.of(context).size.height * 0.01,
        ));

        //increment day
        b++;
        b = b%7;
      }

      print ("Done loading"); //logging

      //update UI if requested
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
                      FutureBuilder<String>( //wait for data
                        future: _wait,
                          key: UniqueKey(),
                        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                          if (snapshot.hasData) { //once loaded
                            return Column (
                              children: scheds,
                            );
                          } else { //until loaded
                            return CircularProgressIndicator(); //loading icon
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

  loadThis (BuildContext context, String cur) async { //loads the selected schedule
    database.once().then((DataSnapshot snapshot) async { //gets data from database
      var map = snapshot.value as Map<dynamic, dynamic>; //map data
      var nodes = map['users'][user];
      var id = nodes['schedules'][cur]['id'];
      var name = nodes['schedules'][cur]['name'];

      await Navigator.push( //navigate to day view of that schedule
        context,
        MaterialPageRoute(builder: (context) => DailyView(oName: name, identifier: id, uName: user,)),
      );

      loadData(true); //update UI in case data changed
    });
  }

  removeThis (String curDay) async { //remove selected shedule
    database.child('users').child(user).child('days').child(curDay).set("0"); //sets the day as empty

    loadData(true); //update UI
  }

  //popup controllers
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

  addHere (BuildContext context, String what, int when) { //sets the schedule to the day
    print ("yes");

    database.once().then((DataSnapshot snapshot) { //accesses the data
      var map = snapshot.value as Map<dynamic, dynamic>;
      var nodes = map['users'][user]['schedules'];

      bool miss = true;

      //finds the id of the chosen schedule
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
        failPopup(context); //notify the user if the schedule was not found
      }

      loadData(true);
    });
  }

  //alert for the schedule not being found. Cannot use default alerts because the calling method ends
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