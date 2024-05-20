import 'dart:ui';
import 'package:example/messages.dart';
import 'package:example/widgets/customtext.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Constant/colors.dart';
import '../homescreen.dart';
class login extends StatefulWidget {
  const login({Key? key}) : super(key: key);

  @override
  State<login> createState() => _loginState();
}
var n=1;
class _loginState extends State<login> {
  @override
  final lemail=TextEditingController();
  final lpass=TextEditingController();
  var auth=FirebaseAuth.instance;
  bool l=true,waitt=true;

  Widget build(BuildContext context) {

    login() async {
      if (lemail.text.isEmpty ||lpass.text.isEmpty) {
        print("emptyyyy");
        Get.snackbar("Erorr", "Please fill out this fields",
            backgroundColor: Colors.red,
            colorText: Colors.white);

        return null;
      } else {
        var user;
        try {
          user = await auth
              .signInWithEmailAndPassword(
              email: lemail.text, password: lpass.text)
              .catchError((err) {
            if (err.code == "invalid-email") {
              return Get.snackbar(
                  "Error", "Please enter a valid email address",
                  backgroundColor: Colors.red);
            }
            if (err.message ==
                "The password is invalid or the user does not have a password.") {
              return Get.snackbar(
                  "Error", "ًWrong email address or password",
                  backgroundColor: Colors.red);
            }
            if (err.message ==
                "There is no user record corresponding to this identifier. The user may have been deleted.") {
              return Get.snackbar(
                  "Error", "Email is not register with us",
                  backgroundColor: Colors.red);
            }
            return Get.snackbar("Error", err.message,
                backgroundColor: Colors.red);
          });
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found') {
            print('No user found for that email.');
          } else if (e.code == 'wrong-password') {
            print('Wrong password provided for that user.');
          }
        }
        if (user != null) {
          print("------ login successfuly-------");
          print("email: " + "${lemail.text}");
          print("pass: " + "${lpass.text}");
          setState(() {
            waitt=!waitt;
          });
          Future.delayed(const Duration(seconds:5), () {
          Get.to(()=> messages({"${FirebaseAuth.instance.currentUser!.uid}"}));
          });
        }
      }
    }
    return Column(children: [
      SizedBox(height:80,),

      Container( margin: EdgeInsets.only(left:10,bottom: 5),alignment: Alignment.topLeft,
          child: Text('Hello!',style: TextStyle(fontFamily:"ProtestStrike-Regular",fontSize:35,color: Colors.white),)),
      Container( margin: EdgeInsets.only(left:10,bottom: 5),alignment: Alignment.topLeft,
          child: Text("Welcome \nBack..",style: TextStyle(fontFamily:"ProtestStrike-Regular",letterSpacing:5,fontSize:45,color: Colors.white,fontWeight: FontWeight.bold),)),

      SizedBox(height:60,),
      Column(
          children: [
            Container(
                margin: EdgeInsets.only(left: 10,right: 10),
                child:customtext("Email",lemail)
            ),
            Container(
              margin: EdgeInsets.only(top:30,left: 10,right: 10),
              child: customtext("Password",lpass),),
            Align(alignment:Alignment.topRight,child: TextButton(onPressed: (){}, child: Text("Forget Password?",style:TextStyle(fontSize:17,color: pinkyy,fontWeight: FontWeight.bold),))),
            SizedBox(height:8,),
            waitt? Container(
              height: 44.0,
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(25)),
                  gradient: LinearGradient(colors: [accentPurpleColor,pinkyy,pinkyy,accentPurpleColor])),
              child:ElevatedButton(
                onPressed: () {
                  login();
                  },
                style: ElevatedButton.styleFrom(fixedSize: Size(150,25),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent),
                child: Text('Login',style: TextStyle(fontSize: 22,color: Colors.white)),
              )):CircularProgressIndicator()] ),
    ],);
  }
}

