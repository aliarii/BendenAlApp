import 'package:benden_al/others/selectedAdContent.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectedCategoryPage extends StatelessWidget {
  final String dbCategoryName, dbCollectionName;

  SelectedCategoryPage(this.dbCategoryName, this.dbCollectionName, {Key key})
      : super(key: key);
  final List<String> images = [];

  @override
  Widget build(BuildContext context) {
    String selectedAdIdNum;
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))),
        title: Text(dbCollectionName + " " + dbCategoryName + " İlanları"),
        backgroundColor: Colors.blueGrey,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Kategoriler')
            .doc(dbCategoryName)
            .collection(dbCollectionName.toString())
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Text('loading');
          if (snapshot.connectionState == ConnectionState.waiting)
            return CircularProgressIndicator();
          else {
            final list = snapshot.data.docs;
            return ListView.builder(
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      color: Color(0xFFF2F2F2),
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        child: Image.network(
                          list[index]['ilan_resim'],
                          width: 75,
                          height: 50,
                        ),
                      ),
                      title: Text(list[index]['ilan_baslik']),
                      subtitle:
                      Text('Fiyat : ' + list[index]['ilan_fiyat'] + ' TL'),
                      trailing: Icon(Icons.keyboard_arrow_right),
                      onTap: () {
                        selectedAdIdNum = list[index].id;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SelectedAdContent(
                                  selectedAdIdNum,
                                  dbCollectionName,
                                  dbCategoryName),
                            ));
                      },
                    ),
                  ),
                );
              },
              itemCount: list.length,
            );
          }
        },
      ),
    );
  }
}
