import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'homepage.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final String name;
  final String main;
  final String peerId;
  final String chatId;

  const ChatPage({Key key, this.userId, this.name, this.main, this.peerId, this.chatId}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = new TextEditingController();
  final _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    //Firestore.instance.collection("Users").document(widget.userId).updateData({'chattingWith': widget.peerId});
    Firestore.instance.collection("Chats").document(widget.chatId).
      collection(widget.chatId).document(DateTime.now().millisecondsSinceEpoch.toString()).setData({'contents': "Hello"});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chatting")
      ),
      body: Center(
        child:  Scaffold(
          body: new Center (
            child: Column(
              children: <Widget>[
                new Text("USER ID:" + widget.userId.toString() + "\n" + "PEER ID:" + widget.peerId.toString()),
              ],
            )
          ),
          bottomNavigationBar: TextField(
            controller: messageController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'chat', 
            ),
            onSubmitted: (value){
              Firestore.instance.collection("Users").document(widget.peerId).updateData({'message': value});
              messageController.clear();
            },
          ),
        )
      ),
    );
  }
}