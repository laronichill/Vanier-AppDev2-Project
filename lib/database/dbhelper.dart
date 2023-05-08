import './markers.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {

  static final _databasefirst = "markers.db";
  static final _databaseVersion = 1;
  static final table = 'markers_table';

  static final columnid = 'id';
  static final columnlatitude = 'latitude';
  static final columnlongitude = 'longitude';
  static final columntitle = 'title';

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databasefirst);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnid INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnlatitude REAL NOT NULL,
            $columnlongitude REAL NOT NULL,
            $columntitle TEXT NOT NULL
          )
          ''');
  }

  Future<int> insert(Markers markers) async {
    Database db = await instance.database;
    return await db.insert(table, {'latitude': markers.latitude, 'longitude': markers.longitude, 'title': markers.title});
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryRows(title) async {
    Database db = await instance.database;
    return await db.query(table, where: "$columntitle LIKE '%$title%'");
  }

  Future<int?> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  Future<int> update(Markers markers) async {
    Database db = await instance.database;
    int id = markers.toMap()['id'];
    return await db.update(
        table, markers.toMap(), where: '$columnid = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnid = ?', whereArgs: [id]);
  }
  Future<int> deleteAll() async {
    Database db = await instance.database;
    return await db.rawDelete("Delete from $table");
  }
}