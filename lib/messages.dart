import 'dart:ui';

import 'package:example/auth/auth.dart';
import 'package:example/auth/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:skeletons/skeletons.dart';
import 'package:example/Settings/settings.dart';
import 'package:example/face.dart';
import 'package:example/pages/friend_profile.dart';
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
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';

import 'Constant/colors.dart';
import 'models/SettingsProvider.dart';
import 'models/sql.dart';
import 'models/theme.dart';
import 'notification.dart';

class messages extends StatefulWidget {
  final id;
 messages(this.id);

  @override
  State<messages> createState() => _messagesState();
}
var auth=FirebaseAuth.instance;
var userDoc_id,username,Photo;
var acc=FirebaseFirestore.instance.collection("accounts");
 check_ifblocked(String email) async {
  try {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await FirebaseFirestore.instance
        .collection("accounts")
        .doc(email)
        .collection("mess")
        .doc(FirebaseAuth.instance.currentUser!.email!)
        .get();

    if (documentSnapshot.exists) {
      return documentSnapshot.data()?['isblocked'] ?? false;
    } else {
      print("Document does not exist");
      return false;
    }
  } catch (e) {
    print("Error getting document: $e");
    return null;
  }
}

class _messagesState extends State<messages> {
  @override
  bool visable=false,issearch=false;
  List s_list=[];
  var wait=false;
  var sql=SQLDB();
  convertTime(var time){
    DateTime dateTime = time.toDate();
    String formattedTime = DateFormat('HH:mm').format(dateTime);
    return formattedTime;
  }
  void search(String enteredKeyword) {
    if (enteredKeyword.isEmpty) {
    } else {
      setState(() {
        s_list = chats.where((user) {
          String name = user['name'].toString().toLowerCase();
          String email = user['email'].toString().toLowerCase();
          String keyword = enteredKeyword.toLowerCase();
          return name.contains(keyword) || email.contains(keyword);
        }).toList();
      });
    }
  }

  List chats=[];
  List lmes=[];

