import 'package:flutter/material.dart';
import 'package:schedu_block/dailyview.dart';
import 'package:schedu_block/schedules.dart';
import 'package:schedu_block/weekview.dart';

class HomePage extends StatelessWidget {
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
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WeekView()),
                      );
                    },
                    child: Text('Week View')
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Schedules()),
                      );
                    },
                    child: Text('Schedules')
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DailyView()),
                      );
                    },
                    child: Text('Favorite')
                )
              ],
            )
        )
    );
  }
}