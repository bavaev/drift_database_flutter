import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 32)();
  TextColumn get lastName => text().withLength(min: 1, max: 32)();
  IntColumn get age => integer()();
  TextColumn get image => text()();
  TextColumn get phone => text()();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}

@DriftDatabase(tables: [Users])
class Database extends _$Database {
  Database() : super(_openConnection());

  Future<int> insertUser(User user) => into(users).insert(user);
  Future updateUser(User user) => update(users).replace(user);
  Future removeUser(User user) => delete(users).delete(user);
  Stream<List<User>> get usersStream => select(users).watch();

  @override
  int get schemaVersion => 1;
}
