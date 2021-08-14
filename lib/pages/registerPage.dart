
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:benden_al/widgets/custom_button.dart';
import 'package:benden_al/widgets/custom_input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  Future<void> _alertDialogBuilder(String error) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("Error"),
            content: Container(
              child: Text(error),
            ),
            actions: [
              TextButton(
                child: Text("Pencereyi Kapat"),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        }
    );
  }
  _createStorage() async {
    int i=1;
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    final uid = user.uid;
    final FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child(uid.toString()).child("$i");
    final UploadTask uploadTask = ref.putString("");
    await uploadTask;
  }
  _createCategory() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    final uid = user.uid;
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid.toString())
        .set({
      "id": uid,
      "userName": _nameSurname,
      "userEmail": _registerEmail,
      "created_at": DateTime.now().millisecondsSinceEpoch,
      "user_card_id": _registerCardId,
    });
  }
  // Create a new user account

  Future<String> _createAccount() async {

    try {
      UserCredential result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _registerEmail, password: _registerPassword);
      User user = result.user;
      user.updateDisplayName(_nameSurname);
      return null;
    } on FirebaseAuthException catch(e) {
      if (e.code == 'weak-password') {
        return 'Daha güçlü bir şifre seçin.';
      } else if (e.code == 'email-already-in-use') {
        return 'Bu email hesabına kayıtlı bir üyelik var.';
      }
      return e.message;
    } catch (e) {
      return e.toString();
    }

  }

  void _submitForm() async {
    setState(() {
      _registerFormLoading = true;
    });

    String _createAccountFeedback = await _createAccount();

    if(_createAccountFeedback != null) {
      _alertDialogBuilder(_createAccountFeedback);
      setState(() {
        _registerFormLoading = false;
      });
    } else {
      _createStorage();
      _createCategory();
      Navigator.pop(context);
    }
  }

  bool _registerFormLoading = false;
  String _registerCardId="";
  String _registerEmail = "";
  String _registerPasswordConfirm = "";
  String _registerPassword = "";
  String _nameSurname="";
  FocusNode _passwordFocusNode;
  FocusNode _passwordComfirmFocusNode;
  CollectionReference users=FirebaseFirestore.instance.collection("userKurumId");
  final _firestore=FirebaseFirestore.instance;
  
  @override
  void initState() {
    _passwordFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var usersRef=_firestore.collection("userKurumId").where("members");
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children:<Widget> [
            Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      top: 24.0,
                    ),
                    child: Text(
                      "Yeni Hesap Oluştur",
                      textAlign: TextAlign.center,

                    ),
                  ),
                  Column(
                    children: [
                      CustomInput(
                        hintText: "Email...",
                        onChanged: (value) {
                          _registerEmail = value;
                        },
                        onSubmitted: (value) {
                          _passwordFocusNode.requestFocus();
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      CustomInput(
                        hintText: "Ad Soyad...",
                        onChanged: (value) {
                          _nameSurname = value;
                        },
                        onSubmitted: (value) {
                          _passwordFocusNode.requestFocus();
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      CustomInput(
                        hintText: "Kurum ID...",
                        onChanged: (value) async {
                          var respose=await usersRef.get();
                          var veri=respose.docs.last.get("members");
                          var secondList = List.from(veri);
                          for(int i=0;i<secondList.length;i++)
                          {
                            if(value==secondList[i])
                            {
                              _registerCardId = value;
                            }
                            else{
                              _registerCardId="";
                            }
                          }
                          //_registerCardId = value;
                        },
                        onSubmitted: (value) {
                          _passwordFocusNode.requestFocus();
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      CustomInput(
                        hintText: "Şifre...",
                        onChanged: (value) {
                          _registerPassword = value;
                        },
                        focusNode: _passwordFocusNode,
                        isPasswordField: true,
                        textInputAction: TextInputAction.next,
                      ),
                      CustomInput(
                        hintText: "Şifreyi Doğrula...",
                        onChanged: (value) {
                          _registerPasswordConfirm = value;
                        },
                        focusNode: _passwordComfirmFocusNode,
                        isPasswordField: true,
                      ),

                      CustomBtn(
                        text: "Oluştur",
                        onPressed: () {
                          if(_registerPassword==_registerPasswordConfirm){
                            if(_registerCardId!="")
                            {
                              _submitForm();
                            }
                            else{
                              _alertDialogBuilder("Id yok");
                            }
                            //_submitForm();
                          }
                          else{
                            _alertDialogBuilder("Şifreler aynı değil!");
                          }
                        },
                        isLoading: _registerFormLoading,
                      ),

                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 16.0,
                    ),
                    child: CustomBtn(
                      text: "Giriş Sayfasına Dön",
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      outlineBtn: true,
                    ),
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
