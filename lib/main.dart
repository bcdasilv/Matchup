import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:matchup/bizlogic/User.dart';
import 'package:matchup/bizlogic/screenSize.dart';
import 'Pages/rootPage.dart';
import 'bizlogic/authentication.dart';
import 'package:provider/provider.dart';


// tutorial followed: https://medium.com/flutterpub/flutter-how-to-do-user-login-with-firebase-a6af760b14d5
// credit: David Cheah at FlutterPub
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<BaseAuth>(create: (context) => Auth()),
        Provider<User>(create: (context) => User())
      ],
      child: MaterialApp(
        title: 'Matchup',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new RootPage(),
      )
    );
  }
}




