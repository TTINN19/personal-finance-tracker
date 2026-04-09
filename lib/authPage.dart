import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import './homePage.dart';
import './loginPage.dart';

class authPage extends StatelessWidget {
  const authPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return homePage();
          } else {
            return loginPage();
          }
        },
      ),
    );
  }
}
