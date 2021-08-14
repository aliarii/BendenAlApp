import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:benden_al/others/sendMessagePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserInboxPage extends StatelessWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    final User currentUser = auth.currentUser;
    final currentUserId = currentUser.uid;
    return Scaffold(
      appBar: AppBar(
        backwardsCompatibility: false,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))),
        systemOverlayStyle:
        SystemUiOverlayStyle(statusBarColor: Colors.blueGrey),
        title: Text('Gelen Kutusu'),
        backgroundColor: Colors.blueGrey,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('conversations')
            .where('members', arrayContains: currentUserId)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Loading...');
          }
          if (snapshot.data.size<=0){
            return Container(
              child: Center(
                child: Text(
                  "Mesaj Kutusu Boş",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if(snapshot.data.docs.last.get("members")[3]!=currentUser.displayName){
            return ListView(
              children: snapshot.data.docs
                  .map(
                    (doc) => Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      color: Color(0xFFF2F2F2),
                    ),
                    child: ListTile(
                      leading: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.person_rounded),
                      ),
                      title: Text(doc["members"][3]),
                      subtitle:
                      Container(child: Text("Mesaj: "+doc["displayMessage"].toString())),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SendMessagePage(currentUserId, doc.id,doc["members"][2],doc["members"][3]),
                          ),
                        );
                      },
                      trailing: Icon(Icons.keyboard_arrow_right),
                    ),
                  ),
                ),
              ).toList(),
            );
          }
          else{
            return ListView(
              children: snapshot.data.docs
                  .map(
                    (doc) => Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      color: Color(0xFFF2F2F2),
                    ),
                    child: ListTile(
                      leading: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.person_rounded),
                      ),
                      title: Text(doc["members"][2]),
                      subtitle:
                      Container(child: Text("Mesaj: "+doc["displayMessage"].toString())),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SendMessagePage(doc["members"][0], doc["members"][1],doc["members"][2],doc["members"][3]),
                          ),
                        );
                      },
                      trailing: Icon(Icons.keyboard_arrow_right),
                    ),
                  ),
                ),
              ).toList(),
            );
          }
        },
      ),
    );
  }
}
