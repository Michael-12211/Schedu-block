import 'package:flutter/material.dart';
import 'package:spannable_grid/spannable_grid.dart';
import 'package:firebase_database/firebase_database.dart';


class DailyView extends StatefulWidget {
  String oName;
  String identifier;
  String uName;
  DailyView({Key key, this.title, @required this.oName, @required this.identifier, @required this.uName}) : super(key: key);
  final String title;

  @override
  _DayState createState() => _DayState(oName, identifier, uName);
}

class block {
  String index;
  String name;
  int duration;
  List<String> tags;
  String Color;
  int start;
  block (this.index, this.name, this.duration, this.tags, this.Color, this.start) {
  }
}

class _DayState extends State<DailyView> {

  final database = FirebaseDatabase.instance.reference();

  //String oName;
  String index;
  String user;
  //List<block> blocks;

  List<SpannableGridCellData> schedData = List();
  var occupied = new List(25);
  int where = 6;

  TextEditingController nameController;

  _DayState (String n, String k, String u){
    //oName = n;
    index = k;
    user = u;
    nameController = new TextEditingController(text: n);
    //blocks = List<block>(24);
    //for (int i = 0; i < 24; i++){
    //  blocks[i] = block("","",0,[],"",0);
    //}
    //blocks[0] = block(0,"test condition",2,["big"],"blue", 6);
    //blocks[1] = block(1,"the second",4,[],"red", 1);
    loadData(false);
  }

  final Future<String> _wait = Future<String>.delayed(
      Duration(milliseconds: 500),
          () => 'Data Loaded'
  );

  loadData (bool re) {
    for (int i = 0; i < 25; i++) {
      occupied[i] = false;
    }

    schedData.clear();

    database.once().then((DataSnapshot snapshot) {
      var map = snapshot.value as Map<dynamic, dynamic>;
      var nodes = map['users'][user]['schedules'][index]['nodes'];
      //print (nodes);
      //print (index);

      nodes.forEach((key, value) {
        print ('the node is: ' + value['name']);

        List<String> tags;

        block curr = block(value['id'],value['name'],value['duration'],[],value['colour'],value['start']);
        //value.forEa

        schedData.add(SpannableGridCellData(
          id: value['id'],
          column: 2,
          row: value['start'],
          rowSpan: value['duration'],
          child: Draggable<block>(
            data: curr,
            child: Container(
                color: Colors.blue,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(" " + curr.name),
                    MaterialButton(
                        onPressed: () {
                          print("Test");
                          var currChi = database.child('users').child(user).child('schedules').child(index).child('nodes').child(curr.index);
                          currChi.remove();
                          loadData(true);
                        },
                      child: Text("X", textAlign: TextAlign.right,),
                    )
                  ],
                )
            ),
            feedback: Container(
                color: Colors.blue,
                height: 100,
                width: 130,
                child: Text(curr.name)
            ),
          ),
        ));
        for (int b = curr.start; b < curr.start + curr.duration; b++){
          occupied[b] = true;
        }
      });

      for (int i = 1; i <= 24; i++) {
        schedData.add(SpannableGridCellData(
            id: "time " + i.toString(),
            column: 1,
            row: i,
            child: Container(
                child: Text((((i - 1) % 12) + 1).toString() + ":00")
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
                onAccept: (block data) async {
                  if (data.duration + i < 26) {
                    print("dragged");
                    //String curkey = curr
                    var currChi = database.child('users').child(user).child('schedules').child(index).child('nodes').child(data.index).child('start');
                    currChi.set(i);
                    //blocks[data.index].start = i;
                    loadData(true);
                    //sleep(Duration (seconds: 1));
                    //etState(() {

                    //});
                  }
                },
              )
          ));
        }
      }
      if (re) {
        setState(() {

        });
      }
    });

    //return schedData;
    //setState(() {

    //});
  }

  @override
  Widget build(BuildContext context) {




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
            /*minWidth: MediaQuery
                .of(context)
                .size
                .width,*/
            padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("<",
              textAlign: TextAlign.center,
            )
        )
    );

    final addButton = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30),
        color: Color(0xff01A0C7),
        child: MaterialButton(
            /*minWidth: MediaQuery
                .of(context)
                .size
                .width,*/
            padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            onPressed: () async {
              await addBlockPopup(context);
            },
            child: Text("+",
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
                            children: [FutureBuilder<String>(
                              future: _wait,
                                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                  if (snapshot.hasData) {
                                    return SpannableGrid(
                                        columns: 2,
                                        rows: 24,
                                        spacing: 2.0,
                                        rowHeight: 50,
                                        cells: schedData
                                    );
                                  } else {
                                    return CircularProgressIndicator();
                                  }
                                }
                            )]
                          )
                      ),
                      Row(
                        children: [
                          backButton,
                          addButton
                        ]
                      )
                    ],
                  )
              )
          )
        )
    );
  }

  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> addBlockPopup(BuildContext context) async {
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
                    )
                  ],
                )
              ),
              title: Text("Add block"),
              actions: <Widget>[
                InkWell(
                  child: Text("ADD"),
                  onTap: () {
                    if (_formKey.currentState.validate()) {
                      addBlock(_nameController.text);
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

  addBlock(String name) {
    print ("the block is " + name);

    database.once().then((DataSnapshot snapshot) {
      var map = snapshot.value as Map<dynamic, dynamic>;
      var nodes = map['users'][user]['schedules'][index]['nodes'];
      //print (nodes);
      //print (index);

      List<String> already = List();
      var open = List<bool>(25);
      for (int i = 0; i < 25; i++) {
        open[i] = true;
      }

      nodes.forEach((key, value) {
        already.add(value['id']);
        print (value['id'] + " is there");
        for (int i = value['start']; i < value['start'] + value['duration']; i++) {
          open[i] = false;
        }
      });

      int start = 1;
      for (int i = 1; i < 25; i++){
        if (open[i]) {
          start = i;
          break;
        }
      }

      int i = 1;
      while (true) {
        if (already.contains("a" + i.toString())){
          i++;
        } else {
          break;
        }
      }
      String id = "a" + i.toString();
      print ("The chosen id is " + id + ", starting at " + start.toString());

      var currChi = database.child('users').child(user).child('schedules').child(index).child('nodes').child(id);

      currChi.child("colour").set("blue");
      currChi.child("duration").set(1);
      currChi.child("id").set(id);
      currChi.child("name").set(name);
      currChi.child("start").set(start);

      currChi = currChi.child("tags");
      currChi.child("a1").set("welcome");

      loadData(true);
    });
  }
}
