import 'package:benden_al/categories/selectCategoryPage.dart';
import 'package:benden_al/others/userAdsPage.dart';
import 'package:benden_al/others/userInboxPage.dart';
import 'package:benden_al/others/selectedAdContent.dart';
import 'package:benden_al/others/chooseNewAdCategory.dart';
import 'package:benden_al/pages/userLoginPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatelessWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final User currentUser = auth.currentUser;
    final currentUserName = currentUser.displayName;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        //backgroundColor: Colors.orangeAccent,
        appBar: AppBar(
          backwardsCompatibility: false,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))),
          systemOverlayStyle:
              SystemUiOverlayStyle(statusBarColor: Colors.blueGrey),
          title: Text('Anasayfa'),
          backgroundColor: Colors.blueGrey,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserInboxPage(),
                      ));
                },
                child: Icon(Icons.email),
              ),
            ),
          ],
        ),
        drawer: Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.white),
          child: Drawer(
            child: ListView(
              children: <Widget>[
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    borderRadius: new BorderRadius.vertical(
                        bottom: new Radius.circular(12.0)),
                    color: Colors.blueGrey,
                  ),
                  accountName: Text(currentUserName),
                  accountEmail: Text(currentUser.email),
                  currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(1.0),
                        child: Image.asset(
                          'assets/images/appicon.png',
                          height: 150.0,
                          width: 100.0,
                        ),
                      )
                      /*Text("A",
                      style: TextStyle(fontSize: 40.0),
                    ),*/
                      ),
                ),
                CustomListTile(Icons.bookmark, "Anasayfa", () {}),
                CustomListTile(Icons.email, "Gelen Kutusu", () {}),
                CustomListTile(Icons.person, "??lanlar??m", () {}),
                CustomListTile(Icons.add, "??lan Ver", () {}),
                CustomListTile(Icons.home, "Emlak", () {}),
                CustomListTile(Icons.directions_car, "Vas??ta", () {}),
                CustomListTile(
                    Icons.architecture, "Yedek Par??a, Aksesuar", () {}),
                CustomListTile(
                    Icons.shopping_cart, "??kinci El - S??f??r Al????veri??", () {}),
                CustomListTile(Icons.logout, "????k????", () {}),
              ],
            ),
          ),
        ),

        body: BodyLayout(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChooseNewAdCategory(),
                ));
            // Add your onPressed code here!
          },
          icon: const Icon(Icons.add),
          label: const Text('??lan Ver'),
          backgroundColor: Colors.blueGrey,
        ),
      ),
    );
  }
}

class BodyLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String currentAdId, dbCollectionName, dbCategoryName;
    return ListView(
      children: <Widget>[
        CustomPadding(Icons.home, "Emlak", "Emlak"),
        CustomPadding(Icons.directions_car, "Vas??ta", "Vas??ta"),
        CustomPadding(
            Icons.architecture, "Yedekparca", "Yedek Par??a, Aksesuar"),
        CustomPadding(
            Icons.shopping_cart, "Ikincisifir", "??kinci El - S??f??r al????veri??"),
        Padding(
          padding: const EdgeInsets.only(top: 3, bottom: 3),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
              color: Colors.blueGrey,
            ),
            child: ListTile(
              title: Text(
                'En Yeni ??lanlara G??z Atabilirsiniz',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Kategoriler')
              .doc('T??m')
              .collection("T??m")
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Text('loading');
            if (snapshot.connectionState == ConnectionState.waiting)
              return CircularProgressIndicator();
            if (snapshot.data.size <= 0) {
              return Container(
                child: Center(
                  child: Text(
                    "??lan Bulunamad??",
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            } else {
              final list = snapshot.data.docs;
              dbCollectionName = "T??m";
              dbCategoryName = "T??m";
              return GridView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      currentAdId = list[index].id;
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SelectedAdContent(currentAdId, dbCollectionName, dbCategoryName),
                          ));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                      margin: EdgeInsets.all(2.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        child: Stack(
                          children: <Widget>[
                            Container(
                              color: Color(0xFFF2F2F2),
                            ),
                            Image.network(list[index]["ilan_resim"],
                                fit: BoxFit.fitHeight, width: 1000),
                            Positioned(
                              bottom: 0.0,
                              left: 0.0,
                              right: 0.0,
                              child: Container(
                                decoration:
                                    BoxDecoration(color: Colors.blueGrey),
                                padding: EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 20.0),
                                child: Text(
                                  list[index]["ilan_baslik"],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                itemCount: list.length,
              );
            }
          },
        ),
      ],
    );
  }
}

class CustomPadding extends StatelessWidget {
  final String dbCategoryName, title;
  final IconData icon;
  CustomPadding(this.icon, this.dbCategoryName, this.title, {Key key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    String categoryPageTileName="";
    if (dbCategoryName == "Emlak") {
      categoryPageTileName = "T??m Emlak ??lanlar??";
    } else if (dbCategoryName == "Vas??ta") {
      categoryPageTileName = "T??m Vas??ta ??lanlar??";
    } else if (dbCategoryName == "Yedekparca") {
      categoryPageTileName = "T??m Yedek Par??a / Aksesuar ??lanlar??";
    } else if (dbCategoryName == "Ikincisifir") {
      categoryPageTileName = "T??m ??kinci El - S??f??r ??lanlar??";
    }
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          color: Color(0xFFF2F2F2),
        ),
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SelectCategoryPage(dbCategoryName, categoryPageTileName),
                ));
          },
        ),
      ),
    );
  }
}

class CustomListTile extends StatelessWidget {
  final IconData icon;
  final String text;
  Function onTap;
  CustomListTile(this.icon, this.text, this.onTap);

  @override
  Widget build(BuildContext context) {
    String catName, tileName;
    if (text == "????k????")
      onTap = () {
        FirebaseAuth.instance.signOut();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => UserLoginPage()),
            ModalRoute.withName("/LoginPage"));
      };
    if (text == "Anasayfa")
      onTap = () {
        Navigator.pop(context);
      };
    else if (text == "Gelen Kutusu")
      onTap = () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserInboxPage(),
            ));
      };
    else if (text == "Emlak")
      onTap = () {
        catName = "Emlak";
        tileName = "T??m Emlak ??lanlar??";
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SelectCategoryPage(catName, tileName)));
      };
    else if (text == "??lanlar??m")
      onTap = () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserAdsPage(),
            ));
      };
    else if (text == "??lan Ver")
      onTap = () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChooseNewAdCategory(),
            ));
      };
    else if (text == "Vas??ta")
      onTap = () {
        catName = "Vas??ta";
        tileName = "T??m Vas??ta ??lanlar??";
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SelectCategoryPage(catName, tileName),
            ));
      };
    else if (text == "Yedek Par??a, Aksesuar")
      onTap = () {
        catName = "Yedekparca";
        tileName = "T??m Yedek Par??a / Aksesuar ??lanlar??";
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SelectCategoryPage(catName, tileName),
            ));
      };
    else if (text == "??kinci El - S??f??r Al????veri??")
      onTap = () {
        catName = "Ikincisifir";
        tileName = "T??m ??kinci El - S??f??r ??lanlar??";
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SelectCategoryPage(catName, tileName),
            ));
      };
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: InkWell(
        splashColor: Colors.white,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            color: Color(0xFFF2F2F2),
          ),
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Icon(icon),
                  ),
                  //Icon(icon),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      text,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ],
              ),
              Icon(Icons.keyboard_arrow_right)
            ],
          ),
        ),
      ),
    );
  }
}
