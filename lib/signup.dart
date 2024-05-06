import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:concentric_transition/page_route.dart';/
// import 'package:concentric_transition/page_view.dart';
import 'package:example/ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:example/Constant/colors.dart';
import 'package:example/login.dart';
import 'package:example/main.dart';
import 'package:example/signup.dart';
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
  final suser=TextEditingController();
  final semail=TextEditingController();
  final spass=TextEditingController();
  database _data=database();
  bool l=true;
  var auth=FirebaseAuth.instance;
  Widget build(BuildContext context) {
    Signup()async{
      var user=await auth.createUserWithEmailAndPassword(email: semail.text, password: spass.text);
      await FirebaseFirestore.instance.collection("accounts").doc("${semail.text}").set(
          {"time":DateTime.now()});
      print("-------------");
      print("email: "+"$semail.text");
      print("pass: "+"$spass.text");
      if(user!=null){
       Get.to(()=>ui("${FirebaseAuth.instance.currentUser!.uid}"));
      }}
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
                child:customtext("Username",suser)
            ),Container(
                margin: EdgeInsets.only(top:30,left: 10,right: 10),
                child:customtext("Email",semail)
            ),
            Container(
              margin: EdgeInsets.only(top:30,left: 10,right: 10),
              child: customtext("Password",spass),),
            SizedBox(height:20,),
            Container(
              height: 44.0,
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(25)),
                  gradient: LinearGradient(
                      colors: [accentPurpleColor,Colors.yellow])),
              child: ElevatedButton(
                onPressed: () {Signup();},
                style: ElevatedButton.styleFrom(fixedSize: Size(150,25),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent),
                child: Text('Signup',style: TextStyle(color:Colors.white,fontSize: 22)),
              ),),
          ] ),
    ],);
  }
}

