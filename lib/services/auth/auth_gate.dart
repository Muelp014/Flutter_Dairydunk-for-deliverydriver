import 'package:DairyDunk/pages/HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:DairyDunk/pages/pages.dart';

class AuthGate extends StatelessWidget {
const AuthGate({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),builder: (context, snapshot) {
          if (snapshot.hasData){
            return  HomePage();
          }
          else{
            return const LoginOrRegisterPage();
          }
        },),
    );
  }
}