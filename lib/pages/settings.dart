
import 'dart:io';

import 'package:example/auth/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:example/pages/edit_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../Constant/colors.dart';
import '../messages.dart';

class settings extends StatefulWidget {
  const settings({Key? key}) : super(key: key);

  @override
  State<settings> createState() => _settingsState();
}

class _settingsState extends State<settings> {
  @override
  List options=['My Account','Language','Privacy'];
  var auth=FirebaseAuth.instance;
  var photo;
  @override
  var filePath;
  get_image(){
    filePath=auth.currentUser!.photoURL.toString();
    filePath= filePath.replaceFirst("File: '", "");
    filePath= filePath.replaceAll("'", "");
    photo=File(filePath);
  }
  void initState() {
    // TODO: implement initState
get_image();
print(auth.currentUser!.photoURL.toString());
print(auth.currentUser!.uid.toString());
print(photo.toString());
print(filePath);
print(auth.currentUser!.displayName.toString());
    print("settings////////////////page");
    super.initState();
  }
  Widget build(BuildContext context) {
    var Width=MediaQuery.of(context).size.width;
  var Height=MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack (
        children: [
          Container(
            height: 250,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [pinkyy,pinkyy,accentPinkColor,lightpinkyy])),
          ),

          Column(
            children: [
              SizedBox(height:180,),
              ClipPath(
                clipper: OvalTopBorderClipper(),
                child: Container(
                  color:lightpinkyy,
                  height:Height-180,
                  // margin:EdgeInsets.only(top:150),
                  child: Column(
                    // mainAxisAlignment:MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 100,),
                      for(int i=0;i<options.length;i++)
                      InkWell(
                        onTap: () {
                          Get.to(()=>edit_profile());
                          // print("${auth.currentUser!.photoURL}");
                          // print("${auth.currentUser!.displayName}");
                          // print("${auth.currentUser!.}");
                        },
                        child:Container(
                          height:70,width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(10,10,10,0), padding:const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Colors.black45,
                              // gradient: LinearGradient(colors: [Color(0xffEE5366),Color(0xFFF99BBD),Color(0xffFCD8DC),])  ,
                              borderRadius: BorderRadius.all(Radius.circular(25))
                          ),child: Row(
                            children: [
                              Text("${options[i]}",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize:22),),
                              Spacer(),
                              Icon(Icons.arrow_forward_ios,size: 22,color: Colors.white,)
                            ],
                          ),)),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(10,10,10,0), padding:const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                            children: [
                              Text("Notifications",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize:22),),
                              Spacer(),
                              Switch(
                                  value: true, onChanged:(value){})
                            ],),
                            SizedBox(height: 130,),
                            Align(alignment: Alignment.bottomCenter,
                              child: InkWell(onTap: ()async{
                                await auth.signOut();
                                Get.to(()=>auth_p());
                              }, child:Container(
                                  // margin: EdgeInsets.only(bottom: 80),
                                  height:50,alignment: Alignment.center,
                                  decoration:BoxDecoration(borderRadius: BorderRadius.circular(20),color:Colors.black45
                                      // gradient: LinearGradient(colors: [pinkyy,pinkyy,accentPinkColor])
                                  ),
                                  child: Text("Sign Out",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 22),))
                              ),
                            ),
                          ],
                        ),),
                      // SizedBox(height: 100,)
                    ],
                  ),
                ),
              ),
            ],
          ),
          Align(alignment: Alignment.topCenter,
            child: Container(padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color:Colors.indigo,
                      borderRadius:BorderRadius.circular(100),
                  boxShadow:[
                BoxShadow(color: Colors.black.withOpacity(0.8),
                    spreadRadius:0,
                    blurRadius: 7,
                    offset: Offset(1,6)
                )]),
              margin: EdgeInsets.only(top:100),
              child:CircleAvatar(radius:70, backgroundImage:
              // filePath == null?
                   AssetImage("image/unknown.png") as ImageProvider
                  // : FileImage(photo!),
              ),),
          ),
      // child:CircleAvatar(radius:70,backgroundImage:photo.toString()=='null'?Image.asset("image/unkown.png"):FileImage(photo!),),),
  //    '/data/user/0/com.example.cloud_error/cache/1dc9a1fb-a212-41e2-82a2-2821d0379c78/1000000037.jpg'
          Container(
            margin: EdgeInsets.fromLTRB(10,20,10,10),
            child: Row(
              children: [
              IconButton(onPressed: () {
                Get.to(()=>messages({"${FirebaseAuth.instance.currentUser!.uid}"}));
              }, icon:Icon(Icons.arrow_back_ios,color: Colors.white,)),
              SizedBox(width:100,),
              Text("Settings",style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold,color: Colors.white),)
            ],),
          )

        ],
      )
    );
  }
}
