import 'package:benden_al/listpages/selectedCategoryPage.dart';
import 'package:flutter/material.dart';

class SelectCategoryPage extends StatelessWidget {
  final String dbCategoryName, firstTileName;

  SelectCategoryPage(this.dbCategoryName, this.firstTileName, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))),
        title: Text('Kategori Seçimi'),
        backgroundColor: Colors.blueGrey,
      ),
      body: ListView(
        children: <Widget>[
          CustomPadding(Icons.circle, dbCategoryName, firstTileName, "Tüm"),
          CustomPadding(Icons.circle, dbCategoryName, "Satılık", "Satılık"),
          CustomPadding(Icons.circle, dbCategoryName, "Kiralık", "Kiralık"),
          CustomPadding(Icons.circle, dbCategoryName, "Sıfır", "Sıfır"),
          CustomPadding(Icons.circle, dbCategoryName, "İkinci El", "Ikinci"),
        ],
      ),
    );
  }
}

class CustomPadding extends StatelessWidget {
  final String dbCategoryName, tileName, dbCollectionName;

  final IconData icon;

  CustomPadding(
      this.icon, this.dbCategoryName, this.tileName, this.dbCollectionName);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          color: Color(0xFFF2F2F2),
        ),
        child: ListTile(
          leading: Icon(Icons.circle),
          title: Text(tileName),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SelectedCategoryPage(dbCategoryName, dbCollectionName),
                ));
          },
        ),
      ),
    );
  }
}
