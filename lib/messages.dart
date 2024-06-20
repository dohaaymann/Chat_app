import 'package:example/auth/auth.dart';
import 'package:example/chatscreen.dart';
import 'package:example/auth/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:skeletons/skeletons.dart';
import 'package:example/Settings/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:left_scroll_actions/cupertinoLeftScroll.dart';
import 'package:left_scroll_actions/leftScroll.dart';

import 'Constant/colors.dart';

class messages extends StatefulWidget {
  final id;
 messages(this.id);

  @override
  State<messages> createState() => _messagesState();
}
var auth=FirebaseAuth.instance;
var userDoc_id,username,Photo;
var acc=FirebaseFirestore.instance.collection("accounts");
// var lmessage=FirebaseFirestore.instance
//     .collection("accounts")
//     .doc("${auth.currentUser?.email}")
//     .collection("mess")
//     .doc("doha@gmail.com")
//     .collection("chat").orderBy('Time',descending: false);
// stream: .snapshots(),


class _messagesState extends State<messages> {
  @override
  bool visable=false,issearch=false;
  List s_list=[];
  convertTime(var time){
    DateTime dateTime = time.toDate();
    String formattedTime = DateFormat('HH:mm').format(dateTime);
    return formattedTime;
  }
  void search(String enteredKeyword) {
    if (enteredKeyword.isEmpty) {
      return null;
    } else {
      s_list = chats.where((user) =>user.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
    });
  }
  List chats=[];
  List lmes=[];
  void messagestream() async{
    QuerySnapshot querySnapshot = await acc.get();
    querySnapshot.docs.forEach((doc) {
      doc.id=='${auth.currentUser!.email}'?null:
      chats.add(doc.id);
    });
  }
  delete_chat(var userDoc_id)async{
    var snapshots =await FirebaseFirestore.instance
        .collection("accounts")
        .doc("${auth.currentUser?.email}")
        .collection("mess").doc(userDoc_id).collection("chat").get();
    // Delete each document in the sub-collection
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }

