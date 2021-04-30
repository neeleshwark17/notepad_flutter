import 'package:flutter/material.dart';
import 'package:notepad/Screens/note_details.dart';
import 'package:notepad/models/note.dart';
import 'package:notepad/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  DataBaseHelper dataBaseHelper = DataBaseHelper();
  List<Note> noteList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }

    return Scaffold(
      appBar: new AppBar(
        title: new Text("Notes"),
      ),
      body: getNoteListView(context),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          debugPrint("FAB Clicked");
          navigateToNoteDetail(Note(2, '', ''), 'Add Note');
        },
        tooltip: "Add Note",
        child: new Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.subtitle1;
    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int position) {
          return Card(
            color: Colors.white,
            elevation: 2,
            child: new ListTile(
              leading: CircleAvatar(
                  backgroundColor:
                      getPriorityColor(this.noteList[position].priority),
                  child: getPriorityIcon(this.noteList[position].priority)),
              title: new Text(this.noteList[position].title, style: textStyle),
              subtitle: new Text(this.noteList[position].date),
              trailing: new GestureDetector(
                child: new Icon(Icons.delete, color: Colors.grey),
                onTap: () {
                  _delete(context, noteList[position]);
                },
              ),
              onTap: () {
                navigateToNoteDetail(this.noteList[position], 'Edit Note');
                debugPrint("List Tile Clicked");
              },
            ),
          );
        });
  }

//Returns the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;
      default:
        return Colors.yellow;
        break;
    }
  }

//Returns the priority icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.arrow_right);
        break;
      default:
        return Icon(Icons.arrow_right);
        break;
    }
  }

//Delete
  void _delete(BuildContext context, Note note) async {
    int result = await dataBaseHelper.deleteNote(note.id);
    if (result != null) {
      _showSnackBar(context, 'Note Deleted Successfully');
    }
    updateListView();
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    // ignore: deprecated_member_use
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToNoteDetail(Note note, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetails(note, title);
    }));
    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = dataBaseHelper.initializeDb();
    dbFuture.then((databse) {
      Future<List<Note>> noteListFuture = dataBaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}
