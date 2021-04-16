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

  String uName; //user name

  final database = FirebaseDatabase.instance.reference(); //database (used for saving)

  var schedules = <Widget>[]; //the loaded schedules

  final Future<String> _wait = Future<String>.delayed( //inefficient means of waiting for loading. I could not get a more proper means to work.
      Duration(milliseconds: 600),
      () => 'Data Loaded'
  );

  loadData (bool re) { //loas data from database. RE determines whether the screen should update afterwards.
    schedules.clear(); //removes previous data so that it doesn't stack

    database.once().then((DataSnapshot snapshot) { //get data from firebase

      var map = snapshot.value as Map<dynamic, dynamic>; //map the returned value
      var scheds = map['users'][uName]['schedules']; //navigate to schedules

      var fav = map['users'][uName]['favorite']; //access favorite

      if (scheds != null) { //if the user has schedules
        scheds.forEach((key, value) { //for each schedule
          Color col = Colors.blue; //default colour
          if (value['id'] == fav) { //if it is favorite
            col = Colors.yellow; //colour it yellow instead
          }

          print('the schedule is: ' + value['name']); //logging
          schedules.add(Container( //add a container for the schedule
              color: col, //colour it
              //height: 300,
              child: MaterialButton( //make it a button for navigation
                  child: Column(
                    children: [
                      SizedBox(
                        //fixed size
                        height: 80,
                        width: 50,
                        child: Image(image: AssetImage('images/Icon.PNG')), //schedule icon to make it look nice
                      ),
                      Text(value['name'], style: TextStyle(fontSize: 17)) //schedule name
                    ],
                  ),
                  onPressed: () async { //selected
                    await Navigator.push( //navigate to the schedule
                      context,
                      MaterialPageRoute(builder: (context) => DailyView(
                        oName: value['name'], //schedule name
                        identifier: value['id'], //schedule id
                        uName: uName, //username
                      )),
                    );
                    loadData(true); //load data after in case new schedules are made or name changes
                  }
              ))
          );
        });
      } else {
        schedules.add(Text("\nNo schedules have been created")); //inform user no schedules are available
      }

      if (re) { //if screen should update
        print ("resetting"); //logging
        setState(() { //update UI

        });
      }
    });
  }

  _SchedulesState (String u) { //initializer
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
                  //size the main box relative to available space
                  height: MediaQuery.of(context).size.height * 0.7,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Scrollbar( //allow schedules to be scrolled through if not all are visible
                    isAlwaysShown: true,
                    child: FutureBuilder<String>(
                      future: _wait, //waits for data to load
                      key: UniqueKey(), //ensure updates are done correctly
                      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.hasData) { //once the data is returned
                          return GridView.count( //grid for the schedules
                              crossAxisCount: 3, //3 columns
                              childAspectRatio: (5 / 7), //ensuring reasonable size
                              mainAxisSpacing: 20,
                              children: schedules //contains the loaded schedules
                          );
                        } else { //until then
                          return CircularProgressIndicator(); //loading symbol
                        }
                      }
                    )
                  ),
                ),
                Row( //below the main section
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, //place buttons on opposite sides
                    children: [
                      ElevatedButton( //back button
                      onPressed: () {
                        Navigator.pop(context); //return to previous page
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
                      ElevatedButton( //add button
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

  addSchedule () { //method to make and save a new schedule
    database.once().then((DataSnapshot snapshot) async { //load data to ensure ID is unique
      var map = snapshot.value as Map<dynamic, dynamic>; //mapping data
      var nodes = map['users'][uName]['schedules']; //getting schedules
      //print (nodes);
      //print (index);

      List<String> already = List(); //listing the ids that are taken

      String id = "a1"; //default id

      if (nodes!=null) { //if schedules exist
        nodes.forEach((key, value) { //for each schedule
          already.add(value['id']); //record it's id as taken
          print(value['id'] + " is there"); //logging
        });

        int i = 1;
        while (true) { //until a valid id is found
          if (already.contains("a" + i.toString())) { //if the id is taken
            i++; //increment
          } else { //if it is available
            break;
          }
        }
        id = "a" + i.toString(); //take the available id
      }

      print ("The chosen id is " + id); //logging

      var currChi = database.child('users').child(uName).child('schedules').child(id); //select the newly created schedule

      //setting default values
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

      print ("this is being called"); //logging
      //loadData(true);
      await Navigator.push( //navigate to the new schedule
        context,
          MaterialPageRoute(builder: (context) => DailyView(oName: "example", identifier: id, uName: uName,))
      );
      loadData(true);
      //return id;
    });
  }
}