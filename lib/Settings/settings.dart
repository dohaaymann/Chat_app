
import 'dart:io';

import 'package:example/Settings/DeleteAccount.dart';
import 'package:example/auth/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:example/Settings/edit_profile.dart';
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
  var name,photo;
   settings(this.name,this.photo);

  @override
  State<settings> createState() => _settingsState();
}

class _settingsState extends State<settings> {
  @override
  List options=['Edit profile','Privacy'];
  var auth=FirebaseAuth.instance;
  @override
  var photo,name;
  // get_image(){
  //   filePath=auth.currentUser!.photoURL.toString();
  //   fileP=auth.currentUser!.photoURL.toString();
  //   filePath= filePath.replaceFirst("File: '", "");
  //   filePath= filePath.replaceAll("'", "");
  //   photo=File(filePath);
  // }
  void initState() {
    // TODO: implement initState
    photo=auth.currentUser!.photoURL.toString();
    name=auth.currentUser!.displayName!;
    print("settings////////////////page");
    super.initState();
  }
  Widget build(BuildContext context) {
  var Width=MediaQuery.of(context).size.width;
  var Height=MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack (
        children: [
          ClipPath(
            clipper: OvalBottomBorderClipper(),
            child: Container(
              height: 400,width: double.infinity,
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [accentPurple,pinkyy])),
            child:
            Padding(
              padding: const EdgeInsets.only(left: 20,top:85),
              child: Align(alignment: Alignment.topLeft,
                child: Row(
                  children: [
                    Icon(Icons.settings_rounded,size:45,color: Colors.white,),
                    SizedBox(width: 10,),
                    Text("Settings",style: TextStyle(fontSize:27,fontWeight: FontWeight.bold,color: Colors.white),),
                  ],
                ),
              ),
            )
              ,
            ),
          ),
          Align(alignment: Alignment.bottomCenter ,
            child: Container(
             margin: EdgeInsets.all(12),
              height: Height-150,decoration: BoxDecoration(
              color:Colors.white,borderRadius: BorderRadius.circular(25)
            ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(children: [
                                  CircleAvatar(radius:30, backgroundImage:
                    NetworkImage("$photo")
                    //               FileImage("file:///data/user/0/com.example.cloud_error/cache/93a74cc1-3075-4537-b9b8-b6ce8073bd96248907175680371923.jpg"),
                                  ),
                      SizedBox(width: 10,),
                      Text(name,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),)
                    ],),
                  ),
                  Divider(height: 1,color: Colors.black54,),
                     Padding(
                       padding: EdgeInsets.all(20),
                       child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Padding(
                             padding: const EdgeInsets.only(top: 5,bottom:5),
                             child: Text("Account Settings",style: TextStyle(color: Colors.grey,fontSize: 20,fontWeight: FontWeight.bold),),
                           ),

                  for(int i=0;i<options.length;i++)
                    InkWell(
                        onTap: () {
                          Get.to(()=>edit_profile());
                        },
                        child:Container(
                          height: 50,
                          child: Row( children: [
                                Text("${options[i]}",style: TextStyle(color: Colors.black,fontWeight:FontWeight.w500,fontSize:22),),
                                Spacer(),
                                Icon(Icons.arrow_forward_ios,size: 20,color: Colors.black,)
                              ],),
                        )),
                  Row(
                    children: [
                      Text("Notifications",style: TextStyle(color: Colors.black,fontWeight:FontWeight.w500,fontSize:22),),
                      Spacer(),
                      Switch(
                          value: true, onChanged:(value){})
                    ],),
                  Row(
                    children: [
                      Text("Dark mode",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize:22),),
                      Spacer(),
                      Switch(
                          value: true, onChanged:(value){})
                    ],),  Padding(
                             padding: const EdgeInsets.only(top:15,bottom:5),
                             child: Text("Security",style: TextStyle(color: Colors.grey,fontSize: 20,fontWeight: FontWeight.bold),),
                           ),
                           InkWell(
                               onTap: () {
                                 Get.to(()=>DeleteAccount(name, auth.currentUser!.email!, photo));
                               },
                               child:Container(
                                 height: 50,
                                 child: Row( children: [
                                   Text("Delete Account",style: TextStyle(color: Colors.black,fontWeight:FontWeight.w500,fontSize:22),),
                                   Spacer(),
                                   Icon(Icons.arrow_forward_ios,size: 20,color: Colors.black,)
                                 ],),
                               )),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(10,10,10,0), padding:const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        SizedBox(height:20,),
                        Align(alignment: Alignment.bottomCenter,
                          child: InkWell(onTap: ()async{
                            await auth.signOut();
                            Get.to(()=>auth_p());
                          }, child:Container(
                            // margin: EdgeInsets.only(bottom: 80),
                              height:50,alignment: Alignment.center,
                              decoration:BoxDecoration(borderRadius: BorderRadius.circular(20),color: Colors.grey[350],
                                // gradient: LinearGradient(colors: [accentPurple,pinkyy,])
                              ),
                              child: Text("Sign Out",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 22),))
                          ),
                        ),],
    ),
    ),
                      ],
                    ),),
                  // SizedBox(height: 100,)
                ],
              ),
            ),
          ),
          // Align(alignment: Alignment.topCenter,
          //   child: Container(padding: EdgeInsets.all(4),
          //     decoration: BoxDecoration(
          //         color:Colors.indigo,
          //             borderRadius:BorderRadius.circular(100),
          //         boxShadow:[
          //       BoxShadow(color: Colors.black.withOpacity(0.8),
          //           spreadRadius:0,
          //           blurRadius: 7,
          //           offset: Offset(1,6)
          //       )]),
          //     margin: EdgeInsets.only(top:100),
          //     child:CircleAvatar(radius:70, backgroundImage:
          //         NetworkImage("$photo")
          //     // FileImage(photo!),
          //     ),),
          // ),
          Container(
            margin: EdgeInsets.fromLTRB(10,20,10,10),
            child: Row(
              children: [
              IconButton(onPressed: () {
                Get.to(()=>messages({"${FirebaseAuth.instance.currentUser!.uid}"}));
              }, icon:Icon(Icons.arrow_back_ios,color: Colors.white,)),
              SizedBox(width:100,),
            ],),
          )

        ],
      )
    );
  }
}
