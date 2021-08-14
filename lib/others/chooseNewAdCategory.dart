import 'package:benden_al/others/listNewAdPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

final List<String> category = [];
final FirebaseAuth auth = FirebaseAuth.instance;
String goPageIlan;

class ChooseNewAdCategory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))),
          systemOverlayStyle:
          SystemUiOverlayStyle(statusBarColor: Colors.blueGrey),
          title: Text('İlan Kategorisini Seç'),
          backgroundColor: Colors.blueGrey,
          actions: <Widget>[
            new IconButton(
                icon: new Icon(Icons.close),
                onPressed: () => Navigator.pop(context)
            ),
          ],
        ),
        body: ListView(
          children: <Widget>[
            CustomPadding(Icons.home, "Emlak", "Emlak"),
            CustomPadding(Icons.directions_car, "Vasıta", "Vasıta"),
            CustomPadding(Icons.architecture, "Yedek Parça, Aksesuar", "Yedekparca"),
            CustomPadding(Icons.shopping_cart, "İkinci El - Sıfır", "Ikincisifir"),
          ],
        ),
      ),
    );
  }
}
class CustomPadding extends StatelessWidget {
  final String dbCategoryName, dbCollectionName;
  final IconData icon;
  CustomPadding(this.icon, this.dbCategoryName, this.dbCollectionName, {Key key}): super(key: key);
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
          leading: Icon(icon),
          title: Text(dbCategoryName),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListNewAdPage(dbCollectionName),
                ));
          },
        ),
      ),
    );
  }
}