   messagestream() async{
    await get_blockes(); // Ensure blocks are fetched before checking
    QuerySnapshot querySnapshot = await acc.get();
    querySnapshot.docs.forEach((doc) {
      if (doc.id != '${auth.currentUser!.email}' &&
          !blocks.any((block) => block['id'] == doc.id)) {
        var data = doc.data() as Map<String, dynamic>;
        chats.add({
          "email": doc.id,
          "name": data['name'],
          "photo": data['photo'],
          "bio": data['bio'],
          "token": data['token']
        });
      }
    });
    setState(() {}); // Update the UI after adding chats
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
  List<Map<String, dynamic>> blocks = [];
  bool _isBlocked=false;
  get_blockes()async*{
    var data = await FirebaseFirestore.instance
        .collection("accounts")
        .doc("${auth.currentUser?.email}")
        .collection("Blocks")
        .get();
    setState(() {
      blocks = data.docs.map((doc) {
        var blockData = doc.data();
        blockData['id']= doc.id; // Add the document ID to the data map
        return blockData;
      }).toList();
    });
    // print(blocks['id'])
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    messagestream();
    get_blockes();
  }
  late QuerySnapshot chatSnapshot;
 var notify= Notification_();
  Widget build(BuildContext context) {
    var provide=Provider.of<SettingsProvider>(context);
    var theme = provide.isDarkTheme ? DarkTheme() : LightTheme();
    var Width=MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset:false,
      body:Stack(
        children: [
          Container(
            height:150,
            decoration: BoxDecoration(
              // color: accentPurpleColor,
                gradient: !provide.isDarkTheme?LinearGradient(
                    // begin: Alignment.bottomCenter,end: Alignment.topCenter,
                    colors: [
                      // LIGHT MODE
                      // accentPurple,pinkyy
                      // Color(0xff543863),
                      // Color(0xff4CBF87),
                      Color(0xff543863),
                      Color(0xff84aa9b)
                      // Color(0xff84aa9b),Color(0xffdadc79)
                    ]):
                LinearGradient(tileMode: TileMode.mirror,
                    colors: [
                      // DARK MODE
                      Color(0xff7B7794),
                      Color(0xff231E73),
                    ])
            ),
          ),
          Container(
            decoration: BoxDecoration(color:theme.backgroundhome,
                borderRadius: BorderRadius.only(topRight: Radius.circular(30),topLeft: Radius.circular(30))),
            margin: EdgeInsets.only(top: 110),
            child: Column(
              children: [
                issearch?
                Column(children: [
                  Container(
                    // height: 50,
                    margin: EdgeInsets.fromLTRB(10,10,10,5),
                    child: TextFormField(
                      onTapOutside: (v){FocusManager.instance.primaryFocus?.unfocus();},
                      style: TextStyle(color:theme.TextColor),
                      onChanged:(value) {
                        setState(() {
                          search(value.toString());
                        });
                      },
                      decoration: InputDecoration( hintText: "Search",hintStyle: TextStyle(color:provide.isDarkTheme?Colors.white60:Colors.black54,fontSize:20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25))
                      ),
                    ),
                  )
                  ,ListView.builder(
                          shrinkWrap: true,
                          itemCount: s_list.length,
                          itemBuilder: (context, index) {
                            var user = s_list[index];
                            return InkWell(
                              onTap: ()async{
                                // // Toggle issearch and navigate to ChatScreen with the user's details
                                // // print(isBlockedSnapshot.data?.data()?['isblocked']);
                                // provide.set_isblock(_isBlocked);
                                // print("========${provide.isblock}");
                                print(_isBlocked);
                                // print(isBlockedSnapshot.data?.data()?['isblocked']);
                                // await sql.update_isblock(isBlockedSnapshot.data?.data()?['isblocked']);
                                // provide.set_isblock(isBlockedSnapshot.data?.data()?['isblocked']);
                                // print("========${provide.isblock}");
                                await check_ifblocked(s_list[index]['email'])?provide.set_blocks('Blocked'):provide.set_blocks('none');

                                issearch = !issearch;
                                Get.to(() => chat_(
                                    s_list[index]['name'],
                                    s_list[index]['email'],
                                    s_list[index]['bio'],
                                    s_list[index]['photo'],
                                    s_list[index]['token'],
                                ));
                              },
                              child: ListTile(
                                leading: CircleAvatar(radius: 30,backgroundImage:
                                NetworkImage(s_list[index]['photo']), // Use NetworkImage for URLs
                                ),subtitle: Text(s_list[index]['bio'].toString(),style: TextStyle(color:theme.TextColor,fontSize:16)),
                                title: Text(s_list[index]['name'].toString(),style: TextStyle(color:theme.TextColor,fontSize:19),

                                ), // Ensure name is a string
                              ),
                            );
                          },
                        ),
                      ],):
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("accounts")
                      .doc("${auth.currentUser?.email}")
                      .collection("mess").orderBy('time', descending: true)
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          // child: Column(
                          //   children: [
                          //     for(int i=0;i<chats.length;i++)
                          //       SizedBox(width:600,height:74,
                          //         // child: SkeletonListView(
                          //         //   item: SkeletonListTile(
                          //         //     verticalSpacing: 12,
                          //         //     leadingStyle: SkeletonAvatarStyle(
                          //         //         width: 64, height:64, shape: BoxShape.circle),
                          //         //     titleStyle:
                          //         //     SkeletonLineStyle(
                          //         //         height: 16,
                          //         //         minLength: 200,
                          //         //         randomLength: true,
                          //         //         borderRadius: BorderRadius.circular(12)),
                          //         //     subtitleStyle: SkeletonLineStyle(
                          //         //         height: 12,
                          //         //         maxLength: 200,
                          //         //         randomLength: true,
                          //         //         borderRadius: BorderRadius.circular(12)),
                          //         //     hasSubtitle: true,
                          //         //   ),
                          //         // ),
                          //       )
                          //   ],
                          // )
                      );
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return
                        Center(
                        child:  Column(
                          children: [
                            // Spacer(),
                            SizedBox(height:150),
                           Image.asset("image/message.png",height: 180,),
                            Text("No chats yet",style: TextStyle(color:theme.TextColor,fontWeight: FontWeight.bold,fontSize: 25),),
                            SizedBox(height: 15,),
                            Text("You didn't make any conversation yet",style: TextStyle(color:provide.isDarkTheme?Colors.white60:Colors.black45,fontWeight: FontWeight.bold,fontSize:18),),
                          ],
                        ),
                      );
                    }

                    // Fetching users from "mess" collection
                    List<DocumentSnapshot> userDocs = snapshot.data!.docs;
                        return  ListView.builder(
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
                                   return Center(
                                       child: Column(
                                         children: [
                                           for(int i=0;i<chats.length;i++)
                                             SizedBox(width:600,height:74,
                                               child: SkeletonListView(
                                                 item: SkeletonListTile(
                                                   verticalSpacing: 12,
                                                   leadingStyle: SkeletonAvatarStyle(
                                                       width: 64, height:64, shape: BoxShape.circle),
                                                   titleStyle:
                                                   SkeletonLineStyle(
                                                       height: 16,
                                                       minLength: 200,
                                                       randomLength: true,
                                                       borderRadius: BorderRadius.circular(12)),
                                                   subtitleStyle: SkeletonLineStyle(
                                                       height: 12,
                                                       maxLength: 200,
                                                       randomLength: true,
                                                       borderRadius: BorderRadius.circular(12)),
                                                   hasSubtitle: true,
                                                 ),
                                               ),
                                             )
                                         ],
                                       )
                                   );
                                }
                                if (nameSnapshot.hasError) {
                                  return Text('Error: ${nameSnapshot.error}');
                                }
                                if (!nameSnapshot.hasData ||
                                    !nameSnapshot.data!.exists) {
                                  return const Text('No name available');
                                }

                                String userName =nameSnapshot.data!.get('name');
                                String bio =nameSnapshot.data!.get('bio');
                                var photo = nameSnapshot.data!.get('photo');
                                var token = nameSnapshot.data!.get('token');
                             return StreamBuilder(stream:FirebaseFirestore.instance
                                            .collection("accounts")
                                            .doc(auth.currentUser?.email)
                                            .collection("mess")
                                            .doc(userDoc.id)
                                            .snapshots(),
                                        builder: (BuildContext context,AsyncSnapshot< DocumentSnapshot< Map<String, dynamic>>>isBlockedSnapshot) {
                                          if (isBlockedSnapshot.connectionState ==ConnectionState.waiting) {
                                            return Center(
                                                // child: Column(
                                                //   children: [
                                                //     for(int i=0;i<chats.length;i++)
                                                //       SizedBox(width:600,height:74,
                                                //         child: SkeletonListView(
                                                //           item: SkeletonListTile(
                                                //             verticalSpacing: 12,
                                                //             leadingStyle: SkeletonAvatarStyle(
                                                //                 width: 64, height:64, shape: BoxShape.circle),
                                                //             titleStyle:
                                                //             SkeletonLineStyle(
                                                //                 height: 16,
                                                //                 minLength: 200,
                                                //                 randomLength: true,
                                                //                 borderRadius: BorderRadius.circular(12)),
                                                //             subtitleStyle: SkeletonLineStyle(
                                                //                 height: 12,
                                                //                 maxLength: 200,
                                                //                 randomLength: true,
                                                //                 borderRadius: BorderRadius.circular(12)),
                                                //             hasSubtitle: true,
                                                //           ),
                                                //         ),
                                                //       )
                                                //   ],
                                                // )
                                            );
                                          }
                                          if (isBlockedSnapshot.hasError) {
                                            return Text(
                                                'Error: ${isBlockedSnapshot.error}');
                                          }
                                          // print(object)
                                        _isBlocked = isBlockedSnapshot.data?.data()?['isblocked'];
                                          return StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection("accounts")
                                      .doc(auth.currentUser?.email)
                                      .collection("mess")
                                      .doc(userDoc.id)
                                      .collection("chat")
                                      .orderBy('Time', descending: true)
                                      .snapshots(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<QuerySnapshot>
                                          chatSnapshot) {
                                    if (chatSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          // child: Column(
                                          //   children: [
                                          //     for(int i=0;i<chats.length;i++)
                                          //       SizedBox(width:600,height:74,
                                          //         child: SkeletonListView(
                                          //           item: SkeletonListTile(
                                          //             verticalSpacing: 12,
                                          //             leadingStyle: SkeletonAvatarStyle(
                                          //                 width: 64, height:64, shape: BoxShape.circle),
                                          //             titleStyle:
                                          //             SkeletonLineStyle(
                                          //                 height: 16,
                                          //                 minLength: 200,
                                          //                 randomLength: true,
                                          //                 borderRadius: BorderRadius.circular(12)),
                                          //             subtitleStyle: SkeletonLineStyle(
                                          //                 height: 12,
                                          //                 maxLength: 200,
                                          //                 randomLength: true,
                                          //                 borderRadius: BorderRadius.circular(12)),
                                          //             hasSubtitle: true,
                                          //           ),
                                          //         ),
                                          //       )
                                          //   ],
                                          // )
                                      );
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
                                    DocumentSnapshot lastMessageDoc =chatSnapshot.data!.docs.first;
                                    userDoc_id=userDoc.id;
                                    username=userName;
                                    Photo=photo;
                                    // Now you can use lastMessageDoc data to display the last message for each user
                                    // Example: lastMessageDoc['message'], lastMessageDoc['Time'], etc.
                    return   CupertinoLeftScroll(
                      buttons: <Widget>[
                        LeftScrollItem(
                          text: 'Delete',icon:Icons.delete,
                          color: Colors.red,
                          onTap: ()async{
                            Get.defaultDialog(
                                buttonColor:theme.buttonColor,
                              title: "Delete Chat",
                              textConfirm: "Delete",
                              textCancel: "Cancel",
                              onCancel: () {},
                                // confirm: wait?CircularProgressIndicator():null,
                              onConfirm: () async {
                                  print("d");
                                  await delete_chat(userDoc.id);
                                    Navigator.of(context).pop();
                                // setState(() {
                              //     wait=!wait;
                              //     });
                                  // Route route = MaterialPageRoute(builder: (context) =>messages(auth.currentUser!.uid));
                                  // Navigator.pushReplacement(context, route);                             //      Future.delayed(const Duration(seconds:3), () {
                             //   setState(() {
                             //     wait=!wait;
                             //     Navigator.of(context).pop();
                             //   });
                             // });

                              },
                              content:Text("Permanently delete chat?")
                              // Removes default content
                            );

                          }
                        ),
                      ],
                      child: InkWell(onTap: () async{
                            print(_isBlocked);
                            print(isBlockedSnapshot.data?.data()?['isblocked']);
                            await sql.update_isblock(isBlockedSnapshot.data?.data()?['isblocked']);
                            provide.set_isblock(isBlockedSnapshot.data?.data()?['isblocked']);
                            // print("========${provide.isblock}");
                            await check_ifblocked(userDoc.id)?provide.set_blocks('Blocked'):isBlockedSnapshot.data?.data()?['isblocked']?provide.set_blocks('Blockhim'):provide.set_blocks('none');
                            // Get.to(()=>ChatScreen(userName,userDoc.id,bio,photo,token));
                            Get.to(()=>chat_(userName,userDoc.id,bio,photo,token));
                            // Get.to(()=>chat_(userName,userDoc.id));
                            },child:Container(
                        padding:const  EdgeInsets.fromLTRB(10,2,10,20),
                                  child: Row(
                                    children: [
                                       InkWell(
                                           onTap:(){
                                             Get.to(()=>friend_profile(userName, userDoc.id, bio, photo,isBlockedSnapshot.data?.data()?['isblocked']));
                                           },
                                           child: CircleAvatar(radius:30,backgroundImage: NetworkImage("$photo"),)),
                                      const SizedBox(width: 10,),
                                      Container(
                                        width:Width-(80+10+Width-(Width-40)),
                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("${userName}",style:TextStyle(color:theme.textFieldTextColor,fontWeight: FontWeight.bold,fontSize:18),),
                                            lastMessageDoc['sendby']=='${auth.currentUser!.email}'
                                                ?lastMessageDoc['istext']?SizedBox(
                                              width: Width-(80+50),
                                                  child: Text("You: ${lastMessageDoc['text']}",
                                                     overflow: TextOverflow.fade,
                                                     maxLines:1,
                                                      softWrap: false,
                                                     style:TextStyle(color:provide.isDarkTheme?Colors.white60:Colors.black45,),),
                                                )
                                                :Row(children: [
                                                  Text("You: ",style:TextStyle(color:provide.isDarkTheme?Colors.white60:Colors.black45),),
                                                 Icon(CupertinoIcons.camera_fill,size:18,color:theme.TextColor,),
                                              Text(" Photo",style: TextStyle(color:provide.isDarkTheme?Colors.white60:Colors.black45),)
                                            ],)
                                                :lastMessageDoc['istext']?Text(lastMessageDoc['text'],
                                              overflow: TextOverflow.fade,
                                              maxLines:1,
                                              softWrap: false,style:TextStyle(color:provide.isDarkTheme?Colors.white60:Colors.black45),):Row(children: [
                                              Icon(CupertinoIcons.camera_fill,size:18,color:theme.TextColor,),Text("  Photo",style: TextStyle(color:provide.isDarkTheme?Colors.white60:Colors.black45),)
                                            ],),
                                          ], ),
                                      ),
                                      Container(width:Width-(Width-40),
                                        child: Column(crossAxisAlignment: CrossAxisAlignment.end,mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("${convertTime(lastMessageDoc['Time'])}",style:TextStyle(color:theme.textFieldTextColor,fontWeight: FontWeight.bold),),

                                             CircleAvatar(child:Text("",style:const TextStyle(fontSize:14),),radius: 10,backgroundColor:theme.backgroundhome),
                                          ], ),
                                      ),
                                      // const SizedBox(width:10,),

                                    ],
                                  ),
                                ),
                            ),
                    );
                          },
                        );
                      },
                    );
                  },
                );});}),
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
header(){

}