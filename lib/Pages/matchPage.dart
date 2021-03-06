import 'dart:async';

import 'dart:collection';
import 'package:matchup/Widgets/loadingCircle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:matchup/bizlogic/peer.dart';
import 'package:matchup/bizlogic/User.dart';
import 'package:matchup/Pages/filterPopupForm.dart' as fpf;
import 'package:matchup/bizlogic/constants.dart' as con;


class MatchPage extends StatefulWidget {
  @override
  MatchPageState createState() => MatchPageState();
}



class MatchPageState extends State<MatchPage>{
  Future<void> _refreshMatchPage()
  {
    Future<bool> res = Future.value(true);
    setState((){

    });
    return res;
  }
  
  // main = 0
  // region = 1
  // skill = 2
  List<String> filters = List<String>(3);

  @override
  Widget build(BuildContext context) {

    final User _user = Provider.of<User>(context);
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Center(child: Text("MatchList")),
        leading: IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () {
            filters[0] = "";
            filters[1] = "";
            filters[2] = "";
            setState(() {});
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.filter_list),
            key: Key('filter'),
            onPressed: () {
              showPopup(context, widget, 'Filters');
            },
          ),
        ],
      ),
      body: new FutureBuilder<List<Peer>>(
        future: _getUsers(_user, filters),
        builder: (BuildContext context, AsyncSnapshot<List<Peer>> snapshot) {
          if (snapshot.hasError)
            return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting: return LoadingCircle.loadingCircle();
          default: 
            return new ListView.separated(
              itemBuilder: (BuildContext context, int index) {
                return ListTile (
                  title: new Text(
                    snapshot.data[index].getUserName,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: new Image(
                    image: AssetImage(con.Constants.minSpritesMap[snapshot.data[index].getMain]),
                    height: 25.0,
                    width: 25.0,
                    alignment: Alignment.centerLeft,
                  ),
                  trailing: new Text(
                    snapshot.data[index].getRegion,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    )
                  ),
                  onTap: (){
                      Peer peer = snapshot.data[index];
                      Navigator.pushNamed(context, "/challenge", 
                      arguments: 
                        <Object>[
                          peer
                        ]
                      );
                    },
                );
              }, 
              separatorBuilder: (BuildContext context, int index) =>  Divider(
                color: Colors.blueGrey,
                indent: 15,
                endIndent: 15,
                thickness: 1.5,
              ), 
              itemCount: snapshot.data.length
            );
          }
        }),
    );
  }

  showPopup(
    BuildContext context,
    Widget widget,
    String title,
  ) async {
    filters = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return fpf.FilterPopupForm();
      }
    );
    setState(() {});
  }

  // retrives and filters users 
  static Future<List<Peer>> _getUsers(User _user, List<String> filters) async {
    CollectionReference ref = Firestore.instance.collection('Users');
    QuerySnapshot userQuery = await ref.getDocuments();
    
    HashMap<String, Peer> userHashMap = new HashMap<String, Peer>();

    userQuery.documents.forEach((document) {
      userHashMap.putIfAbsent(document.documentID, () => new Peer(
        document.documentID, 
        document['Username'], 
        document['Main'], 
        document['Secondary'], 
        document['Region'], 
        document['Skill'])
        );
    });

    userHashMap.remove(_user.getUserId); // removes current user from list
    if(filters != null) {
      if(filters[0] != null) {
        userHashMap.removeWhere((key, value) => 
        value.getMain != filters[0]);
      } 
      if(filters[1] != null) {
        userHashMap.removeWhere((key, value) => 
        value.getRegion != filters[1]);
      } 
      if(filters[2] != null) {
        userHashMap.removeWhere((key, value) => 
        value.getSkill != filters[2]);
      } 
    }
    return userHashMap.values.toList();
  }

}

