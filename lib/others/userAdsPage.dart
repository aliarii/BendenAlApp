import 'package:benden_al/others/editAdInfoPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserAdsPage extends StatelessWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final User currentUser = auth.currentUser;
    final currentUserId = currentUser.uid;
    final FirebaseFirestore storage = FirebaseFirestore.instance;
    return Scaffold(
      appBar: AppBar(
        backwardsCompatibility: false,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))),
        systemOverlayStyle:
            SystemUiOverlayStyle(statusBarColor: Colors.blueGrey),
        title: Text('Aktif İlanlarım'),
        backgroundColor: Colors.blueGrey,
      ),
      body: StreamBuilder(
        stream: storage
            .collection('Kategoriler')
            .doc('Tüm')
            .collection('Tüm')
            .where('ilan_uid', isEqualTo: currentUserId)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Loading...');
          }
          if (snapshot.data.size <= 0) {
            return Container(
              child: Center(
                child: Text(
                  "İlan Bulunamadı",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView(
            children: snapshot.data.docs
                .map(
                  (doc) => Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        //border: Border.all(color: Colors.grey),
                        color: Color(0xFFF2F2F2),
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                          child: Image.network(
                            doc['ilan_resim'],
                            width: 75,
                            height: 50,
                          ),
                        ),
                        title: Text(doc["ilan_baslik"]),
                        subtitle: Container(child: Text(doc["ilan_aciklama"])),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditAdInfoPage(
                                  doc["ilan_baslik"],
                                  doc["ilan_aciklama"],
                                  doc["ilan_kategori"],
                                  doc["ilan_durum"],
                                  doc.id),
                            ),
                          );
                        },
                        trailing: Icon(Icons.edit),
                      ),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}
