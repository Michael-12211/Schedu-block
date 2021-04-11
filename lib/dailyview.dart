import 'package:flutter/material.dart';
import 'package:spannable_grid/spannable_grid.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rflutter_alert/rflutter_alert.dart';


class DailyView extends StatefulWidget {
  String oName; //Origional name of the schedule
  String identifier; //id of the schedfule to find it in the database
  String uName; //username to access their side of the database
  DailyView({Key key, this.title, @required this.oName, @required this.identifier, @required this.uName}) : super(key: key);
  final String title;

  @override
  _DayState createState() => _DayState(oName, identifier, uName);
}

class block { //stores information for blocks
  String index;
  String name;
  int duration;
  List<String> tags;
  String Color;
  int start;
  block (this.index, this.name, this.duration, this.tags, this.Color, this.start) {
  }
}

class _DayState extends State<DailyView> { //state for the schedules page

  final database = FirebaseDatabase.instance.reference(); //storing the frebase access

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

        Color col = Colors.blue; //default is blue in case an incorrect color is enterred

        switch(value['colour']) {
          case 'grey': {
            col = Colors.grey;
          }
          break;
          case 'red': {
            col = Colors.red;
          }
          break;
          case 'green': {
            col = Colors.green;
          }
        }

        block curr = block(value['id'],value['name'],value['duration'],[],value['colour'],value['start']);
        //value.forEa

        schedData.add(SpannableGridCellData(
          id: value['id'],
          column: 2,
          row: value['start'],
          rowSpan: value['duration'],
          columnSpan: 3,
          child: Draggable<block>(
            data: curr,
            child: Container(
                color: col,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(" " + curr.name),
                    Row(
                      children: [
                        MaterialButton(
                          minWidth: 2,
                          onPressed: () {
                            editBlockPopup(context, curr.index, curr.name, curr.duration, curr.Color);
                          },
                          child: Text("i", textAlign: TextAlign.right,),
                        ),
                        MaterialButton(
                          minWidth: 2,
                          onPressed: () {
                            print("Test");
                            var currChi = database.child('users').child(user).child('schedules').child(index).child('nodes').child(curr.index);
                            currChi.remove();
                            loadData(true);
                          },
                          child: Text("X", textAlign: TextAlign.right,),
                        )
                      ]
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

      String am = "am";
      for (int i = 1; i <= 24; i++) {
        if (i >= 12)
          am = "pm";
        schedData.add(SpannableGridCellData(
            id: "time " + i.toString(),
            column: 1,
            row: i,
            child: Container(
                child: Text((((i - 1) % 12) + 1).toString() + ":00" + am)
            )
        ));
        if (!occupied[i]) {
          schedData.add(SpannableGridCellData(
              id: "dest" + i.toString(),
              column: 2,
              row: i,
              columnSpan: 3,
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
        onChanged: (text) {
          if (text.length <= 9) { //prevents text overflow on schedules page
            print("name changed to " + text);
            database.child('users').child(user).child('schedules')
                .child(index)
                .child('name')
                .set(text);
          } /*else {
            Alert(context: context, title: "Name length exceeded", desc: "Names can only have up to 9 characters").show();
          }*/
          },
        obscureText: false,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            hintText: "Schedule name",

            border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
        ),
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
            minWidth: 10,
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
            minWidth: 10,
            onPressed: () async {
              await addBlockPopup(context);
            },
            child: Text("+",
              textAlign: TextAlign.center,
            )
        )
    );

    final deleteButton = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30),
        color: Color(0xff01A0C7),
        child: MaterialButton(
          /*minWidth: MediaQuery
                .of(context)
                .size
                .width,*/
            padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            minWidth: 10,
            onPressed: () async {
              deletePopup(context);
            },
            child: Text("X",
              textAlign: TextAlign.center,
            )
        )
    );

    final favButton = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30),
        color: Color(0xff01A0C7),
        child: MaterialButton(
          /*minWidth: MediaQuery
                .of(context)
                .size
                .width,*/
            padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            minWidth: 10,
            onPressed: () {
              var currChi = database.child('users').child(user).child('favorite');
              currChi.set(index);
              Alert(context: context, title: "Schedule marked as favorite", desc: "This schedule can now be accessed from the home page").show();
            },
            child: Text("#",
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
                                        columns: 4,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          backButton,
                          addButton,
                          favButton,
                          deleteButton
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
  final TextEditingController _durationController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();



  Future<void> addBlockPopup(BuildContext context) async {

    String dVal = 'blue';

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
                    ),
                    TextFormField(
                      controller: _durationController,
                      validator: (value) {
                        return value.isNotEmpty ? null : "Enter any text";
                      },
                      decoration: InputDecoration(hintText: "Enter block duration"),
                    ),
                    DropdownButton<String>(
                      value: dVal,
                        icon: Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        underline: Container(
                          height: 2,
                          color: Colors.black
                        ),
                        onChanged: (String newValue) {
                          setState(() {
                            dVal = newValue;
                          });
                        },
                        items: <String>['blue', 'grey', 'red', 'green']
                        .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value)
                          );
                        }).toList()
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
                      addBlock(_nameController.text, int.parse(_durationController.text), dVal);
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

  addBlock(String name, int dur, String col) {
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

      currChi.child("colour").set(col);
      currChi.child("duration").set(dur);
      currChi.child("id").set(id);
      currChi.child("name").set(name);
      currChi.child("start").set(start);

      currChi = currChi.child("tags");
      currChi.child("a1").set("welcome");

      loadData(true);
    });
  }

  Future<void> deletePopup(BuildContext context) async {
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

                    ],
                  )
              ),
              title: Text("Delete schdule?"),
              actions: <Widget>[
                InkWell(
                  child: Text("Delete"),
                  onTap: () {
                    var currChi = database.child('users').child(user).child('schedules').child(index);
                    currChi.remove();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
        }
    );
  }

  Future<void> editBlockPopup(BuildContext context, String index, String currName, int currVal, String currCol) async {

    _nameController.text = currName;
    _durationController.text = "" + currVal.toString();
    String dVal = currCol;

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
                      ),
                      TextFormField(
                        controller: _durationController,
                        validator: (value) {
                          return value.isNotEmpty ? null : "Enter any text";
                        },
                        decoration: InputDecoration(hintText: "Enter block duration"),
                      ),
                      DropdownButton<String>(
                          value: dVal,
                          icon: Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          underline: Container(
                              height: 2,
                              color: Colors.black
                          ),
                          onChanged: (String newValue) {
                            setState(() {
                              dVal = newValue;
                            });
                          },
                          items: <String>['blue', 'grey', 'red', 'green']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value)
                            );
                          }).toList()
                      )
                    ],
                  )
              ),
              title: Text("Edit block"),
              actions: <Widget>[
                InkWell(
                  child: Text("Confirm"),
                  onTap: () {
                    if (_formKey.currentState.validate()) {
                      editBlock(index, _nameController.text, int.parse(_durationController.text), dVal);
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

  editBlock(String id, String name, int dur, String col) {
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

      var currChi = database.child('users').child(user).child('schedules').child(index).child('nodes').child(id);

      currChi.child("colour").set(col);
      currChi.child("duration").set(dur);
      currChi.child("id").set(id);
      currChi.child("name").set(name);

      currChi = currChi.child("tags");
      currChi.child("a1").set("welcome");

      loadData(true);
    });
  }

}
