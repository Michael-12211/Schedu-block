import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:schedu_block/dailyview.dart';
import 'package:firebase_database/firebase_database.dart';

class Schedules extends StatefulWidget {
  String uName;
  Schedules({Key key, this.title, @required this.uName}) : super(key: key);
  //print ("the uName is" + uName);
  final String title;

  @override
  _SchedulesState createState() => _SchedulesState(uName);
}

class _SchedulesState extends State<Schedules> {

  String uName;

  final database = FirebaseDatabase.instance.reference();

  var schedules = <Widget>[];

  final Future<String> _wait = Future<String>.delayed(
      Duration(milliseconds: 600),
      () => 'Data Loaded'
  );

  loadData (bool re) {
    schedules.clear();

    database.once().then((DataSnapshot snapshot) {
      //print ('Data : ${snapshot.value}');
      //var parsed = jsonDecode(snapshot);
      var map = snapshot.value as Map<dynamic, dynamic>;
      //print ('first ' + map['users'].toString());
      var scheds = map['users'][uName]['schedules'];
      //print ('schedules: ' + scheds.toString());
      //String name = scheds['example']['name'];
      //print (name);
      //print (scheds);

      var fav = map['users'][uName]['favorite'];

      scheds.forEach((key, value) {

        Color col = Colors.blue;
        if (value['id'] == fav) {
          col = Colors.yellow;
        }

        print ('the schedule is: ' + value['name']);
        schedules.add( Container (
          color: col,
          //height: 300,
          child: MaterialButton(
            child: Column(
              children: [
                SizedBox(
                  height: 80,
                  width: 50,
                  child: Image(image: AssetImage('images/Icon.PNG')),
                ),
                Text(value['name'], style: TextStyle(fontSize: 17))
              ],
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DailyView(oName: value['name'], identifier: value['id'], uName: uName,)),
              );
              loadData(true);
            }
          ))
        );
      });

      if (re) {
        print ("resetting");
        setState(() {

        });
      }
    });
  }

  _SchedulesState (String u) {
    uName = u;
    print ("uName: " + uName);
    loadData(false);
  }

  @override
  Widget build(BuildContext context) {

    //loadData(false);


    print ('making scaffold');
    return Scaffold(
        appBar: AppBar(
            title: Text('Schedules')
        ),
        body: Center(
            child: Column(
              children: [

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Scrollbar(
                    isAlwaysShown: true,
                    child: FutureBuilder<String>(
                      future: _wait,
                      key: UniqueKey(),
                      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.hasData) {
                          return GridView.count(
                              crossAxisCount: 3,
                              childAspectRatio: (5 / 7),
                              mainAxisSpacing: 20,
                              children: schedules
                          );
                        } else {
                          return CircularProgressIndicator();
                        }
                      }
                    )
                  ),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('<'),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)
                          )
                        )
                      ),
                    ),
                      ElevatedButton(
                        onPressed: () {
                          addSchedule();
                          //MaterialPageRoute(builder: (context) => DailyView(oName: "example", identifier: "a1", uName: uName,));
                        },
                        child: Text('+'),
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18)
                                )
                            )
                        ),
                      ),
                  ]
                )
              ],
            )
        )
    );
  }

  addSchedule () {
    database.once().then((DataSnapshot snapshot) async {
      var map = snapshot.value as Map<dynamic, dynamic>;
      var nodes = map['users'][uName]['schedules'];
      //print (nodes);
      //print (index);

      List<String> already = List();

      nodes.forEach((key, value) {
        already.add(value['id']);
        print (value['id'] + " is there");
      });

      int i = 1;
      while (true) {
        if (already.contains("a" + i.toString())){
          i++;
        } else {
          break;
        }
      }
      String id = "a" + i.toString();
      print ("The chosen id is " + id);

      var currChi = database.child('users').child(uName).child('schedules').child(id);

      currChi.child("id").set(id);
      currChi.child("name").set("example");

      currChi = currChi.child("nodes").child("a1");

      currChi.child("colour").set("blue");
      currChi.child("duration").set(2);
      currChi.child("id").set("a1");
      currChi.child("name").set("first");
      currChi.child("start").set(5);

      currChi = currChi.child("tags");
      currChi.child("a1").set("welcome");

      print ("this is being called");
      //loadData(true);
      await Navigator.push(
        context,
          MaterialPageRoute(builder: (context) => DailyView(oName: "example", identifier: id, uName: uName,))
      );
      loadData(true);
      //return id;
    });
  }
}