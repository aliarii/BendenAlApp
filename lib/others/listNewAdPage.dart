import 'dart:async';
import 'dart:io';
import 'package:benden_al/pages/homePage.dart';
import 'package:benden_al/widgets/custom_button.dart';
import 'package:benden_al/widgets/custom_ilan_input.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

final List<String> adInfo = [];



class ListNewAdPage extends StatefulWidget {

  final String dbCollectionName;

  ListNewAdPage(this.dbCollectionName);
  @override
  State<StatefulWidget> createState() {
    adInfo.clear();
    adInfo.add(dbCollectionName);
    return _ListNewAdPage();
  }
}
class _ListNewAdPage extends State<ListNewAdPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  String dropdownValue = 'Kiralık';
  bool checkedValueRent = false;
  bool checkedValueSell = false;
  bool checkedValueNew = false;
  bool checkedValueUsed = false;
  String _adTitle,_adCondition,_adComment,_adPrice,_adContact,_currentUserId,_bos;
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseFirestore _fireStoreRef = FirebaseFirestore.instance;
  List<Asset> images = <Asset>[];

  List<File> _files = [];
  Widget buildGridView() {
    return Container(
        margin: EdgeInsets.only(top: 10, left: 10.0, right: 10.0, bottom: 10),
        decoration: BoxDecoration(
            color: Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(12.0)),
        child: GridView.count(
          padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 5, bottom: 5),
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          crossAxisCount: 5,
          children: List.generate(images.length, (index) {
            Asset asset = images[index];
            return AssetThumb(
              asset: asset,
              width: 300,
              height: 300,
            );
          }),
        ));
  }
  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    String _error = 'No Error Detected';
    String error = 'No Error Detected';
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#FF607D8B",
          actionBarTitle: "Resim Seç",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }
    List<File> files = [];
    for (Asset asset in resultList) {
      final filePath =
      await FlutterAbsolutePath.getAbsolutePath(asset.identifier);
      files.add(File(filePath));
    }
    if (!mounted) return;
    setState(() {
      images = resultList;
      _files = files;
      _error = error;
    });
  }
  void getCurrentUser() {
    final User currentUser = auth.currentUser;
    final currentUserId = currentUser.uid;
    _currentUserId = currentUserId.toString();
  }
  Future uploadMultipleImages() async {
    final User currentUser = auth.currentUser;
    final currentUserName = currentUser.displayName;
    List<String> _imageUrls = <String>[];
    String _adImage;
    try {
      for (int i = 0; i < _files.length; i++) {
        final FirebaseStorage storage = FirebaseStorage.instance;
        String fileName = _files[i].toString();
        Reference ref =
        storage.ref().child(_currentUserId.toString()).child("$fileName");
        final UploadTask uploadTask = ref.putFile(_files[i]);

        await uploadTask;
        String imageUrl = await ref.getDownloadURL();
        _imageUrls.add(imageUrl);
      }
      _adImage = _imageUrls[0];
      //ilan durumuna ekle(satılık,kiralık vb.)
      await _fireStoreRef
          .collection("Kategoriler")
          .doc(adInfo[0])
          .collection(adInfo[2])
          .doc(_adTitle+"_"+_adComment+"_"+_currentUserId)
          .set({
        "ilan_aciklama": _adComment,
        "ilan_baslik": _adTitle,
        "ilan_durum": _adCondition,
        "ilan_fiyat": _adPrice,
        "ilan_iletisim": _adContact,
        "ilan_resim": _adImage,
        "ilan_uid": _currentUserId,
        "ilan_resimler": _imageUrls,
        "ilan_kategori": widget.dbCollectionName,
        "ilan_sahip_name": currentUserName,
      });
      //Tüm ilanları tek bir yere ekleme
      await _fireStoreRef
          .collection("Kategoriler")
          .doc("Tüm")
          .collection("Tüm")
          //.doc(category[category.length - 1])
          .doc(_adTitle+"_"+_adComment+"_"+_currentUserId)
          .set({
        "ilan_aciklama": _adComment,
        "ilan_baslik": _adTitle,
        "ilan_durum": _adCondition,
        "ilan_fiyat": _adPrice,
        "ilan_iletisim": _adContact,
        "ilan_resim": _adImage,
        "ilan_uid": _currentUserId,
        "ilan_resimler": _imageUrls,
        "ilan_kategori": widget.dbCollectionName,
        "ilan_sahip_name": currentUserName,
      });
      //Kategorinin Tüm ilanlara ekle
      await _fireStoreRef
          .collection("Kategoriler")
          .doc(adInfo[0])
          .collection("Tüm")
          //.doc(category[category.length - 1])
          .doc(_adTitle+"_"+_adComment+"_"+_currentUserId)
          .set({
        "ilan_aciklama": _adComment,
        "ilan_baslik": _adTitle,
        "ilan_durum": _adCondition,
        "ilan_fiyat": _adPrice,
        "ilan_iletisim": _adContact,
        "ilan_resim": _adImage,
        "ilan_uid": _currentUserId,
        "ilan_resimler": _imageUrls,
        "ilan_kategori": widget.dbCollectionName,
        "ilan_sahip_name": currentUserName,
      });
    } catch (e) {
      print(e);
    }
  }

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
          title: Text('İlan Bilgileri'),
          backgroundColor: Colors.blueGrey,
          actions: <Widget>[
            new IconButton(
                icon: new Icon(Icons.close),
                onPressed: () => Navigator.pop(context)

            ),
          ],
        ),
        body: ListView(
          shrinkWrap: true,
          physics: ScrollPhysics(),
          children: <Widget>[
            new Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("\n\n İlan Başlığı"),
                  CustomIlanInput(
                    hintText: "İlan Başlığı Girin",
                    textInputAction: TextInputAction.next,
                    onChanged: (value) {
                      _adTitle = value;
                    },
                    onHeight: 50.0,
                  ),
                  Text("Durum"),
                  Padding(
                    padding: EdgeInsets.zero,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Checkbox(
                          value: checkedValueRent,
                          onChanged: (newValue) {
                            setState(() {
                              checkedValueRent = newValue;
                              _adCondition = "Kiralık";
                            });
                          },
                        ),
                        Text("Kiralık"),
                        Checkbox(
                          value: checkedValueSell,
                          onChanged: (newValueTwo) {
                            setState(() {
                              checkedValueSell = newValueTwo;
                              _adCondition = "Satılık";
                            });
                          },
                        ),
                        Text("Satılık"),
                        Checkbox(
                          value: checkedValueNew,
                          onChanged: (newValueThree) {
                            setState(() {
                              checkedValueNew = newValueThree;
                              _adCondition = "Sıfır";
                            });
                          },
                        ),
                        Text("Sıfır"),
                        Checkbox(
                          value: checkedValueUsed,
                          onChanged: (newValueFour) {
                            setState(() {
                              checkedValueUsed = newValueFour;
                              _adCondition = "Ikinci";
                            });
                          },
                        ),
                        Text("İkinci El"),
                      ],
                    ),
                  ),
                  Text('Açıklama'),
                  CustomIlanInput(
                    hintText: "Açıklama Girin",
                    textInputAction: TextInputAction.next,
                    onChanged: (value) {
                      _adComment = value;
                    },
                    onHeight: 125,
                  ),
                  Text('Fiyat'),
                  CustomIlanInput(
                    hintText: "Fiyat Girin",
                    textInputAction: TextInputAction.next,
                    onChanged: (value) {
                      _adPrice = value;
                    },
                    onHeight: 50,
                  ),
                  Text('İletişim'),
                  CustomIlanInput(
                    hintText: "İletişim Bilgileri",
                    onChanged: (value) {
                      _adContact = value;
                    },
                    onHeight: 50.0,
                  ),
                ],
              ),
            ),
            new Container(
              height: 360,
              width: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Görsel Ekle'),
                  CustomBtn(
                    text: "Resim Seç",
                    onPressed: loadAssets,
                  ),
                  Expanded(
                    child: buildGridView(),
                  ),
                  CustomBtn(
                    text: "İlan Ver",
                    onPressed: () {
                      if(_adTitle==null||_adCondition==null||_adComment==null||_adPrice==null||_adContact==null){
                        showDialog(
                            context: context,
                            builder: (context) {
                              Future.delayed(Duration(seconds: 2), () {
                                Navigator.pop(context);
                              });
                              return AlertDialog(
                                title: Text('Tüm alanları doldurun!', textAlign: TextAlign.center,),
                              );
                            });
                      }
                      else{
                        adInfo.add(_adTitle);
                        adInfo.add(_adCondition);
                        adInfo.add(_adComment);
                        adInfo.add(_adPrice);
                        adInfo.add(_adContact);
                        getCurrentUser();
                        adInfo.add(_currentUserId);
                        adInfo.add(_bos);
                        uploadMultipleImages();
                        showDialog(
                            context: context,
                            builder: (context) {
                              Future.delayed(Duration(seconds: 2), () {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomePage()
                                    ),
                                    ModalRoute.withName("/HomePage")
                                );
                              });
                              return AlertDialog(
                                title: Text('İlan başarıyla eklendi!', textAlign: TextAlign.center,),
                              );
                            });
                        //category.clear();
                      }
                    },
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

