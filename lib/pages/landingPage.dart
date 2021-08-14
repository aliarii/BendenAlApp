import 'package:benden_al/pages/homePage.dart';
import 'package:benden_al/pages/userLoginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

class LandingPage extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text("Error: ${snapshot.error}"),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, streamSnapshot) {
              if (streamSnapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Text("Error: ${streamSnapshot.error}"),
                  ),
                );
              }

              if (streamSnapshot.connectionState == ConnectionState.active) {
                User _user = streamSnapshot.data;

                if (_user == null) {
                  return UserLoginPage();
                } else {
                  return HomePage();
                }
              }

              return Scaffold(
                body: Center(
                  child: Text(
                    "Oturum Açılıyor...",
                  ),
                ),
              );
            },
          );
        }

        return Scaffold(
          body: Center(
            child: Text(
              "Uygulama Başlatılıyor...",
            ),
          ),
        );
      },
    );
  }
}
