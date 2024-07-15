import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example/auth/login.dart';
import 'package:example/widgets/custombutton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../chatscreen.dart';
import '../models/SettingsProvider.dart';
import '../models/theme.dart';
import '../widgets/customtext.dart';

class change_pass extends StatelessWidget {
  var _email = TextEditingController();
  final auth=FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SettingsProvider>(context);
    var theme = provider.isDarkTheme ? DarkTheme() : LightTheme();
    return Scaffold(
      backgroundColor: theme.backgroundhome,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(onPressed: (){
          Navigator.of(context).pop();
        }, icon:Icon(Icons.arrow_back_ios,color:theme.TextColor,)),
        backgroundColor: theme.backgroundhome,),
      body: Container(
          padding: EdgeInsets.only(top: 10, left: 10, right: 20),
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Image.asset("image/lock.png",height: 150,),
            SizedBox(height: 20,),
            Text(
              "Reset Password",
              style: TextStyle(color:theme.TextColor,fontSize: 35, fontWeight: FontWeight.bold),
            ),Text("Please enter your email address. We will send you an email to reset your password."
              ,style: TextStyle(color:provider.isDarkTheme?Colors.white60:Colors.black87,fontSize:17),textAlign: TextAlign.center,),
            SizedBox(height: 20,),
            Align(alignment: Alignment.centerLeft,
                child: Text("Email",style:TextStyle(color:theme.TextColor,fontWeight: FontWeight.bold,fontSize: 20,),)),
            TextFormField(
              style: TextStyle(fontSize:20),
              cursorColor: Colors.indigo,controller: _email,
              decoration:InputDecoration(  hintText: "yours@gmail.com",
                hintStyle: TextStyle(color: provider.isDarkTheme?Colors.white60:Colors.black54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 2, color:provider.isDarkTheme?Colors.white60:Colors.black54),
                ),),
            ),
            SizedBox(height:30,),
            Center(
              child: CustomButton(
                  onTap: () async {
                    late BuildContext dialogContext = context;
                    Timer? timer = Timer(Duration(milliseconds: 4000), () {
                      Navigator.pop(dialogContext);
                    });
                    await auth
                        .sendPasswordResetEmail(email: _email.text)
                        .then((value) {
                          Navigator.of(context).pop();
                      return Get.snackbar("","Password reset link send! check your email",
                          backgroundColor:Colors.green,messageText:Text("Password reset link send! check your email"));
                    }).catchError((e) {
                      Get.snackbar("Error", e.message ?? "An error occurred",
                          backgroundColor: Colors.red, colorText: Colors.white);
                    });
                  },
                  text:"Reset Password",height:45.0,width:250.0,),
            )
          ])),
    );
  }
}
