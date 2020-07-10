import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/models/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database _db;

  DatabaseHelper._instance();

  final String tasksTable = 'tasks_table';
  final String colId = 'id';
  final String colTitle = 'title';
  final String colDate = 'date';
  final String colPriority = 'priority';
  final String colStatus = 'status';

  Future<Database> get db async {
    if (_db == null) {
      _db = await _initDb();
    }
    return _db;
  }

  Future<Database> _initDb() async => await openDatabase(
        join(await getDatabasesPath(), 'tasks.db'),
        version: 1,
        onCreate: _createDb,
      );

  _createDb(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $tasksTable('
      '$colId INTEGER PRIMARY KEY AUTOINCREMENT,'
      '$colTitle TEXT,'
      '$colDate TEXT,'
      '$colPriority TEXT,'
      '$colStatus INTEGER'
      ')',
    );
  }

  Future<List<Map<String, dynamic>>> getTaskMapList() async {
    final db = await this.db;
    return db.query(tasksTable);
  }

  Future<List<Task>> getTasksList() async {
    final tasksMap = await getTaskMapList();
    final list = tasksMap.map((map) => Task.fromMap(map)).toList();
    list.sort((taskA, taskB) => taskA.date.compareTo(taskB.date));
    return list;
  }

  Future<int> insertTask(Task task) async {
    final db = await this.db;
    return await db.insert(tasksTable, task.toMap());
  }

  Future<int> updateTask(Task task) async {
    final db = await this.db;
    final result = await db.update(
      tasksTable,
      task.toMap(),
      where: '$colId = ?',
      whereArgs: [task.id],
    );
    return result;
  }

  Future<int> deleteTask(Task task) async {
    final db = await this.db;
    return await db.delete(
      tasksTable,
      where: '$colId = ? ',
      whereArgs: [task.id],
    );
  }
}
