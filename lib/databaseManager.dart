// ignore_for_file: non_constant_identifier_names, file_names, no_leading_underscores_for_local_identifiers
import 'dart:convert';

// ignore: no_leading_underscores_for_library_prefixes, depend_on_referenced_packages
import 'package:path/path.dart' as _path;
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

class CapitalPreset{
  final int? presetID;
  final String presetName;
  final List<String> capitalCities;

  CapitalPreset({ this.presetID, required this.presetName, required this.capitalCities });

  factory CapitalPreset.fromMap(Map<String, dynamic> _json) => CapitalPreset(
    presetID: _json['presetID'],
    presetName: _json['presetName'],
    capitalCities: List<String>.from(json.decode(_json['capitals'])),
  );

  Map<String, dynamic> toMap(){
    return {
      'presetID': presetID,
      'presetName': presetName,
      'capitals': capitalCities,
    };
  }
}

class DatabaseManager{
  DatabaseManager._privateConstructor();
  static final DatabaseManager instance = DatabaseManager._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase(); //if database doesnt exist, initialize db, else use the exsiting db

  Future<Database> _initDatabase() async{
    var databasesPath = await getDatabasesPath();
    String path = _path.join(databasesPath, 'capitalcityguesser.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
 
  // For testing purposes
  // Future<void> deleteDatabase() async {
  //   var databasesPath = await getDatabasesPath();
  //   String path = _path.join(databasesPath, 'flagguesser.db');

  //   await databaseFactory.deleteDatabase(path);
  // }

  // For testing purposes
  // Future<bool> existsDatabase() async {
  //   var databasesPath = await getDatabasesPath();
  //   String path = _path.join(databasesPath, 'flagguesser.db');
  //   print(path);
  //   return await databaseFactory.databaseExists(path);
  // }

  Future _onCreate(Database db, int version) async{
    await db.execute('''
      CREATE TABLE CapitalCityPresets(
        presetID INTEGER PRIMARY KEY,
        presetName TEXT,
        capitals TEXT
      );
    ''');

    await db.execute('''
      INSERT INTO CapitalCityPresets VALUES(1, 'CustomPreset1', '');
    ''');
  }

  Future<List<CapitalPreset>> getAllPresets() async { //SELECT * FROM CapitalPresets
    Database db = await instance.database;
    var productsRaw = await db.query('CapitalPresets'); 
    List<CapitalPreset> productsData = productsRaw.isNotEmpty ? productsRaw.map((e) => CapitalPreset.fromMap(e)).toList() : [];
    return productsData;
  }

  Future<int> updateCustomPreset(String countries, int presetID) async {
    Database db = await instance.database;
    try {
      return await db.rawUpdate('UPDATE CapitalCityPresets SET capitals = ? WHERE presetID = ?', [countries, presetID]);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }

      return 0;
    }
  }

  Future<CapitalPreset?> getCapitalsPresetById(int id) async {
    Database db = await instance.database;
    try {
      var resultRaw = await db.rawQuery('SELECT * FROM CapitalCityPresets WHERE presetID = ?', [id]); 
      List<CapitalPreset> result= resultRaw.isNotEmpty ? resultRaw.map((e) => CapitalPreset.fromMap(e)).toList() : [];
      return result.first;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }

      return null;
    }
  }
}