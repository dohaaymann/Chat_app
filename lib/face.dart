import 'package:example/models/database.dart';
import 'package:example/links.dart';
import 'package:example/homescreen.dart';
import 'package:example/main.dart';
import 'package:example/auth/signup.dart';
import 'package:example/messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'chatscreen.dart';
import 'home.dart';
// import 'package:http/http.dart' as http;
import 'dart:convert';
class face extends StatelessWidget{
List img=["images/5.jpeg","images/1.jpeg","images/4.jpeg","images/2.jpeg","images/3.jpeg","images/1.jpeg","images/6.jpeg"];
  @override
  var auth=FirebaseAuth.instance;
  Widget build(BuildContext context) {
    return
      Scaffold(resizeToAvoidBottomInset: true,
        appBar: AppBar(backgroundColor: Colors.white,automaticallyImplyLeading: false,
          title: Text("Facebook",style: TextStyle(fontSize: 30,color: Colors.blue,fontWeight: FontWeight.bold)),
          actions: [
            CircleAvatar(backgroundColor:Colors.white54,
                child:IconButton(onPressed: ()async{
                  // var db=database();
                  // var w=await db.postRequest(chatbot);
                  // print(w);
                  print(FirebaseAuth.instance.currentUser?.email);
                  print(FirebaseAuth.instance.currentUser?.uid);
                  // Get.to(()=> ChatScreen());
                }, icon:Icon(Icons.search,color: Colors.black,) ,)
               ),Padding(padding: EdgeInsets.all(2)),
            CircleAvatar(backgroundColor: Colors.white54,
                child:IconButton(onPressed: (){
                 // Navigator.of(context).push(MaterialPageRoute(builder: (context) => home(sendto:"doha",sendto2:"dohaa"),));
                 Navigator.of(context).push(MaterialPageRoute(builder: (context) =>messages("${auth.currentUser?.uid}"),));
                }, icon:FaIcon(FontAwesomeIcons.facebookMessenger,color: Colors.blue,) ,)
            ),Padding(padding: EdgeInsets.all(4))
          ],elevation:0,scrolledUnderElevation:40,
        ),
        bottomNavigationBar: BottomAppBar(child:
          Container(
            height: 50,
            width: double.maxFinite,
            decoration: BoxDecoration(
                color: Colors.white,
            ),
            child: Row(
              // mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: InkWell(onTap: (){
                    FirebaseAuth.instance.signOut();
                    // Get.to(()=>MyHomePage(title: "title"));
                  },child: Column(children: [Icon(Icons.home),Text("Home",style: TextStyle(fontSize: 11),)]),),
                ),Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: InkWell(onTap: (){},child: Column(children: [Icon(Icons.group),Text("Friends",style: TextStyle(fontSize: 11),)]),),
                ),Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: InkWell(onTap: (){},child: Column(children: [Icon(Icons.ondemand_video),Text("Video",style: TextStyle(fontSize: 11),)]),),
                ),Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: InkWell(onTap: (){},child: Column(children: [Icon(Icons.groups_outlined),Text("Groups",style: TextStyle(fontSize: 11),)]),),
                ),Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: InkWell(onTap: (){},child: Column(children: [Icon(Icons.notifications_rounded),Text("Notifications",style: TextStyle(fontSize: 11),)]),),
                ),Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: InkWell(onTap: (){},child: Column(children: [Icon(Icons.menu),Text("Menu",style: TextStyle(fontSize: 11),)]),),
                ),
              ],
            ),
          ),),
    body:Stack (
      children:[ SingleChildScrollView(
        child: Column(children: [
          Container(color: Colors.white,padding: EdgeInsets.all(6),
            child: Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: CircleAvatar(
                  radius: 25,
                  backgroundImage:AssetImage("images/6.jpeg"),
                ),
              ),
              SizedBox(width: 200,
                child: GestureDetector(
                  onTap: ()async{
                    var db=database();
                    // var w=await db.postRequest(linkw);
                    // print(w);
                  },
                  child: TextFormField(
                    // controller: p,
                  ),
                ),
              ),
              // Container(width:200,margin:EdgeInsets.only(left: 15,right:76),child:
              // // Text("What's on your mind?",style: TextStyle(fontSize: 16),),
              // ),
              IconButton(onPressed: (){}, icon: Icon(Icons.add_photo_alternate,color: Colors.green,))
            ],),
          ),
          Container(color:Colors.grey,height:4,child: Divider(color: Colors.grey,thickness:0.5,)),
          Container(height: 200,margin: EdgeInsets.all(5),
            child: GridView.builder(scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                itemCount: img.length,
                itemBuilder: (BuildContext ctx, i) {
                  return Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(image: DecorationImage(
                      image: AssetImage(img[i]),
                      fit: BoxFit.cover,
                    ),
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10)),
                    child: Container(height:200,decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
                        child:
                        Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(margin: EdgeInsets.all(5),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.blue,
                                  width: 3.0,
                                ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: CircleAvatar(
                                radius: 25,
                                backgroundImage:AssetImage("images/4.jpeg"),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(top: 115,left:5,bottom:1),child:
                            Align(alignment:Alignment.bottomLeft,child:Text("Dohaa ayman",style:
                              TextStyle(color: Colors.white,fontSize:17),)),),
                          ],
                        )),
                  );
                }),
          ),
          Container(color:Colors.grey,height:4,child: Divider(color: Colors.grey,thickness:1,)),
            Posts(),
            Posts(),
            Posts(),


        ],),
      ),


    ]));
}
}
class Posts extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(color:Colors.white,margin: EdgeInsets.only(left: 7,top: 12,right: 7),child:
    Column(
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              child: CircleAvatar(
                radius: 25,
                backgroundImage:AssetImage("images/6.jpeg"),
              ),
            ),
            Padding(padding: EdgeInsets.only(left: 10)),
            Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
              Text("Dohaa aymann",style:TextStyle(fontSize: 19)),
              // Text("${DateTime.now().hour}h.")
              Text("8h.")
              // Icon(Icons.planet)
            ],),Padding(padding: EdgeInsets.only(left:115)),

            Expanded(
              child:IconButton(onPressed: (){}, icon: FaIcon(FontAwesomeIcons.ellipsis,size: 19,))
            ),
            Align(alignment: Alignment.bottomRight,
                child: IconButton(onPressed: (){}, icon: Icon(Icons.close))),

          ],),
        Padding(
          padding: const EdgeInsets.only(top: 8,left: 3,bottom: 4),
          child: Align(alignment:Alignment.topLeft,child: Text("Hello,Just try posting",style:TextStyle(fontSize: 19),)),
        ),
        Padding(padding: EdgeInsets.all(5)),
        Row(children: [
          Icon(Icons.thumb_up_rounded,color: Colors.blue,),
          Text(" 12"),
          Expanded(
              child:Align(alignment: Alignment.bottomRight,
                  child: Text("12 comments"))),
          Padding(padding: EdgeInsets.only(left: 10)),
          Text("2 shares")
        ],),
        Divider(color: Colors.grey,height: 2,thickness:0.5,),
        Padding(
          padding: const EdgeInsets.only(top: 9,bottom: 7),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: [
            InkWell(onTap: (){print("tab");},child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.thumb_up_alt_outlined,color:Colors.black),Text(" Like",style:TextStyle(color:Colors.black),)
              ],),),
            InkWell(onTap: (){print("tab");},child:Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FaIcon(FontAwesomeIcons.comment),Text("  Comment",style:TextStyle(color:Colors.black),)
              ],),),
            InkWell(onTap: (){print("tab");},child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.send,color:Colors.black),Text(" Send",style:TextStyle(color:Colors.black),)
              ],),),
          ],),
        ),
        Container(color:Colors.grey,height:5,child: Divider(color: Colors.grey,thickness:0.5,)),
      ],
    )
      ,);
  }
  }