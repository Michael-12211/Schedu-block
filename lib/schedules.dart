import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:schedu_block/dailyview.dart';
import 'package:firebase_database/firebase_database.dart';

class Schedules extends StatefulWidget {
  Schedules({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _SchedulesState createState() => _SchedulesState();
}

class _SchedulesState extends State<Schedules> {

  final database = FirebaseDatabase.instance.reference();

  var schedules = <Widget>[];

  final Future<String> _wait = Future<String>.delayed(
      Duration(milliseconds: 200),
      () => 'Data Loaded'
  );

  @override
  Widget build(BuildContext context) {

    database.once().then((DataSnapshot snapshot) {
      //print ('Data : ${snapshot.value}');
      //var parsed = jsonDecode(snapshot);
      var map = snapshot.value as Map<dynamic, dynamic>;
      //print ('first ' + map['users'].toString());
      var scheds = map['users']['admin']['schedules'];
      //print ('schedules: ' + scheds.toString());
      //String name = scheds['example']['name'];
      //print (name);

      scheds.forEach((key, value) {
        print ('the schedule is: ' + value['name']);
        schedules.add( MaterialButton(
            child: Column(
              children: [
                SizedBox(
                  height: 90,
                  width: 60,
                  child: Image(image: AssetImage('images/Logo.PNG')),
                ),
                Text(value['name'])
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DailyView(oName: value['name'])),
              );
            }
        ));
      });
    });

    //sleep(Duration(seconds: 3));

    /*for (var i = 0; i < 9; i++){
      MaterialButton m = ( MaterialButton(
        child: Column(
          children: [
            SizedBox(
              height: 90,
              width: 60,
              child: Image(image: AssetImage('images/Logo.PNG')),
            ),
            Text("name: " + i.toString())
          ],
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DailyView(oName: "Name: " + i.toString())),
          );
        }
      ));
      //var m = Text("test");
      schedules.add(m);
    }*/

    print ('making scaffold');
    return Scaffold(
        appBar: AppBar(
            title: Text('Schedules')
        ),
        body: Center(
            child: Column(
              children: [

                SizedBox(
                  height: 500,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Scrollbar(
                    isAlwaysShown: true,
                    child: FutureBuilder<String>(
                      future: _wait,
                      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.hasData) {
                          return GridView.count(
                              crossAxisCount: 3,
                              mainAxisSpacing: 80,
                              children: schedules
                          );
                        } else {
                          return CircularProgressIndicator();
                        }
                      }
                    )
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
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
                )
              ],
            )
        )
    );
  }
}