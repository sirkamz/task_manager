import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:task_manager/model/task.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // Singleton DatabaseHelper
  static Database _database; // Singleton Database

  String taskTable = 'task_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'tasks.db';

    // Open/create the database at a given path
    var tasksDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return tasksDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $taskTable($colId INTEGER PRIMARY KEY AUTOINCREMENT , $colTitle TEXT, '
        '$colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

  // Fetch Operation: Get all objects from database
  Future<List<Map<String, dynamic>>> getTaskMapList() async {
    Database db = await this.database;

    var result = await db.query(taskTable, orderBy: '$colPriority ASC');
    return result;
  }

  // Insert Operation: Insert  object to database
  Future<int> insertTask(Task task) async {
    Database db = await this.database;
    var result = await db.insert(taskTable, task.toMap());
    return result;
  }

  // Update Operation: Update an object and save it to database
  Future<int> updateTask(Task task) async {
    var db = await this.database;
    var result = await db.update(taskTable, task.toMap(),
        where: '$colId = ?', whereArgs: [task.id]);
    return result;
  }

  // Delete Operation: Delete an object from database
  Future<int> deleteTask(int id) async {
    var db = await this.database;
    int result =
        await db.rawDelete('DELETE FROM $taskTable WHERE $colId = $id');
    return result;
  }

  // Get number of objects in database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $taskTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'Task List' [ List<Task> ]
  Future<List<Task>> getTaskList() async {
    var taskMapList = await getTaskMapList(); // Get 'Map List' from database
    int count =
        taskMapList.length; // Count the number of map entries in db table

    List<Task> taskList = <Task>[];
    // For loop to create a 'Task List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      taskList.add(Task.fromMapObject(taskMapList[i]));
    }

    return taskList;
  }
}
