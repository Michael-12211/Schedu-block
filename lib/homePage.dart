import 'package:flutter/material.dart';
import 'package:schedu_block/dailyview.dart';
import 'package:schedu_block/schedules.dart';
import 'package:schedu_block/weekview.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatelessWidget {
  String uName;

  final database = FirebaseDatabase.instance.reference();

  HomePage (String n){
    uName = n;
    print (uName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Home page')
        ),
        body: Center(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Log out')
                  )
                ),
                SizedBox(height: 50),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WeekView(uName: uName,)),
                      );
                    },
                    child: SizedBox(
                        height: 205,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Column (
                          children: [
                            SizedBox(
                              //width and height set with the same calculation
                                width: MediaQuery.of(context).size.width * 0.4,
                                height: MediaQuery.of(context).size.width * 0.4,
                              child: Image(image: AssetImage('images/Icon.PNG'))
                            ),
                            Text("Week View", style: TextStyle(fontSize: 30))
                          ]
                        )
                    ),
                ),
                SizedBox(height: 100),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Schedules(uName: uName)),
                          );
                        },
                        child: Text('Schedules', style: TextStyle(fontSize: 20))
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.06),
                      ElevatedButton(
                          onPressed: () {
                            loadToday(context);
                          },
                          child: Column (
                              children: [
                                Text('Today', style: TextStyle(fontSize: 20)),
                                SizedBox(
                                    width: 50,
                                    height: 100,
                                    child: Image(image: AssetImage('images/Icon.PNG'))
                                )
                              ]
                          )
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.06),
                      ElevatedButton(
                        onPressed: () {
                          loadFavorite(context);
                        },
                        child: Column (
                          children: [
                            Text('Favorite', style: TextStyle(fontSize: 20)),
                            SizedBox(
                              width: 50,
                              height: 100,
                              child: Image(image: AssetImage('images/Icon.PNG'))
                            )
                          ]
                        )
                    )
                  ]
                )
              ],
            )
        )
    );
  }

  loadFavorite(BuildContext context) {
    database.once().then((DataSnapshot snapshot) {
      var map = snapshot.value as Map<dynamic, dynamic>;
      var nodes = map['users'][uName];
      var fav = nodes['favorite'];
      var id = nodes['schedules'][fav]['id'];
      var name = nodes['schedules'][fav]['name'];

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DailyView(oName: name, identifier: id, uName: uName,)),
      );
    });
  }

  loadToday(BuildContext context) {
    List<String> days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

    database.once().then((DataSnapshot snapshot) {
      var map = snapshot.value as Map<dynamic, dynamic>;
      var nodes = map['users'][uName];

      var now = DateTime.now();
      //print (now.day);
      int Today = (now.day + 2)%7;

      var fav = nodes['days'][days[Today]];
      var id = nodes['schedules'][fav]['id'];
      var name = nodes['schedules'][fav]['name'];

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DailyView(oName: name, identifier: id, uName: uName,)),
      );
    });
  }
}