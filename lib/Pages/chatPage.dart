import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:matchup/bizlogic/User.dart';
import 'package:matchup/bizlogic/message.dart';
import 'package:matchup/bizlogic/constants.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final User user;
  final DocumentSnapshot peer;
  final String chatId;

  const ChatPage(
      {Key key, this.user, this.peer, this.chatId})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  final FocusNode focusNode = new FocusNode();

  Message _message;
  var listMessage;

  @override
  void initState() {
    super.initState();
    // messages are from to the peer from the user
    _message = new Message("", widget.peer.documentID, widget.user.getUserId);
  }

  // idea for messaging structure from flutter community guide
  // https://medium.com/flutter-community/building-a-chat-app-with-flutter-and-firebase-from-scratch-9eaa7f41782e
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: buildPeerInfo(),
      ),
      body: GestureDetector(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            buildMessageList(context),
            buildMessageInputContainer(context)
          ],
        ),
        onTap: (){
          FocusScope.of(context).requestFocus(new FocusNode());
        },
      )
    );
  }

  Widget buildPeerInfo(){
    return Row(children: <Widget>[
      // puts the image of the users main left of their name
      Container(
        child: Image.asset(nameMap[widget.peer["Main"]], cacheWidth: 30, cacheHeight: 30,),
        padding: EdgeInsets.only(right: 10),
      ),
      // places text for the Username in between main and secondary
      Expanded(
        child: Center(
          child: Text(widget.peer["Username"]), 
        )
      ),
      // puts the image of the users secondary right of their name
      Container(
        child: Image.asset(nameMap[widget.peer["Secondary"]], cacheWidth: 30, cacheHeight: 30,),
        padding: EdgeInsets.only(
          left: 10,
          right: 50),
      ),
      ],
    );
  }

  Widget snapshotError(AsyncSnapshot snapshot){
    return Center(
      child: Container(
        child: Text(
          "uh oh, an error occurred retrieving the Firebase snapshot:\n ${snapshot.error}",
          style: TextStyle(color: Colors.red),
        ),
      )
    );
  }

  Widget loadingCircle(){
    return Center(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                Colors.lightBlue)));
  }

  Widget buildMessageList(BuildContext context){
    return Expanded(
      child: StreamBuilder(
        stream: Firestore.instance
            .collection("Chats")
            .document(widget.chatId)
            .collection(widget.chatId)
            .orderBy('timeStamp', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError){
            return snapshotError(snapshot);
          }
          else if (!snapshot.hasData) {
            return loadingCircle();
          } 
          else {
            listMessage = snapshot.data.documents;
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) =>
                buildMessageBoxes(index, snapshot.data.documents[index]),
              itemCount: snapshot.data.documents.length,
              controller: listScrollController,
              scrollDirection: Axis.vertical,
              reverse: true,
              shrinkWrap: true,
            );
          }
        },
      ),
      flex: 3
    );
  }

  // building messages
  // arguments are the index of the current item being built obtained from listBuilder
  // and document is the snapshot of the current message log for the given chatId
  // if the fromId of the message is the current users, the message displays on right
  // otherwise, the fromId is from the peerId and appears on left
  Widget buildMessageBoxes(int index, DocumentSnapshot document) {
    if (document['fromId'] == widget.user.getUserId) {
      // Right (my message)
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
        // Text
        Container(
          child: Text(
            document['content'],
            style: TextStyle(color: Colors.white),
          ),
          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
          width: 175.0,
          decoration: BoxDecoration(
              color: Colors.blue[400],
              borderRadius: BorderRadius.circular(8.0)),
          margin: EdgeInsets.only(
              bottom: isLastMessageRight(index) ? 20.0 : 10.0,
          ),
        )
      ]);
    } 
    else {
      String timeStamp = document['timeStamp'];
      // row for left side messages - from peer
      return Row(
        children: <Widget>[
          Container(
            // column containing message box and timestamp
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // message box
                Container(
                  child: Text(
                    document['content'],
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 175.0,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8.0)),
                ),
                buildMessageTimeStamp(timeStamp),
              ]
            ),
            margin: EdgeInsets.only(
                bottom: isLastMessageRight(index) ? 20.0 : 10.0),
          )
        ]
      );
    }
  }

  Widget buildMessageTimeStamp(String timeStamp){
    // time stamp
    return Container(
      child: Text(
          DateFormat('dd MMM').add_jm()
          .format(DateTime.fromMillisecondsSinceEpoch(int.parse(timeStamp))),
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 12.0,
          )
        ),
      padding: EdgeInsets.only(left: 10),
    );
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] == widget.user.getUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] != widget.user.getUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  // container that holds send message button and message input field 
  Widget buildMessageInputContainer(BuildContext context){
    return Container(
      child: Row(
        children: <Widget>[
          buildSendFriendCodeButton(context),
          buildMessageInput(context),
          buildSendButton(),
        ],),
      padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
      decoration: new BoxDecoration(
        border: new Border(top: new BorderSide(color: Colors.grey[100], width: 0.5)),
        color: Colors.grey[300]
      ),
    );
  }

  Widget buildSendFriendCodeButton(BuildContext context){
    return Flexible(
      child: Material(
        child: IconButton(
          color: Colors.lightBlue,
          onPressed: (){
            _message.setContent = widget.user.getFriendCode;
            sendMessage();
          },
          icon: Icon(
            Icons.videogame_asset
          )
        ),
        color: Colors.grey[300],
      ),
      flex: 1,
    );
  }

  Widget buildMessageInput(BuildContext context){
    return Flexible(
        child: TextField(
        controller: messageController,
        minLines: 1,
        maxLines: 5,
        keyboardType: TextInputType.multiline,
        //textInputAction: TextInputAction.done,
        decoration: InputDecoration.collapsed(
          hintText: 'Send a message...',
        ),
        focusNode: focusNode,
        onSubmitted: (messageContents) {
        },
      ),
      flex: 6,
    );
  }

  Widget buildSendButton(){
    return Flexible(
      child: Material(
        child: IconButton(
          color: Colors.lightBlue,
          onPressed: (){
            _message.setContent = messageController.text;
            sendMessage();
            messageController.clear();
          },
          icon: Icon(
            Icons.send
          )
        ),
        color: Colors.grey[300],
      ),
      flex: 1,
    );
  }

  // receives a message with updated contents when the chat box is submitted
  // creates a message document using a time stamp to ensure uniqueness in the given chatId
  void sendMessage() {
    if (_message.getContent != "") {
      DocumentReference messageReference = Firestore.instance
          .collection("Chats")
          .document(widget.chatId)
          .collection(widget.chatId)
          .document(_message.getTimeStamp);

      // this method allows for an asyncrhonous write to occur without the whole function being async
      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(messageReference, {
          'content': _message.getContent,
          'toId': _message.getToId,
          'fromId': _message.getFromId,
          'timeStamp': _message.getTimeStamp,
        });
      });
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }
}