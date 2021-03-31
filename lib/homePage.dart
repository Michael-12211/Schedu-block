import 'package:flutter/material.dart';
import 'package:schedu_block/dailyview.dart';
import 'package:schedu_block/schedules.dart';
import 'package:schedu_block/weekview.dart';

class HomePage extends StatelessWidget {
  String favorite = "test";

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
                        MaterialPageRoute(builder: (context) => WeekView()),
                      );
                    },
                    child: SizedBox(
                        height: 205,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Image(image: AssetImage('images/Logo.PNG'))
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
                            MaterialPageRoute(builder: (context) => Schedules()),
                          );
                        },
                        child: Text('Schedules')
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.3),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DailyView(oName: favorite,)),
                          );
                        },
                        child: Column (
                          children: [
                            Text('Favorite'),
                            SizedBox(
                              width: 50,
                              height: 100,
                              child: Image(image: AssetImage('images/Logo.PNG'))
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
}