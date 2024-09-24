import 'package:flutter/material.dart';
import 'package:DairyDunk/services/auth/auth_service.dart';
import 'package:DairyDunk/utils/extension.dart';

import '../components/components.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();


  void register() async{
    final authService = AuthService();

    if (passController.text==confirmPasswordController.text){
      try{
        await authService.signUpWithEmailPassword(
          emailController.text,
          passController.text,
        );
      }
      catch (e){
        showDialog(
          context: context, 
          builder: (context)=> AlertDialog(title: Text(e.toString()),
          ),
          );
      }
    
    }
    else{
      showDialog(
          context: context, 
          builder: (context)=> AlertDialog(title: Text("Passwords don't match!"),
          ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Logo
            Icon(
              Icons.delivery_dining_rounded,
              size: 100,
              color: Colors.pink,
            ),
            25.pv,

            //message, app  slogan
            Text(
              "Let´s create an account for you",
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),

            25.pv,

            // email textfield
            MyTextField(
              controller: emailController,
              hintText: 'Email',
              obscureText: false,
            ),

            10.pv,
            // password textfield
            MyTextField(
              controller: passController,
              hintText: 'Password',
              obscureText: true,
            ),

            10.pv,
            // confirm password textfield
            MyTextField(
              controller: confirmPasswordController,
              hintText: 'Confirm Password',
              obscureText: false,
            ),

            10.pv,

            // sing up button
            MyButton(
              text: "Sign Up",
              onTap: register
            ),
            25.pv,

            // already have an account?  Login here!
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account?",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary),
                ),
                4.ph,
                GestureDetector(
                  // onTap: widget.onTap,
                  onTap: widget.onTap,
                  child: Text(
                    "Login now",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
