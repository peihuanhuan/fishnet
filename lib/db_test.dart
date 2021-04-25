import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'beans.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final Future<Database> database = openDatabase(
    join(await getDatabasesPath(), 'grid.db'),
    onCreate: (db, version) {
      print('调用 onCreate');
      db.execute(
        "create table variety(id integer primary key autoincrement, code varchar(32), name varchar(64), create_time datetime default current_timestamp not null);",
      );
      db.execute(
        "create table variety_grid(id integer primary key autoincrement, variety_id bigint,grid_id bigint);",
      );
      db.execute(
        "create table grid(id integer primary key autoincrement, level float, buy_id bigint, sell_id bigint, tag varchar(64));",
      );
      db.execute(
        "create table trade(id integer primary key autoincrement, num float, number int, time datetime default current_timestamp  not null);",
      );
    },
    version: 1,
  );
  Future<void> insertDog(Variety variety) async {
    final Database db = await database;
    await db.insert(
      'variety',
      variety.toDbJson(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  Future<List<Map>> dogs() async {
    final Database db = await database;
    // Query the table for all The Dogs (查询数据表，获取所有的狗狗们)
    final List<Map<String, dynamic>> maps = await db.query('variety');
    // Convert the List<Map<String, dynamic> into a List<Dog> (将 List<Map<String, dynamic> 转换成 List<Dog> 数据类型)
    return List.generate(maps.length, (i) {
      return maps[i];
    });
  }

  // Future<void> updateDog(Dog dog) async {
  //   final db = await database;
  //   await db.update(
  //     'dogs',
  //     dog.toMap(),
  //     where: "id = ?",
  //     whereArgs: [dog.id],
  //   );
  // }
  //
  // Future<void> deleteDog(int id) async {
  //   final db = await database;
  //   await db.delete(
  //     'dogs',
  //     where: "id = ?",
  //     whereArgs: [id],
  //   );
  // }

  print('执111行');
  var fido = Variety('Fido', '3');
  await insertDog(fido);
  // Print the list of dogs (only Fido for now) [打印一个列表的狗狗们 (现在列表里只有一只叫 Fido 的狗狗)]
  // Update Fido's age and save it to the database (修改数据库中 Fido 的年龄并且保存)
  // await updateDog(fido);
  // Print Fido's updated information (打印 Fido 的修改后的信息)
  // Delete Fido from the database (从数据库中删除 Fido)
  // await deleteDog(fido.id);
  // Print the list of dogs (empty) [打印一个列表的狗狗们 (这里已经空了)]
  print(await dogs());
}

