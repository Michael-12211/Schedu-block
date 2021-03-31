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
  int index;
  String name;
  int duration;
  List<String> tags;
  String Color;
  int start;
  block (this.index, this.name, this.duration, this.tags, this.Color, this.start) {
  }
}

class _DayState extends State<DailyView> {
  String oName;
  List<block> blocks;

  List<SpannableGridCellData> schedData = List();
  var occupied = new List(25);
  int where = 6;

  TextEditingController nameController;

  _DayState (String n){
    oName = n;
    nameController = new TextEditingController(text: oName);
    blocks = List<block>(24);
    for (int i = 0; i < 24; i++){
      blocks[i] = block(i,"",0,[],"",0);
    }
    blocks[0] = block(0,"test condition",2,["big"],"blue", 6);
    blocks[1] = block(1,"the second",4,[],"red", 1);
  }



  @override
  Widget build(BuildContext context) {

    for (int i = 0; i < 25; i++){
      occupied[i] = false;
    }

    schedData.clear();

    for (int i = 0; i < 24; i++) {
      if (blocks[i].name != "") {
        schedData.add(SpannableGridCellData(
          id: i,
          column: 2,
          row: blocks[i].start,
          rowSpan: blocks[i].duration,
          child: Draggable<block>(
            data: blocks[i],
            child: Container(
                color: Colors.blue,
                child: Text(blocks[i].name)
            ),
            feedback: Container(
                color: Colors.blue,
                height: 100,
                width: 130,
                child: Text(blocks[i].name)
            ),
          ),
        ));
        for (int b = blocks[i].start; b < blocks[i].start + blocks[i].duration; b++){
          occupied[b] = true;
        }
      }
    }


    for (int i = 1; i <= 24; i++) {
      schedData.add(SpannableGridCellData(
          id: "time " + i.toString(),
          column: 1,
          row: i,
          child: Container(
            child: Text ((((i-1)%12)+1).toString() + ":00")
          )
      ));
      if (!occupied[i]) {
        schedData.add(SpannableGridCellData(
            id: "dest" + i.toString(),
            column: 2,
            row: i,
            child: DragTarget<block>(
              builder: (BuildContext context,
                  List<dynamic> accepted,
                  List<dynamic> rejected) {
                return Container(

                );
              },
              onAccept: (block data) {
                if (data.duration + i < 26) {
                  print("dragged");
                  blocks[data.index].start = i;
                  setState(() {

                  });
                }
              },
            )
        ));
      }
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