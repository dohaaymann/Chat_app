import 'package:example/auth/auth.dart';
import 'package:example/chatscreen.dart';
import 'package:example/auth/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example/pages/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

import 'Constant/colors.dart';

class messages extends StatefulWidget {
  final id;
 messages(this.id);

  @override
  State<messages> createState() => _messagesState();
}
var auth=FirebaseAuth.instance;
// var user=FirebaseFirestore.instance.collection(widget.id);
var acc=FirebaseFirestore.instance.collection("accounts");
var lmessage=FirebaseFirestore.instance
    .collection("accounts")
    .doc("${auth.currentUser?.email}")
    .collection("mess")
    .doc("doha@gmail.com")
    .collection("chat").orderBy('Time',descending: false);
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
      chats.add(doc.id);
    });
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
                gradient: LinearGradient(colors: [pinkyy,pinkyy,accentPinkColor])
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
                            Get.to(()=>ChatScreen(s_list[index],s_list[index].toString()));
                            // Get.to(()=>chat(s_list[index],s_list[index].toString()));
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
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Text("no");
                    }

                    // Fetching users from "mess" collection
                    List<DocumentSnapshot> userDocs = snapshot.data!.docs;

                    return ListView.builder(shrinkWrap: true,
                      itemCount: userDocs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot userDoc = userDocs[index];
                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("accounts")
                              .doc("${auth.currentUser?.email}")
                              .collection("mess")
                              .doc(userDoc.id) // Using doc.id to get each user's document ID
                              .collection("chat")
                              .orderBy('Time', descending: true) // Assuming 'Time' is the field for timestamp
                              .limit(1) // Limit to fetch only the last message
                              .snapshots(),
                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
                            if (chatSnapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            if (chatSnapshot.hasError) {
                              return Text('Error: ${chatSnapshot.error}');
                            }
                            if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
                              return const Text('No messages available');
                            }

                            // Fetching the last message document
                            DocumentSnapshot lastMessageDoc = chatSnapshot.data!.docs.first;

                            // Now you can use lastMessageDoc data to display the last message for each user
                            // Example: lastMessageDoc['message'], lastMessageDoc['Time'], etc.
                    return  InkWell(onTap: () async{
                            Get.to(()=>ChatScreen(userDoc.id,userDoc.id.toString()));
                            print("${auth.currentUser!.email}");
                            print("${auth.currentUser!.photoURL}");
                            print("${auth.currentUser!.phoneNumber}");
                            print("${auth.currentUser!.displayName}");
                            // await auth.getRedirectResult().
                            // auth.currentUser!.updateDisplayName("Doha ayman");
                          },
                              child:Container(padding:const  EdgeInsets.fromLTRB(10,2,10,20),
                                child: Row(
                                  children: [
                                    const CircleAvatar(radius:30,backgroundImage: AssetImage("image/2.jpg"),),
                                    const SizedBox(width: 10,),
                                    Column(crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("${userDoc.id}",style: const TextStyle(fontWeight: FontWeight.bold,fontSize:18),),
                                        lastMessageDoc['sendby']=='${auth.currentUser!.email}'
                                            ?Text("You: ${lastMessageDoc['text']}")
                                            :Text(lastMessageDoc['text']),
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
                          );
                          },
                        );
                      },
                    );
                  },
                ),
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
                    Get.to(()=>settings());

                    print("${auth.currentUser!.photoURL}");


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
