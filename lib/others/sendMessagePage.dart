import 'package:benden_al/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

class SendMessagePage extends StatefulWidget {
  final String chatRoomId;
  final String currentUserId;
  final String currentUserName;
  final String adOwnerName;

  const SendMessagePage(this.currentUserId, this.chatRoomId,this.currentUserName,this.adOwnerName, {Key key})
      : super(key: key);

  @override
  _SendMessagePage createState() => _SendMessagePage();
}

class _SendMessagePage extends State<SendMessagePage> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();
  CollectionReference _collectionRef;
  @override
  void initState() {
    _collectionRef = FirebaseFirestore.instance
        .collection("conversations/${widget.chatRoomId}/messages");

    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        if (visible) {

          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            curve: Curves.ease,
            duration: Duration(milliseconds: 200),
          );
        }
      },
    );

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final User currentUser = auth.currentUser;
    String barText;
    final currentUserName = currentUser.displayName;
    if(widget.adOwnerName==currentUser.displayName)
      {
        barText= widget.currentUserName;
      }
    else{
       barText= widget.adOwnerName;
    }
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))),
        systemOverlayStyle:
        SystemUiOverlayStyle(statusBarColor: Colors.blueGrey),
        title: Text(barText),
        backgroundColor: Colors.blueGrey,
      ),
      body: Container(

        decoration: BoxDecoration(
          color: Color(0xFFF2F2F2),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder(
                  stream: _collectionRef.orderBy('timeStamp', descending: false).snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    return !snapshot.hasData
                        //? CircularProgressIndicator()
                        ? Container()
                        : ListView(
                      controller: _scrollController,
                      children: snapshot.data.docs.map((doc) => ListTile(
                        title: Align(
                          alignment: currentUser.uid != doc['senderId']
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Colors.blueGrey,
                                borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(10),
                                    right: Radius.circular(10))),
                            child: Text(
                              doc['message'],
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      )
                      ).toList(),

                    );
                  }),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(15),
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      color: Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(12),
                        right: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Icon(Icons.keyboard, color: Colors.grey),
                          ),
                        ),
                        Expanded(
                            child: Container(
                              child: TextField(
                                controller: _controller,
                                decoration: InputDecoration(hintText: "Bir mesaj yaz", border: InputBorder.none),
                              ),
                            )

                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 15),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blueGrey,
                  ),
                  child: InkWell(
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    onTap: () async {
                      _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: Duration(milliseconds: 200),
                          curve: Curves.easeIn,
                      );
                      await _collectionRef.add({
                        'message': _controller.text,
                        'senderId': currentUser.uid,
                        'senderName':currentUserName,
                        'timeStamp': DateTime.now(),

                      });

                      if(widget.currentUserId!=widget.chatRoomId){
                        List<String> users = [widget.currentUserId,widget.chatRoomId, widget.currentUserName, widget.adOwnerName];
                        Map<String, dynamic> conversations = {
                          "members": users,
                          "displayMessage": _controller.text,
                        };
                        DatabaseMethods().addChatRoom(conversations, widget.chatRoomId);
                      }
                      else{
                        List<String> users = [widget.currentUserId,widget.chatRoomId, widget.currentUserName, widget.adOwnerName];
                        Map<String, dynamic> conversations = {
                          "members": users,
                          "displayMessage": _controller.text,
                        };
                        DatabaseMethods().addChatRoom(conversations, widget.chatRoomId);
                      }
                      _controller.text = '';
                    },
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
