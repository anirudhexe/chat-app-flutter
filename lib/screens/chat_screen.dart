import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _store=FirebaseFirestore.instance;
User loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = "chat_screen";
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController=TextEditingController();

  String message;

  final _auth = FirebaseAuth.instance;

  @override
  void initState() {

    super.initState();
    getCurrentUser();
  }

  void getCurrentUser()
  {
    try {
      final user = _auth.currentUser;
      if (user != null)
        loggedInUser=user;
        print(loggedInUser.email);
    }
    catch(e)
    {
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('X Chat'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(222,15,162,1),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _store.collection('messages').orderBy('time',descending: false).snapshots(),
              builder: (context,snapshot){
                if(!snapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator(
                    color: Colors.pinkAccent,
                    ),
                  );
                }
                  final messages=snapshot.data.docs.reversed;
                  List<TextBubble>messageBubbles=[];
                  for(var m in messages)
                    {
                      final messageText=m.get('text');
                      final messageSender=m.get('sender');
                      final currentUser=loggedInUser.email;
                      final messageBubble=TextBubble(sender: messageSender,text: messageText,isMe: currentUser==messageSender);
                      messageBubbles.add(messageBubble);
                    }
                  return Expanded(
                    child: ListView(
                      reverse: true,
                      children: messageBubbles,
                    ),
                  );
                }
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        message=value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messageTextController.clear();
                      _store.collection('messages').add({
                        'text':message,
                        'sender':loggedInUser.email,
                        'time': DateTime.now()
                      });
                    },
                    child: Icon(
                      Icons.send,
                      color: Color.fromRGBO(242,51,187,1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class TextBubble extends StatelessWidget {
  TextBubble({this.sender,this.text,this.isMe});
  final String sender,text;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe?CrossAxisAlignment.end:CrossAxisAlignment.start,
        children: [
          Text(sender,style: TextStyle(
            color: Colors.white54,
            fontSize: 12
          ),),
          Material(
            borderRadius: isMe?BorderRadius.only(
                topLeft: Radius.circular(30),
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30)
            ):BorderRadius.only(
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30)
            ),
              color: isMe?Color.fromRGBO(242,51,187,1):Colors.purple,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                child: Text(
                    '$text',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

