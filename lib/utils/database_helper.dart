import 'dart:async';
import 'dart:core';
import 'package:notepad/models/note.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class DataBaseHelper {
  static DataBaseHelper _dataBaseHelper; //Singleton object
  Database _dataBase; //Singleton DataBase

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  DataBaseHelper._createInstance(); //Named Constructor to create instance of DataBaseHelper

  Future<Database> get database async {
    if (_dataBase == null) {
      _dataBase = await initializeDb();
    }
    return _dataBase;
  }

  factory DataBaseHelper() {
    if (_dataBaseHelper == null) {
      _dataBaseHelper = DataBaseHelper._createInstance();
    }
    return _dataBaseHelper;
  }

  Future<Database> initializeDb() async {
    Directory directory = await getApplicationSupportDirectory();
    String path = directory.path + 'notes.db';

    //Open/create DataBase in current directory

    var notesDataBase =
        await openDatabase(path, version: 1, onCreate: createDb);
    return notesDataBase;
  }

  void createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT,$colTitle TEXT,$colDescription TEXT,$colPriority INTEGER,$colDate TEXT)');
  }

//Fetch
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;
    //var result = db.rawQuery(  'SELECT * FROM $noteTable order by $colPriority ASC');   ////rawQuery method for fetching the data from table

    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

//Insert
  Future<int> insertNote(Note note) async {
    Database db = await this.database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

//Update
  Future<int> updateNote(Note note) async {
    Database db = await this.database;
    var result = db.update(noteTable, note.toMap(),
        where: '$colId=?', whereArgs: [note.id]);
    return result;
  }

//Delete
  Future<int> deleteNote(int id) async {
    Database db = await this.database;
    var result = db.rawDelete('DELETE FROM $noteTable WHERE $colId=$id');
    return result;
  }

  //Get the no of objects/records in the table
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) FROM $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList();
    int count = noteMapList.length;

    List<Note> noteList = List<Note>();
    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromObject(noteMapList[i]));
    }
    return noteList;
  }
}
