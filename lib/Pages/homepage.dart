import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../authentication.dart';
import './friendPage.dart' as friendp;
import './profilePage.dart' as profilep;
import './messagePage.dart' as messagep;
import './matchPage.dart' as matchp;

class HomePage extends StatefulWidget{
  final String userId;
  final BaseAuth auth;
  final VoidCallback logoutCallback;

  HomePage({this.userId, this.auth, this.logoutCallback});

  @override
  HomePageState createState() => new HomePageState();
}

// this class will be used to pass the callback to the tabs created by homepage
class HomePageProvider extends InheritedWidget{
  final String userId;
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final Widget child;

  HomePageProvider(this.userId, this.auth, this.logoutCallback, this.child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  // by using this function to add the call back to the context in the tabstate build,
  // should be able to ref the call back in a tab class
  static HomePageProvider of(BuildContext context) =>
    context.inheritFromWidgetOfExactType(HomePageProvider);

}

class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  TabController controller;

  @override
  void initState() {
    super.initState();
    controller = new TabController(vsync: this, length: 3);
  }

  @override 
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new HomePageProvider(
      widget.userId,
      widget.auth,
      widget.logoutCallback,
      Scaffold( bottomNavigationBar: new Material(
        color: Colors.blue,
        child: 
          TabBar(
          controller: controller,
          tabs: <Tab>[
            new Tab(icon: new Icon(Icons.face)),
            new Tab(icon: new Icon(Icons.pie_chart)),
            new Tab(icon: new Icon(Icons.chat)),
          ]
        ),
      ),
      body: new TabBarView(
        controller: controller,
        children: <Widget>[
          new profilep.ProfilePage(),
          new matchp.MatchPage(),
          new messagep.MessagePage(),
        ]
      ))
    );
      /*
      appBar: new AppBar(
        actions: <Widget>[
          _showForm(),
      ],),
      */
      
    
  }
}