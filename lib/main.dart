import 'package:flutter/material.dart';

import 'Screens/note_list.dart';

void main() {
  runApp(new MaterialApp(
      title: "Notes",
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        accentColor: Colors.grey,
        primaryColor: Colors.amber,
      ),
      home: NoteList()));
}
