import 'package:drift_flutter/edit_user.dart';
import 'package:flutter/material.dart';

import 'list_users.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drift',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case ListUsers.routeName:
            ListUsers args = settings.arguments as ListUsers;
            return MaterialPageRoute(
              builder: (BuildContext context) {
                return ListUsers(
                  user: args.user,
                  secure: args.secure,
                );
              },
            );
          case EditUser.routeName:
            EditUser args = settings.arguments as EditUser;
            return MaterialPageRoute(builder: (BuildContext context) {
              return EditUser(
                user: args.user,
                secure: args.secure,
              );
            });
          default:
            return MaterialPageRoute(
              builder: (BuildContext context) {
                return const ListUsers(
                  user: null,
                );
              },
            );
        }
      },
    );
  }
}
