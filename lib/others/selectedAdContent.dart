import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:benden_al/others/sendMessagePage.dart';
import 'package:benden_al/services/database.dart';
import 'package:benden_al/widgets/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'showFulScreenImage.dart';



class SelectedAdContent extends StatefulWidget {
  final String selectedAdIdNum, dbCollectionName, dbCategoryName;

  SelectedAdContent(this.selectedAdIdNum, this.dbCollectionName, this.dbCategoryName, {Key key})
      : super(key: key);

  @override
  _SelectedAdContentState createState() => _SelectedAdContentState();
}

class _SelectedAdContentState extends State<SelectedAdContent> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseMethods databaseMethods = new DatabaseMethods();

  List<String> images = [];

  getChatRoomId(String adOwnerId) {
    return "$adOwnerId";
  }

  sendMessage(String currentUserId, adOwnerId, currentUserName, adOwnerName) {
    List<String> users = [currentUserId, adOwnerId, currentUserName, adOwnerName];

    String chatRoomId = getChatRoomId(adOwnerId);

    Map<String, dynamic> conversations = {
      "members": users,
      "displayMessage": '-',
    };
    databaseMethods.addChatRoom(conversations, chatRoomId);

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              SendMessagePage(currentUserId, chatRoomId, currentUserName, adOwnerName)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User currentUser = auth.currentUser;
    final currentUserId = currentUser.uid;
    final currentUserName = currentUser.displayName;
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))),
        systemOverlayStyle:
            SystemUiOverlayStyle(statusBarColor: Colors.blueGrey),
        title: Text(widget.dbCategoryName),
        backgroundColor: Colors.blueGrey,
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('Kategoriler')
              .doc(widget.dbCategoryName.toString())
              .collection(widget.dbCollectionName.toString())
              .doc(widget.selectedAdIdNum)
              .snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData) return Text('loading');
            if (snapshot.connectionState == ConnectionState.waiting)
              return CircularProgressIndicator();
            else {
              final dbAdData = snapshot.data;
              images = List.from(dbAdData.get('ilan_resimler'));
              String adOwnerId, adOwnerName;
              return ListView(
                children: <Widget>[
                  Container(
                    child: CarouselSlider.builder(
                      itemCount: images.length,
                      options: CarouselOptions(
                        height: 210,
                        autoPlay: false,
                        aspectRatio: 2.0,
                        enlargeCenterPage: false,
                      ),
                      itemBuilder: (context, index, realIdx) {
                        int imageIndex = images.indexOf(images[index]);
                        return Container(
                          margin: EdgeInsets.all(1.0),
                          child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    color: Colors.black12,
                                    child: GestureDetector(
                                      child: Image.network(images[index],
                                          fit: BoxFit.fitHeight, width: 1000),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            opaque: false,
                                            barrierColor: Colors.black,
                                            pageBuilder:
                                                (BuildContext context, _, __) {
                                              return FullScreenPage(
                                                child: Image.network(
                                                    images[index]),
                                                dark: true,
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0.0,
                                    left: 0.0,
                                    right: 0.0,
                                    child: Container(
                                      decoration:
                                          BoxDecoration(color: Colors.blueGrey),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 20.0),
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            (imageIndex + 1).toString() +
                                                '. Resim',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 100.0),
                                            child: Text(
                                              'Büyük Resim',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 1),
                                            child: InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    PageRouteBuilder(
                                                      opaque: false,
                                                      barrierColor:
                                                          Colors.black,
                                                      pageBuilder:
                                                          (BuildContext context,
                                                              _, __) {
                                                        return FullScreenPage(
                                                          child: Image.network(
                                                              images[index]),
                                                          dark: true,
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                                child: Icon(
                                                  Icons.zoom_in,
                                                  color: Colors.white,
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        );
                      },
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 15, top: 10),
                      child: Text("İlan Başlık",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              height: 2,
                              fontSize: 20,
                              leadingDistribution:
                                  TextLeadingDistribution.even))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          color: Color(0xFFF2F2F2),
                        ),
                        child: Text(
                          dbAdData.get('ilan_baslik'),
                          style: TextStyle(
                              fontSize: 15,
                              leadingDistribution:
                                  TextLeadingDistribution.even),
                        )),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text("Açıklama",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              height: 2,
                              fontSize: 20,
                              leadingDistribution:
                                  TextLeadingDistribution.even))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          color: Color(0xFFF2F2F2),
                        ),
                        child: Text(
                          dbAdData.get('ilan_aciklama'),
                          style: TextStyle(
                              fontSize: 15,
                              leadingDistribution:
                                  TextLeadingDistribution.even),
                        )),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text("Durum",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              height: 2,
                              fontSize: 20,
                              leadingDistribution:
                                  TextLeadingDistribution.even))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          color: Color(0xFFF2F2F2),
                        ),
                        child: Text(
                          dbAdData.get('ilan_durum'),
                          style: TextStyle(
                              fontSize: 15,
                              leadingDistribution:
                                  TextLeadingDistribution.even),
                        )),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text("Fiyat",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              height: 2,
                              fontSize: 20,
                              leadingDistribution:
                                  TextLeadingDistribution.even))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          color: Color(0xFFF2F2F2),
                        ),
                        child: Text(
                          dbAdData.get('ilan_fiyat'),
                          style: TextStyle(
                              fontSize: 15,
                              leadingDistribution:
                                  TextLeadingDistribution.even),
                        )),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text("İletişim",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              height: 2,
                              fontSize: 20,
                              leadingDistribution:
                                  TextLeadingDistribution.even))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          color: Color(0xFFF2F2F2),
                        ),
                        child: Text(
                          dbAdData.get('ilan_iletisim'),
                          style: TextStyle(
                              fontSize: 15,
                              leadingDistribution:
                                  TextLeadingDistribution.even),
                        )),
                  ),
                  if (dbAdData.get("ilan_uid") != currentUserId)
                    CustomBtn(
                      text: "Mesaj Gönder",
                      onPressed: () {
                        showDialog<String>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text(""),
                                content: const Text(
                                    'İlan sahibine mesaj göndermek istiyor musunuz?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, 'Vazgeçtim');
                                    },
                                    child: const Text('Vazgeçtim'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, 'Evet');
                                      adOwnerId = dbAdData.get("ilan_uid");
                                      adOwnerName =
                                          dbAdData.get("ilan_sahip_name");
                                      sendMessage(currentUserId, adOwnerId, currentUserName,
                                          adOwnerName);
                                    },
                                    child: const Text('Evet'),
                                  ),
                                ],
                              );
                            });
                      },
                    )
                  else
                    CustomBtn(
                      text: "İlan Sahibisiniz!",
                    )
                ],
              );
            }
          }),
    );
  }
}
