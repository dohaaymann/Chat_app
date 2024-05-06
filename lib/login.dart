import 'dart:ui';

// import 'package:concentric_transition/page_view.dart';
import 'package:example/ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Constant/colors.dart';
import 'customtext.dart';
// import 'package:untitled/Constant/links.dart';
// import 'package:untitled/Constant/colors.dart';

// import 'package:untitled/homapage.dart';
// import 'package:untitled/main.dart';
// import 'package:untitled/signup.dart';
// import 'package:untitled/widgets/customtext.dart';
// import 'package:untitled/widgets/database.dart';
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
  bool l=true;
  Widget build(BuildContext context) {

    login() async {
      var user=await auth.signInWithEmailAndPassword(email: lemail.text, password: lpass.text);
      try {
        final credential = await auth.signInWithEmailAndPassword(email: lemail.text, password: lpass.text);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
        }}
      print("-------------");
      print("email: "+"$lemail");
      print("pass: "+"$lpass");
      if(user!=null){
        Get.to(()=>ui("${FirebaseAuth.instance.currentUser?.uid}"));
      }
      else{
        Get.snackbar("Erorr","Please fill out this fields",backgroundColor: Colors.red,colorText: Colors.white);
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
            Align(alignment:Alignment.topRight,child: TextButton(onPressed: (){}, child: Text("Forget Password?",style:TextStyle(fontSize:17,color: Colors.yellow,fontWeight: FontWeight.bold),))),
            SizedBox(height:8,),
            Container(
              height: 44.0,
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(25)),
                  gradient: LinearGradient(
                      colors: [accentPurpleColor,Colors.yellow])),
              child: ElevatedButton(
                onPressed: () {login();},
                style: ElevatedButton.styleFrom(fixedSize: Size(150,25),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent),
                child: Text('Login',style: TextStyle(fontSize: 22,color: Colors.white)),
              ),)] ),
    ],);
  }
}

