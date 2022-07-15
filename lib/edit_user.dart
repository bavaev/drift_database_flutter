import 'package:drift_flutter/data/secure.dart';
import 'package:drift_flutter/list_users.dart';
import 'package:flutter/material.dart';

import 'package:drift_flutter/data/database.dart';
import 'package:flutter/services.dart';

class EditUser extends StatefulWidget {
  static const routeName = '/edit';
  const EditUser({Key? key, required this.user, this.secure}) : super(key: key);
  final User user;
  final SecureData? secure;

  @override
  State<EditUser> createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  TextEditingController? _name;
  TextEditingController? _lastName;
  TextEditingController? _age;
  TextEditingController? _phone;
  TextEditingController? _bankCard;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.user.name);
    _lastName = TextEditingController(text: widget.user.lastName);
    _age = TextEditingController(text: widget.user.age.toString());
    _phone = TextEditingController(text: widget.user.phone);
    _bankCard = TextEditingController(text: widget.secure!.card);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/${widget.user.image}',
                    height: 150,
                  ),
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
                    onChanged: (String value) => setState(() {
                      _name = TextEditingController(text: value);
                      _name!.selection = TextSelection.fromPosition(TextPosition(offset: _name!.text.length));
                    }),
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
                  widget.secure != null
                      ? Column(
                          children: [
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
                              onChanged: (String value) => setState(() {
                                _bankCard = TextEditingController(text: value);
                                _bankCard!.selection = TextSelection.fromPosition(TextPosition(offset: _bankCard!.text.length));
                              }),
                            ),
                          ],
                        )
                      : const SizedBox(),
                  const SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                      child: const Padding(
                        padding: EdgeInsets.all(14),
                        child: Text(
                          'Edit User',
                          style: TextStyle(fontSize: 30),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/list',
                          arguments: ListUsers(
                            user: User(
                              id: widget.user.id,
                              image: widget.user.image,
                              name: _name!.text,
                              lastName: _lastName!.text,
                              age: int.parse(_age!.text),
                              phone: _phone!.text,
                            ),
                            secure: SecureData(id: widget.secure!.id, card: _bankCard!.text),
                          ),
                        );
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
