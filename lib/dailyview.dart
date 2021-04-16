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
  String index; //id of schedule
  String user; //username
  //List<block> blocks;

  List<SpannableGridCellData> schedData = List(); //the data in the schedule
  var occupied = new List(25); //holds which spaces are available
  //int where = 6;

  TextEditingController nameController; //controller for schedule name

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

  loadData (bool re) { //loads data. RE determines whether the UI should be updated
    for (int i = 0; i < 25; i++) { //sets all locations to open
      occupied[i] = false;
    }

    schedData.clear(); //clears previous data

    database.once().then((DataSnapshot snapshot) { //accesses database
      var map = snapshot.value as Map<dynamic, dynamic>; //maps data
      var nodes = map['users'][user]['schedules'][index]['nodes']; //gets nodes of the schedule
      //print (nodes);
      //print (index);

      if (nodes!=null) { //if there are nodes
        nodes.forEach((key, value) { //for each node
          print('the node is: ' + value['name']); //logging

          List<String> tags; //list of tags (unused, but kept for later potential implementation)

          Color col = Colors.blue; //default is blue in case an incorrect color is enterred

          switch (value['colour']) { //turning the colour string into a UI colour
            case 'grey':
              {
                col = Colors.grey;
              }
              break;
            case 'red':
              {
                col = Colors.red;
              }
              break;
            case 'green':
              {
                col = Colors.green;
              }
          }

          //saving block
          block curr = block(value['id'], value['name'], value['duration'], [],
              value['colour'], value['start']);
          //value.forEa

          schedData.add(SpannableGridCellData( //adding UI block
            id: value['id'], //id
            column: 2, //aligned right of times
            row: value['start'], //start time
            rowSpan: value['duration'], //duration
            columnSpan: 3, //take up the rest of the space
            child: Draggable<block>( //allow the block to be dragged
              data: curr, //contains block data
              child: Container(
                  color: col, //setting colour
                  child: Row( //align elements horizontally
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, //align on opposite sides
                    children: [
                      Text(" " + curr.name, style: TextStyle(fontSize: 18)), //display name
                      Row( //keeps the buttons isolated
                          children: [
                            MaterialButton( //edit button
                              minWidth: 2,
                              onPressed: () {
                                editBlockPopup(context, curr.index, curr.name,
                                    curr.duration, curr.Color); //popup the edit menu
                              },
                              child: Text("i", textAlign: TextAlign.right,),
                            ),
                            MaterialButton( //delete button
                              minWidth: 2,
                              onPressed: () {
                                print("Test");
                                var currChi = database.child('users').child(
                                    user).child('schedules').child(index).child(
                                    'nodes').child(curr.index); //find the element in the database
                                currChi.remove(); //remove it
                                loadData(true); //update UI
                              },
                              child: Text("X", textAlign: TextAlign.right,),
                            )
                          ]
                      )
                    ],
                  )
              ),
              feedback: Container( //what is displayed while moving the block
                  color: col,
                  height: 100,
                  width: 130,
                  child: Text(curr.name,
                      style: TextStyle(fontSize: 18, color: Colors.black))
              ),
            ),
          ));
          for (int b = curr.start; b < curr.start + curr.duration; b++) {
            occupied[b] = true; //sets it's covered time as occupied
          }
        });
      }

      String am = "am";
      for (int i = 1; i <= 24; i++) {
        if (i >= 12) //after noon
          am = "pm"; //changing to pm
        schedData.add(SpannableGridCellData(
            id: "time " + i.toString(),
            column: 1, //only on the left
            row: i,
            child: Container(
                child: Text((((i - 1) % 12) + 1).toString() + ":00" + am) //display the time
            )
        ));
        if (!occupied[i]) { //if the space is open
          schedData.add(SpannableGridCellData(
              id: "dest" + i.toString(),
              column: 2,
              row: i,
              columnSpan: 3,
              child: DragTarget<block>( //sets a space the blocks can be dragged to
                builder: (BuildContext context,
                    List<dynamic> accepted,
                    List<dynamic> rejected) {
                  return Container( //nothing to display

                  );
                },
                onAccept: (block data) async { //when a block is dragged here
                  if (data.duration + i < 26) { //if it fits
                    print("dragged");
                    //String curkey = curr
                    var currChi = database.child('users').child(user).child('schedules').child(index).child('nodes').child(data.index).child('start');
                    currChi.set(i); //sets the start time to this time
                    //blocks[data.index].start = i;
                    loadData(true); //updates UI
                    //sleep(Duration (seconds: 1));
                    //etState(() {

                    //});
                  }
                },
              )
          ));
        }
      }
      if (re) { //if requested
        setState(() { //update UI

        });
      }
    });

    //return schedData;
    //setState(() {

    //});
  }

  @override
  Widget build(BuildContext context) {




    final nameField = TextField( //where to enter schedule name
        controller: nameController, //setting the controller
        onChanged: (text) { //when the name changes
          if (text.length <= 14) { //prevents text overflow on schedules page
            print("name changed to " + text);
            database.child('users').child(user).child('schedules')
                .child(index)
                .child('name')
                .set(text); //setting the new name
          } /*else {
            Alert(context: context, title: "Name length exceeded", desc: "Names can only have up to 9 characters").show();
          }*/
          },
        obscureText: false, //visible
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            hintText: "Schedule name",

            border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
        ),
    );

    final backButton = Material( //back button
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
              Navigator.pop(context); //return to the previous page
            },
            child: Text("<",
              textAlign: TextAlign.center,
            )
        )
    );

    final addButton = Material( //add button
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
              await addBlockPopup(context); //display options to add block
            },
            child: Text("+",
              textAlign: TextAlign.center,
            )
        )
    );

    final deleteButton = Material( //delete button
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

    final favButton = Material( //favorite button
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
              currChi.set(index); //set favorite to this shcuedle's id
              Alert(context: context, title: "Schedule marked as favorite", desc: "This schedule can now be accessed from the home page").show();
            },
            child: Text("#",
              textAlign: TextAlign.center,
            )
        )
    );

    final copyButton = Material( //copy button
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
              copySchedule();
              //var currChi = database.child('users').child(user).child('favorite');
              //currChi.set(index);
              //Alert(context: context, title: "Schedule marked as favorite", desc: "This schedule can now be accessed from the home page").show();
            },
            child: Text("C",
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
                  child: Column( //vertically order elmements
                    children: [
                      nameField,
                      Container(
                        //size relative to screen
                        height: MediaQuery.of(context).size.height * 0.7,
                        width: MediaQuery.of(context).size.width * 0.9,
                        margin: EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          border: Border.all( //border
                            width: 2.0,
                            color: Colors.black
                          )
                        ),
                          child: ListView( //doesn't contain a list, but allows scrolling
                            physics: AlwaysScrollableScrollPhysics(),
                            children: [FutureBuilder<String>(
                              future: _wait, //wait for data to load
                                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                  if (snapshot.hasData) { //when loaded
                                    return SpannableGrid(
                                        columns: 4, //only two columns in practice, set to 4 for sizing
                                        rows: 24, //one for each hour
                                        spacing: 2.0,
                                        rowHeight: 50,
                                        cells: schedData //the data loaded from the database
                                    );
                                  } else { //until then
                                    return CircularProgressIndicator(); //loading symbol
                                  }
                                }
                            )]
                          )
                      ),
                      Row( //horizontally order buttons
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, //space between buttons
                        children: [
                          backButton,
                          addButton,
                          favButton,
                          copyButton,
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

  //variables for page functions
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();



  Future<void> addBlockPopup(BuildContext context) async { //add block interface

    String dVal = 'blue'; //default colour is blue

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
                    TextFormField( //name
                      controller: _nameController,
                      validator: (value) {
                        return value.isNotEmpty ? null : "Enter any text";
                      },
                      decoration: InputDecoration(hintText: "Enter block name"),
                    ),
                    TextFormField( //duration
                      controller: _durationController,
                      validator: (value) {
                        return value.isNotEmpty ? null : "Enter any text";
                      },
                      decoration: InputDecoration(hintText: "Enter block duration"),
                    ),
                    DropdownButton<String>( //colour
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
                  child: Text("ADD"), //add button
                  onTap: () {
                    if (_formKey.currentState.validate()) {
                      addBlock(_nameController.text, int.parse(_durationController.text), dVal);
                      Navigator.of(context).pop(); //remove the popup
                    }
                  },
                )
              ],
            );
          });
        }
    );
  }

  addBlock(String name, int dur, String col) { //code to add a block
    print ("the block is " + name); //logging

    database.once().then((DataSnapshot snapshot) { //access the database
      var map = snapshot.value as Map<dynamic, dynamic>; //map the data
      var nodes = map['users'][user]['schedules'][index]['nodes']; //access nodes
      //print (nodes);
      //print (index);

      List<String> already = List(); //list of taken IDs
      var open = List<bool>(25); //list of open times
      for (int i = 0; i < 25; i++) {
        open[i] = true;
      }

      String id = "a1";
      if (nodes!=null) { //if there are nodes
        nodes.forEach((key, value) { //for each node
          already.add(value['id']); //record the id as taken
          print(value['id'] + " is there"); //logging
          for (int i = value['start']; i <
              value['start'] + value['duration']; i++) {
            open[i] = false; //set the covered times as unavailable
          }
        });

        int i = 1;
        while (true) { //until a valid id is found
          if (already.contains("a" + i.toString())) { //if the id is taken
            i++; //increment
          } else { //if it is available
            break;
          }
        }
        id = "a" + i.toString(); //set the id
      }

      //finding valid start time
      int start = 1;
      for (int i = 1; i < 25; i++){
        if (open[i]) {
          start = i;
          break;
        }
      }

      print ("The chosen id is " + id + ", starting at " + start.toString()); //logging

      //access the chosen id
      var currChi = database.child('users').child(user).child('schedules').child(index).child('nodes').child(id);

      //set the data
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

  Future<void> deletePopup(BuildContext context) async { //delete confirmation
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
                    Navigator.pop(context); //close popup
                    Navigator.pop(context); //close schedule editor now that the schedule does not exist
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

    return await showDialog( //similar to creating a new block, but with pre-filled settings
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

  editBlock(String id, String name, int dur, String col) { //saving edited settings
    print ("the block is " + name);

    //access block data
      var currChi = database.child('users').child(user).child('schedules').child(index).child('nodes').child(id);

      //set data
      currChi.child("colour").set(col);
      currChi.child("duration").set(dur);
      currChi.child("name").set(name);

      currChi = currChi.child("tags");
      currChi.child("a1").set("welcome");

      loadData(true);
  }

  copySchedule () { //create a copy of the schedule. Mostly same as ne schedule, but with more pre-set data
    database.once().then((DataSnapshot snapshot) async { //access the database
      var map = snapshot.value as Map<dynamic, dynamic>; //map the data
      var nodes = map['users'][user]['schedules']; //access nodes
      //print (nodes);
      //print (index);

      List<String> already = List(); //list of taken IDs

      nodes.forEach((key, value) { //record the taken ids
        already.add(value['id']);
        print (value['id'] + " is there");
      });

      //find a valid id
      int i = 1;
      while (true) {
        if (already.contains("a" + i.toString())){
          i++;
        } else {
          break;
        }
      }
      String id = "a" + i.toString();
      print ("The chosen id is " + id);

      var currChi = database.child('users').child(user).child('schedules').child(id); //accessing chosen id

      currChi.set(nodes[id]);
      currChi.child("id").set(id);
      currChi.child("name").set(nameController.text + "2"); //appends 2 to name

      currChi = currChi.child("nodes"); //moving to nodes

      nodes = nodes[index]['nodes']; //accessing nodes of the copied schedule
      int inte = 1;

      //copy current nodes to new schedule
      nodes.forEach((key, value) {
        //already.add(value['id']);
        //print (value['id'] + " is there");
        var lChi = currChi.child("a" + inte.toString());
        lChi.child('colour').set(value['colour']);
        lChi.child('duration').set(value['duration']);
        lChi.child('id').set('a' + inte.toString());
        lChi.child('name').set(value['name']);
        lChi.child('start').set(value['start']);
        lChi.child('tags').child('a1').set('welcome');

        inte++;
      });

      /*currChi.child("colour").set("blue");
      currChi.child("duration").set(2);
      currChi.child("id").set("a1");
      currChi.child("name").set("first");
      currChi.child("start").set(5);

      currChi = currChi.child("tags");
      currChi.child("a1").set("welcome");*/

      print ("this is being called");
      //loadData(true);
      await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DailyView(oName: nameController.text + "2", identifier: id, uName: user,))
      );
      loadData(true);
      //return id;
    });
  }

}
