import 'dart:math';

import 'package:drift_flutter/data/secure.dart';
import 'package:drift_flutter/edit_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:drift_flutter/data/database.dart';

class ListUsers extends StatefulWidget {
  static const routeName = '/list';
  const ListUsers({Key? key, this.user, this.secure}) : super(key: key);
  final User? user;
  final SecureData? secure;

  @override
  State<ListUsers> createState() => _ListUsersState();
}

class _ListUsersState extends State<ListUsers> {
  late Database _database;
  FlutterSecureStorage? storage;
  Map<String, String> keys = {};

  final _name = TextEditingController();
  final _lastName = TextEditingController();
  final _age = TextEditingController();
  final _phone = TextEditingController();
  final _bankCard = TextEditingController();
  bool loading = false;
  Random rng = Random();

  List<String> images = [
    '1.webp',
    '2.jpeg',
    '3.jpeg',
    '4.jpeg',
    '5.jpeg',
    '6.jpeg',
  ];

  @override
  void initState() {
    super.initState();
    storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: IOSAccessibility.first_unlock,
      ),
    );
    secureData();
    _database = Database();
    if (widget.user != null) {
      updateUser(widget.user as User, widget.secure);
    }
  }

  IOSOptions _getIOSOptions() => const IOSOptions(
        accessibility: IOSAccessibility.first_unlock,
      );

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );

  void secureData() async {
    keys = await storage!.readAll(
      iOptions: _getIOSOptions(),
      aOptions: _getAndroidOptions(),
    );
    setState(() => keys);
  }

  void insertUser(User user, SecureData secure) async {
    await _database.insertUser(user);
    storage!.write(
      key: '${user.id}_user_card_key',
      value: secure.card,
      iOptions: _getIOSOptions(),
      aOptions: _getAndroidOptions(),
    );
    setState(() {
      _name.clear();
      _lastName.clear();
      _age.clear();
      _phone.clear();
      _bankCard.clear();
    });
  }

  void updateUser(User user, SecureData? secure) async {
    await _database.updateUser(user);
    if (secure != null) {
      storage!.write(
        key: '${user.id}_user_card_key',
        value: secure.card,
        iOptions: _getIOSOptions(),
        aOptions: _getAndroidOptions(),
      );
    }
  }

  void removeUser(User user) async {
    await _database.removeUser(user);
    storage?.delete(
      key: '${user.id}_user_card_key',
      aOptions: _getAndroidOptions(),
      iOptions: _getIOSOptions(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _database.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Users'),
      ),
      body: StreamBuilder<List<User>>(
        stream: _database.usersStream,
        builder: (context, users) {
          if (users.hasData) {
            return ListView.builder(
              itemCount: users.data!.length,
              itemBuilder: (context, index) {
                final SecureData userCard = SecureData(
                  id: users.data![index].id.toString(),
                  card: keys['${users.data![index].id.toString()}_user_card_key'] ?? '',
                );
                return Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.white, Colors.grey.shade300]),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        offset: Offset(5, 5),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          'assets/images/${users.data![index].image}',
                          height: 80,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${users.data![index].lastName} ${users.data![index].name}',
                              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${users.data![index].age} years old',
                              style: const TextStyle(fontSize: 30),
                            ),
                            Text(
                              'Phone: ${users.data![index].phone}',
                              style: const TextStyle(fontSize: 25),
                            ),
                            Text(
                              'bank card: ${userCard.card}',
                              style: const TextStyle(fontSize: 25),
                            )
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pushNamed(context, '/edit',
                                arguments: EditUser(
                                  user: users.data![index],
                                  secure: SecureData(id: users.data![index].id.toString(), card: userCard.card),
                                )),
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () => removeUser(users.data![index]),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return SizedBox(
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        const Text(
                          'Name',
                          style: TextStyle(fontSize: 30),
                        ),
                        TextFormField(
                          controller: _name,
                          validator: (value) {
                            if (value == '') return 'Please input Name';
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: "Name*",
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 1)),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          'Lastname',
                          style: TextStyle(fontSize: 30),
                        ),
                        TextFormField(
                          controller: _lastName,
                          validator: (value) {
                            if (value == '') return 'Please input Lastname';
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: "Lastname*",
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 1)),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          'Age',
                          style: TextStyle(fontSize: 30),
                        ),
                        TextFormField(
                          controller: _age,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                          validator: (value) {
                            if (value == '') return 'Please input age';
                            int intValue = int.tryParse(value!) ?? 0;
                            if (intValue < 1) return 'Please input real age';
                            if (intValue > 120) return 'Please input real age';
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: "Age* (min: 1, max: 120)",
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 1)),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          'Phone',
                          style: TextStyle(fontSize: 30),
                        ),
                        TextFormField(
                          controller: _phone,
                          validator: (value) {
                            if (value == '') return 'Please input phone';
                            if (value.toString().length < 6) return 'Please input real phone';
                            if (value.toString().length > 7) return 'Please input real phone';
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: "Phone* (min: 6 digits, max: 7 digits)",
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 1)),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          'Bank Card number',
                          style: TextStyle(fontSize: 30),
                        ),
                        TextFormField(
                          controller: _bankCard,
                          validator: (value) {
                            if (value == '') return 'Please input card';
                            if (value!.length != 8) return 'Please correct card number';
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: "Bank card* (8 digits)",
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 1)),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        ElevatedButton(
                          child: const Padding(
                            padding: EdgeInsets.all(14),
                            child: Text(
                              'Add User',
                              style: TextStyle(fontSize: 30),
                            ),
                          ),
                          onPressed: () => insertUser(
                            User(
                              id: rng.nextInt(1000),
                              name: _name.text.toString(),
                              lastName: _lastName.text.toString(),
                              age: int.parse(_age.text),
                              image: images[rng.nextInt(6)],
                              phone: _phone.text.toString(),
                            ),
                            SecureData(card: _bankCard.text),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