    // Optionally delete the parent document
    await FirebaseFirestore.instance
        .collection("accounts")
        .doc("${auth.currentUser?.email}")
        .collection("mess").doc(userDoc_id).delete();
  }
  @override
  void initState() {
    // TODO: implement initState
    messagestream();
    super.initState();
  }
  late QuerySnapshot chatSnapshot;
  Widget build(BuildContext context) {
    return Scaffold(
      body:Stack(
        children: [
          Container(
            height:150,
            decoration: BoxDecoration(
              // color: accentPurpleColor,
                gradient: LinearGradient(colors: [accentPurple,pinkyy])
            ),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.only(topRight: Radius.circular(30),topLeft: Radius.circular(30))),
            margin: EdgeInsets.only(top: 110),
            child: Column(
              children: [
                issearch?
                Column(children: [
                  Container(
                    // height: 50,
                    margin: EdgeInsets.all(10),
                    child: TextFormField(
                      onChanged:(value) {
                        print(value);
                        setState(() {
                          search(value.toString());
                        });
                      },
                      decoration: InputDecoration( hintText: "Search",hintStyle: TextStyle(fontSize:20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25))
                      ),
                    ),
                  )
                  ,ListView.builder( shrinkWrap: true,
                    itemCount: s_list.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap:(){
                            // Get.to(()=>ChatScreen(userDoc_id,userDoc_id.toString()));
                            issearch=!issearch;
                            print("////*${s_list[index]}");
                            Get.to(()=>ChatScreen(s_list[index],s_list[index].toString()));

                          },
                          child: ListTile(title:Text(s_list[index].toString()),));
                    },),
                ],):
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("accounts")
                      .doc("${auth.currentUser?.email}")
                      .collection("mess")
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        // child:SkeletonListView()
                      );

                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return  Center(
                        child:  Column(
                          children: [
                            // Spacer(),
                            SizedBox(height:150),
                           Image.asset("image/message.png",height: 180,),
                            Text("No chats yet",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
                            SizedBox(height: 15,),
                            Text("You didn't make any conversation yet",style: TextStyle(color:Colors.black45,fontWeight: FontWeight.bold,fontSize:18),),
                          ],
                        ),
                      );
                    }

                    // Fetching users from "mess" collection
                    List<DocumentSnapshot> userDocs = snapshot.data!.docs;
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: userDocs.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot userDoc = userDocs[index];
                            return StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection("accounts")
                                  .doc(userDoc.id)
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<DocumentSnapshot>
                                      nameSnapshot) {
                                if (nameSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                }
                                if (nameSnapshot.hasError) {
                                  return Text('Error: ${nameSnapshot.error}');
                                }
                                if (!nameSnapshot.hasData ||
                                    !nameSnapshot.data!.exists) {
                                  return const Text('No name available');
                                }

                                String userName =nameSnapshot.data!.get('name');
                                var photo = nameSnapshot.data!.get('photo');

                                return StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection("accounts")
                                      .doc(auth.currentUser?.email)
                                      .collection("mess")
                                      .doc(userDoc.id)
                                      .collection("chat")
                                      .orderBy('Time', descending: true)
                                      .limit(1)
                                      .snapshots(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<QuerySnapshot>
                                          chatSnapshot) {
                                    if (chatSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    }
                                    if (chatSnapshot.hasError) {
                                      return Text(
                                          'Error: ${chatSnapshot.error}');
                                    }
                                    if (!chatSnapshot.hasData ||
                                        chatSnapshot.data!.docs.isEmpty) {
                                      return Center(
                                        child:  Column(
                                          children: [
                                            // Spacer(),
                                            SizedBox(height:150),
                                            Image.asset("image/message.png",height: 180,),
                                            Text("No chats yet",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
                                            SizedBox(height: 15,),
                                            Text("You didn't make any conversation yet",style: TextStyle(color:Colors.black45,fontWeight: FontWeight.bold,fontSize:18),),
                                          ],
                                        ),
                                      );
                                    }
                                    // Fetching the last message document
                                    DocumentSnapshot lastMessageDoc =
                                        chatSnapshot.data!.docs.first;
                                    userDoc_id=userDoc.id;
                                    username=userName;
                                    Photo=photo;
                                    // Now you can use lastMessageDoc data to display the last message for each user
                                    // Example: lastMessageDoc['message'], lastMessageDoc['Time'], etc.
                    return   CupertinoLeftScroll(
                      buttons: <Widget>[
                        // LeftScrollItem(
                        //   text: 'edit',
                        //   // icon:CupertinoIcons.delete_solid,
                        //   color: Colors.orange,
                        //   onTap: () {
                        //     print('edit');
                        //   },
                        // ),
                        LeftScrollItem(
                          text: 'delete',
                          // icon: CupertinoIcons.delete,
                          color: Colors.red,
                          onTap: ()async{
                            Get.defaultDialog(content:null,
                                textConfirm:"Delete",title:"Permanetly delete chat?",
                                onCancel: (){},
                                onConfirm:()async{
                                  await delete_chat(userDoc.id);
                                },);
                          },
                        ),
                      ],
                      child: InkWell(onTap: () async{
                            Get.to(()=>ChatScreen(userDoc.id,userDoc.id.toString()));
                            },child:Container(padding:const  EdgeInsets.fromLTRB(10,2,10,20),
                                  child: Row(
                                    children: [
                                       CircleAvatar(radius:30,backgroundImage: NetworkImage("$photo"),),
                                      const SizedBox(width: 10,),
                                      Column(crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("${userName}",style: const TextStyle(fontWeight: FontWeight.bold,fontSize:18),),
                                          lastMessageDoc['sendby']=='${auth.currentUser!.email}'
                                              ?lastMessageDoc['istext']?Text("You: ${lastMessageDoc['text']}"):Row(children: [
                                                Text("You: "),Icon(CupertinoIcons.camera_fill,size:18,),Text(" Photo")
                                          ],)
                                              :lastMessageDoc['istext']?Text(lastMessageDoc['text']):Row(children: [
                                            Icon(CupertinoIcons.camera_fill,size:18,),Text(" Photo")
                                          ],),
                                        ], ),
                                     Spacer(),
                                      Column(crossAxisAlignment: CrossAxisAlignment.end,mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("${convertTime(lastMessageDoc['Time'])}",style: const TextStyle(fontWeight: FontWeight.bold),),
                                          const CircleAvatar(child:Text("2",style:const TextStyle(fontSize:14),),radius: 10,backgroundColor:Color(0xffEE5366),),
                                        ], ),
                                      const SizedBox(width:6,)
                                    ],
                                  ),

                                )
                            ),
                    );
                          },
                        );
                      },
                    );
                  },
                );}),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10,35,10,10),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(decoration: BoxDecoration(color: Colors.white54,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: IconButton(onPressed: () {
                    // print("${auth.currentUser!.photoURL}");
                   //  auth.currentUser!.updateProfile(photoURL:
                   //      "https://firebasestorage.googleapis.com/v0/b/base-8c0bc.appspot.com/o/files%2F245471000000037.jpg?alt=media&token=bcf1b423-fbab-4673-92df-c8307e59c930"
                   // ,displayName: "Doaa");
                    Get.to(()=>settings("${auth.currentUser!.displayName}","${auth.currentUser!.photoURL}"));
                  }, icon:Icon(Icons.settings,color: Colors.white,)),
                ),
                Text("Messages",style: TextStyle(fontSize:25,fontWeight: FontWeight.bold,color: Colors.white),),
                Container(decoration: BoxDecoration(color: Colors.white54,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: IconButton(onPressed: () {
                      setState(() {
                        visable=!visable;
                        issearch=!issearch;
                        });
                  }, icon:Icon(Icons.search,color: Colors.white,)),
                ),
              ],),
          )
        ],
      )
    );
  }
}
