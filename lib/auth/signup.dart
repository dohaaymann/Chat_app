import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example/homescreen.dart';
// import 'package:concentric_transition/page_route.dart';/
// import 'package:concentric_transition/page_view.dart';
import 'package:example/messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:example/Constant/colors.dart';
import 'package:example/auth/login.dart';
import 'package:example/main.dart';
import 'package:example/auth/signup.dart';
import 'package:example/widgets/customtext.dart';
import 'package:example/widgets/database.dart';
class signup extends StatefulWidget {
  const signup({Key? key}) : super(key: key);

  @override
  State<signup> createState() => _signupState();
}
var n=1;
class _signupState extends State<signup> {
  @override
  final sname=TextEditingController();
  final semail=TextEditingController();
  final spass=TextEditingController();
  database _data=database();
  bool l=true,waitt=true;
  var auth=FirebaseAuth.instance;
  Widget build(BuildContext context) {
    Signup()async{
      if (semail.text.isEmpty || spass.text.isEmpty||sname.text.isEmpty) {
        print("emptyyyy");
        Get.snackbar("Erorr", "Please fill out this fields",
            backgroundColor: Colors.red,
            colorText: Colors.white);

        return null;
      }
      else {
        var user;
        try {
          user = await auth.createUserWithEmailAndPassword(email:semail.text, password:spass.text)
          .then((value) async{
            print("------account created-------");
            print("email: "+"${semail.text}");
            print("pass: "+"${spass.text}");
            setState(() {
              waitt=!waitt;
            });
            Future.delayed(const Duration(seconds:5), () {
              Get.to(()=> messages({"${FirebaseAuth.instance.currentUser!.uid}"}));
            });
            await auth.currentUser!.updateDisplayName(sname.text);
            // await auth.currentUser!.updatePhotoURL("File: '/data/user/0/com.example.cloud_error/cache/176ed10c-2ae7-4789-9f43-68ca42d7f2ac/1000000037.jpg'");

            await FirebaseFirestore.instance
                .collection("accounts")
                .doc("${auth.currentUser?.email}").set({
                "name":"${sname.text}",
                "password":"${spass.text}",
            });
          })
          .catchError((err) {
            return Get.snackbar("Error",err.message,backgroundColor: Colors.red,colorText:Colors.white);
          });
        } on FirebaseAuthException catch (e) {
          Get.snackbar("Error",e.toString(),backgroundColor: Colors.red,colorText:Colors.white);

        }
        if(user!=null){
          print("------account created-------");
          print("email: "+"${semail.text}");
          print("pass: "+"${spass.text}");
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
      SizedBox(height:120,),                 //----------------------------signup-------------------------------
      Container( margin: EdgeInsets.only(left:10,bottom: 5),alignment: Alignment.topLeft,
          child: Text("Let's Get Started",style: TextStyle(fontFamily:"ProtestStrike-Regular",fontSize:40,color: Colors.white),)),
      Container( margin: EdgeInsets.only(left:10,bottom: 5),alignment: Alignment.topLeft,
          child: Text("Create an account",style: TextStyle(fontFamily:"ProtestStrike-Regular",fontSize:25,color: Colors.white),)),
      SizedBox(height:80,),
      Column(
          children: [
            Container(
                margin: EdgeInsets.only(left: 10,right: 10),
                child:customtext("Name",sname)
            ),Container(
                margin: EdgeInsets.only(top:30,left: 10,right: 10),
                child:customtext("Email",semail)
            ),
            Container(
              margin: EdgeInsets.only(top:30,left: 10,right: 10),
              child: customtext("Password",spass),),
            SizedBox(height:20,),
            waitt?Container(
              height: 44.0,
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(25)),
                  gradient: LinearGradient(colors: [accentPurpleColor,pinkyy,pinkyy,accentPurpleColor])),
              child: ElevatedButton(
                onPressed: () {Signup();},
                style: ElevatedButton.styleFrom(fixedSize: Size(150,25),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent),
                child: Text('Signup',style: TextStyle(color:Colors.white,fontSize: 22)),
              ),):CircularProgressIndicator(),
          ] ),
    ],);
  }
}

