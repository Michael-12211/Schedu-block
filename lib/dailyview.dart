import 'package:flutter/material.dart';
import 'package:spannable_grid/spannable_grid.dart';


class DailyView extends StatefulWidget {
  String oName;
  DailyView({Key key, this.title, @required this.oName}) : super(key: key);
  final String title;

  @override
  _DayState createState() => _DayState(oName);
}

class block {
  String name;
  block () {
    name = "text";
  }
}

class _DayState extends State<DailyView> {
  String oName;

  TextEditingController nameController;

  _DayState (String n){
    oName = n;
    nameController = new TextEditingController(text: oName);
  }

  @override
  Widget build(BuildContext context) {
    List<SpannableGridCellData> schedData = List();
    var occupied = new List(24);

    for (int i = 1; i <= 24; i++) {
      schedData.add(SpannableGridCellData(
          id: "time " + i.toString(),
          column: 1,
          row: i,
          child: Container(
            child: Text ((((i-1)%12)+1).toString() + ":00")
          )
      ));
    }

    final nameField = TextField(
        controller: nameController,
        obscureText: false,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            hintText: "Schedule name",

            border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
        )
    );

    final backButton = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30),
        color: Color(0xff01A0C7),
        child: MaterialButton(
            minWidth: MediaQuery
                .of(context)
                .size
                .width,
            padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("<",
              textAlign: TextAlign.center,
            )
        )
    );

    return Scaffold(
        body: Center(
          child: Container(
            color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(36),
                  child: Column(
                    children: [
                      nameField,
                      Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        width: MediaQuery.of(context).size.width * 0.9,
                        margin: EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2.0,
                            color: Colors.black
                          )
                        ),
                          child: ListView(
                            physics: AlwaysScrollableScrollPhysics(),
                            children: [SpannableGrid(
                              columns: 2,
                              rows: 24,
                              spacing: 2.0,
                              rowHeight: 50,
                              cells: schedData
                            )]
                          )
                      ),
                      backButton
                    ],
                  )
              )
          )
        )
    );
  }
}