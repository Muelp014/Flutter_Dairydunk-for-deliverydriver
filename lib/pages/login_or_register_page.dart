import 'package:DairyDunk/pages/login_page.dart';
import 'package:DairyDunk/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:DairyDunk/pages/pages.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  // initially, show login page
  bool _isLoginPage = true;

  void toggledPages() {
    setState(() {
      _isLoginPage = !_isLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoginPage) {
      return LoginPage(onTap: toggledPages);
    } else {
      return RegisterPage(onTap: toggledPages);
    }
  }
}
