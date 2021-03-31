import 'package:flutter/material.dart';
import 'package:schedu_block/dailyview.dart';

class Schedules extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    //making all the schedules show up uniform
    final schedules = <Widget>[];
    for (var i = 0; i < 10; i++){
      schedules.add( MaterialButton(
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
    }

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
                    child: GridView.count (
                      crossAxisCount: 3,
                      mainAxisSpacing: 80,
                      children: schedules
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