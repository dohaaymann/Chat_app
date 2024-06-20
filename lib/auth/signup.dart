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

import '../widgets/custombutton.dart';
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
            await auth.currentUser!.updatePhotoURL("https://firebasestorage.googleapis.com/v0/b/base-8c0bc.appspot.com/o/files%2F245471000000037.jpg?alt=media&token=bcf1b423-fbab-4673-92df-c8307e59c930");

            await FirebaseFirestore.instance
                .collection("accounts")
                .doc("${auth.currentUser?.email}").set({
                "name":"${sname.text}",
                "password":"${spass.text}",
              "bio":'Busy',
                 "photo":"https://firebasestorage.googleapis.com/v0/b/base-8c0bc.appspot.com/o/files%2F245471000000037.jpg?alt=media&token=bcf1b423-fbab-4673-92df-c8307e59c930"
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
            waitt?CustomButton(text: "Signup",onTap:()async{await Signup();},height:50.0,width:150.0):CircularProgressIndicator(),
          ] ),
    ],);
  }
}

