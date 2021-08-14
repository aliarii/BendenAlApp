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

final List<String> editAdInfo = [];
final FirebaseAuth auth = FirebaseAuth.instance;


class EditAdInfoPage extends StatefulWidget {

  final String adTitle,adComment,adCategory,adCondition,adId;

  EditAdInfoPage(this.adTitle,this.adComment,this.adCategory,this.adCondition,this.adId);
  @override
  State<StatefulWidget> createState() {
    editAdInfo.clear();
    editAdInfo.add(adCategory);
    return _IlanDuzenlePage();
  }
}
class _IlanDuzenlePage extends State<EditAdInfoPage> {

  String dropdownValue = 'Kiralık';
  bool checkedValueRent = false;
  bool checkedValueSell = false;
  bool checkedValueNew = false;
  bool checkedValueUsed = false;
  String _adTitle,_adCondition,_adComment,_adPrice,_adContact,_currentUserId,_bos;
  bool imageSelected=false;
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
    String _error = 'No Error Detected';
    List<Asset> resultList = <Asset>[];
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
    if(resultList.isEmpty){
      imageSelected=false;
    }
    else{
      imageSelected=true;
    }
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
  Future deleteIlan()async{
    CollectionReference _collectionRef=FirebaseFirestore.instance.collection("Kategoriler");
    Future<void> deleteAd(){
      return _collectionRef
          .doc("Tüm")
          .collection("Tüm")
          .doc(widget.adId).delete();
    }
    Future<void> deleteAdCategory(){
      return _collectionRef
          .doc(widget.adCategory)
          .collection(widget.adCondition)
          .doc(widget.adId).delete();
    }
    Future<void> deleteAdCategoryAll(){
      return _collectionRef
          .doc(widget.adCategory)
          .collection("Tüm")
          .doc(widget.adId).delete();
    }

    deleteAd();
    deleteAdCategory();
    deleteAdCategoryAll();
  }

  Future uploadMultipleImages() async {
    List<String> _imageUrls = <String>[];
    String _image;
    try {
      for (int i = 0; i < _files.length; i++) {
        final FirebaseStorage storage = FirebaseStorage.instance;
        String fileName = _files[i].toString();
        Reference ref =
        storage.ref().child(_currentUserId.toString()).child("$fileName");
        final UploadTask uploadTask = ref.putFile(_files[i]);

        await uploadTask;
        String imageUrl = await ref.getDownloadURL();
        _imageUrls.add(imageUrl); //all all the urls to the list
      }
      _image = _imageUrls[0];

      CollectionReference _collectionRef=FirebaseFirestore.instance.collection("Kategoriler");
      Future<void> deleteAd(){
        return _collectionRef
            .doc("Tüm")
            .collection("Tüm")
            .doc(widget.adId).delete();
      }
      Future<void> deleteAdCategory(){
        return _collectionRef
            .doc(widget.adCategory)
            .collection(widget.adCondition)
            .doc(widget.adId).delete();
      }
      Future<void> deleteAdCategoryAll(){
        return _collectionRef
            .doc(widget.adCategory)
            .collection("Tüm")
            .doc(widget.adId).delete();
      }

      deleteAd();
      deleteAdCategory();
      deleteAdCategoryAll();
      //Tüm ilanlara ekle
      await _fireStoreRef
          .collection("Kategoriler")
          .doc("Tüm")
          .collection("Tüm")
          .doc(_adTitle+"_"+_adComment+"_"+_currentUserId)
          //.doc('${_userId}')
          .set({
        "ilan_aciklama": _adComment,
        "ilan_baslik": _adTitle,
        "ilan_durum": _adCondition,
        "ilan_fiyat": _adPrice,
        "ilan_iletisim": _adContact,
        "ilan_resim": _image,
        "ilan_uid": _currentUserId,
        "ilan_resimler": _imageUrls,
        "ilan_kategori": widget.adCategory,
      });
      //ilan durumuna ekle(satılık,kiralık vb.)
      await _fireStoreRef
          .collection("Kategoriler")
          .doc(editAdInfo[0])
          .collection(editAdInfo[2])
      //.doc(category[category.length - 1])
          .doc(_adTitle+"_"+_adComment+"_"+_currentUserId)
          .set({
        "ilan_aciklama": _adComment,
        "ilan_baslik": _adTitle,
        "ilan_durum": _adCondition,
        "ilan_fiyat": _adPrice,
        "ilan_iletisim": _adContact,
        "ilan_resim": _image,
        "ilan_uid": _currentUserId,
        "ilan_resimler": _imageUrls,
        "ilan_kategori": widget.adCategory,
      });
      //Kategorinin Tüm ilanlara ekle
      await _fireStoreRef
          .collection("Kategoriler")
          .doc(editAdInfo[0])
          .collection("Tüm")
      //.doc(category[category.length - 1])
          .doc(_adTitle+"_"+_adComment+"_"+_currentUserId)
          .set({
        "ilan_aciklama": _adComment,
        "ilan_baslik": _adTitle,
        "ilan_durum": _adCondition,
        "ilan_fiyat": _adPrice,
        "ilan_iletisim": _adContact,
        "ilan_resim": _image,
        "ilan_uid": _currentUserId,
        "ilan_resimler": _imageUrls,
        "ilan_kategori": widget.adCategory,
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
            Container(
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
                  ListTile(
                    title: Row(
                      children: <Widget>[
                        Expanded(
                            child: ElevatedButton(
                                onPressed: () {
                                  showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) {
                                         return AlertDialog(
                                          title: const Text(""),
                                          content: const Text(
                                              'İlan silinsin mi?'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, 'Vazgeçtim');
                                              },
                                              child: const Text('Vazgeçtim'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                deleteIlan();
                                                Navigator.pop(context, 'Evet');
                                                showDialog(context: context, builder: (context){
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
                                                    title: Text('İlan başarıyla silindi!', textAlign: TextAlign.center,),
                                                  );
                                                });
                                              },
                                              child: const Text('Evet'),
                                            ),
                                          ],
                                        );
                                      });
                                },
                                child: Text("İlan Sil"),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.redAccent
                              ),
                            )
                        ),
                        Expanded(
                            child: ElevatedButton(
                                onPressed: () {
                                  if(_adTitle==null||_adCondition==null||_adComment==null||_adPrice==null||_adContact==null||imageSelected==false){
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
                                    editAdInfo.add(_adTitle);
                                    editAdInfo.add(_adCondition);
                                    editAdInfo.add(_adComment);
                                    editAdInfo.add(_adPrice);
                                    editAdInfo.add(_adContact);
                                    getCurrentUser();
                                    editAdInfo.add(_currentUserId);
                                    editAdInfo.add(_bos);
                                    uploadMultipleImages();
                                    Navigator.pop(context);
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          Future.delayed(Duration(seconds: 2), () {
                                            Navigator.of(context).pop(true);
                                          });
                                          return AlertDialog(
                                            title: Text('İlan başarıyla güncellendi!', textAlign: TextAlign.center,),
                                          );
                                        });
                                    //category.clear();
                                  }
                                },
                                child: Text("İlan Güncelle"),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.blueGrey
                              ),
                            )
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
