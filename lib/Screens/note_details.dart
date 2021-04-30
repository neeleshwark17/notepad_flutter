import 'package:flutter/material.dart';
import 'package:notepad/models/note.dart';
import 'package:intl/intl.dart';
import 'package:notepad/utils/database_helper.dart';

class NoteDetails extends StatefulWidget {
  final String appBarTitle;
  final Note note;
  NoteDetails(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailsState(this.note, this.appBarTitle);
  }
}

class NoteDetailsState extends State<NoteDetails> {
  var formKey = GlobalKey<FormState>();

  static var priorities = ["High", "Low"];
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String currentSelectedItem = "";

  DataBaseHelper helper = DataBaseHelper();

  String appBarTitle;
  Note note;
  NoteDetailsState(this.note, this.appBarTitle);

  @override
  void initState() {
    super.initState();
    currentSelectedItem = priorities[1];
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.subtitle1;
    return WillPopScope(
        onWillPop: () {
          moveToLastScreen();
          return null;
        },
        child: Scaffold(
          appBar: new AppBar(
            title: new Text(appBarTitle),
            leading: new IconButton(
                icon: new Icon(Icons.arrow_back),
                onPressed: () {
                  moveToLastScreen();
                }),
          ),
          body: Form(
            key: formKey,
            child: new Padding(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              child: new ListView(
                children: <Widget>[
                  ////First Element
                  new ListTile(
                    title: new DropdownButton<String>(
                      items: priorities.map((String dropDownStringItem) {
                        return DropdownMenuItem<String>(
                            value: dropDownStringItem,
                            child: new Text(dropDownStringItem));
                      }).toList(),
                      style: textStyle,
                      onChanged: (String valueSelectedByUser) {
                        setState(() {
                          updatePriorityAsString(valueSelectedByUser);
                          debugPrint("$valueSelectedByUser Priority");
                        });
                      },
                      value: getPriorityAsString(note.priority),
                    ),
                  ),

                  ////Second Element

                  new Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: new TextFormField(
                      controller: titleController,
                      validator: (value) {
                        String msg;
                        if (value.isEmpty) {
                          msg = 'Please enter some Title';
                        }
                        return msg;
                      },
                      style: textStyle,
                      onChanged: (value) {
                        debugPrint("TextFied 1");
                        updateTitle();
                      },
                      decoration: new InputDecoration(
                          labelText: "Title",
                          labelStyle: textStyle,
                          border: new OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5))),
                    ),
                  ),

                  ////Third Element

                  new Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: new TextField(
                      controller: descriptionController,
                      style: textStyle,
                      onChanged: (value) {
                        debugPrint("Description");
                        updateDescription();
                      },
                      decoration: new InputDecoration(
                        labelStyle: textStyle,
                        labelText: "Description",
                        border: new OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5)),
                      ),
                    ),
                  ),

                  ////Fourth Element ---Row

                  new Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new RaisedButton(
                              color: Colors.grey,
                              textColor: Colors.white,
                              child: new Text(
                                "Save",
                                textScaleFactor: .8,
                              ),
                              onPressed: () {
                                if (formKey.currentState.validate()) {
                                  setState(() {
                                    debugPrint("Save Raised Button");
                                    _save();
                                  });
                                }
                              }),
                        ),
                        new Container(
                          width: 5,
                        ),
                        new Expanded(
                            child: new RaisedButton(
                                color: Colors.grey,
                                textColor: Colors.white,
                                child: new Text("Delete"),
                                onPressed: () {
                                  debugPrint("Delete Raised Button");
                                  _delete();
                                }))
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

//Convert String to int for saving it into database
  void updatePriorityAsString(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

//Convert int to string for displaying on screen
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = priorities[0]; //High
        break;
      case 2:
        priority = priorities[1]; //Low
        break;
    }
    return priority;
  }

//Update the title of Note object
  void updateTitle() {
    note.title = titleController.text;
  }

//Update the Description of Note object
  void updateDescription() {
    note.description = descriptionController.text;
  }

  void _save() async {
    moveToLastScreen();
    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {
      result = await helper.updateNote(note);
    } else {
      result = await helper.insertNote(note);
    }
    if (result != 0) {
      _showAlertDialogue('Status', 'Saved Successfully');
    } else {
      _showAlertDialogue('Status', 'Failed');
    }
  }

  void _showAlertDialogue(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      content: new Text(message),
      title: new Text(title),
    );
    showDialog(context: context, builder: (context) => alertDialog);
  }

  void _delete() async {
    moveToLastScreen();
    if (note.id == null) {
      _showAlertDialogue('Status', 'No note deleted');
      return;
    }

    int result = await helper.deleteNote(note.id);
    if (result != 0) {
      _showAlertDialogue('Status', 'Note Deleted');
    } else {
      _showAlertDialogue('Status', 'Failed to delete');
    }
  }
}
