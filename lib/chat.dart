import 'package:example/bot.dart';
import 'package:example/ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:chatview/chatview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example/data.dart';
import 'package:example/models/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class chat extends StatefulWidget {
  var doc,user;
  chat(this.doc,this.user);

  @override
  State<chat> createState() => _chatState();
}

AppTheme theme = LightTheme();
bool isDarkTheme = false;


var auth=FirebaseAuth.instance;
var _messagecont=TextEditingController();

var user=FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess");
Future<bool> doesDocumentExist(String documentPath) async {
  try {
    DocumentReference docRef = FirebaseFirestore.instance.doc(documentPath);
    DocumentSnapshot docSnapshot = await docRef.get();
    return docSnapshot.exists;
  } catch (e) {
    print('Error checking document existence: $e');
    return false; // Return false in case of error
  }
}
class _chatState extends State<chat> {
  @override
  void initState() {
    super.initState();
  }
  @override
  bool sendtap=false;
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:theme.backgroundColor,
        appBar:AppBar(
          elevation: theme.elevation,
          backgroundColor: theme.appBarColor,
          // profilePicture: Data.profileImage,
          // backArrowColor: theme.backArrowColor,
          title: Text("${widget.user}"),
          titleTextStyle: TextStyle(
            color: theme.appBarTitleTextStyle,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.25,
          ),
          // userStatus: "online",
          // userStatusTextStyle: const TextStyle(color: Colors.grey),
          actions: [
            IconButton(
              onPressed: _onThemeIconTap,
              icon: Icon(
                isDarkTheme
                    ? Icons.brightness_4_outlined
                    : Icons.dark_mode_outlined,
                color: theme.themeIconColor,
              ),
            ),
            IconButton(
              tooltip: 'Toggle TypingIndicator',
              onPressed: ()async{
                // initState();
              },
              icon: Icon(
                Icons.keyboard,
                color: theme.themeIconColor,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                // stream:FirebaseFirestore.instance.collection("${auth.currentUser?.email}").doc(widget.doc).collection("mess").snapshots(),
                // stream:FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(widget.user).collection("chat").orderBy('time').snapshots(),
                stream:FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(widget.user).collection("chat").orderBy("Time").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    // Data is fetched successfully
                    final data = snapshot.data!;
                    return ListView.builder(shrinkWrap:true,reverse:false,
                      itemCount: data.docs.length,
                      itemBuilder: (context, index) {
                        final doc = data.docs[index];
                        var c=FirebaseAuth.instance.currentUser!.email;
                        return messstyle(text:doc.data()['text'].toString(),isUser:doc.data()['sendby'].toString()==auth.currentUser?.email.toString()?true:false,messageTime:doc.data()['Time'] ,);
                        // );
                      },
                    );
                  }
                },
              ),
            ),
            Row(children: [
              Visibility(visible: sendtap,
                child:Container(padding: EdgeInsets.all(5),margin: EdgeInsets.all(5),
                  width:MediaQuery.of(context).size.width-10,decoration:BoxDecoration(
                      color: Colors.grey,borderRadius: BorderRadius.all(Radius.circular(20))
                  ),
                  child: TextFormField(
                              cursorColor: Colors.indigo,
                            style: TextStyle(fontSize:18),controller: _messagecont,
                              decoration: InputDecoration(
                  hintText: "Type your message..",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  // suffixIcon:
                              ),
                          ),
                ),),
              Visibility( visible:!sendtap,
                  child:Container(
                    padding: EdgeInsets.all(5),margin: EdgeInsets.all(5),
                    width:MediaQuery.of(context).size.width-10,decoration:BoxDecoration(
                    color: Colors.grey,borderRadius: BorderRadius.all(Radius.circular(20))
                  ),
                    child: Row(children: [
                      Expanded(
                        child: InkWell(onTap: () => setState(() {
                          sendtap=!sendtap;
                        }),
                          child: Row(children: [SizedBox(width:10),
                          Text("Message",style: TextStyle(color: Colors.black45),),],),),
                      ),IconButton(onPressed: (){}, icon:Icon(CupertinoIcons.camera)),
                        IconButton(onPressed: (){}, icon:Icon(CupertinoIcons.photo)),
                        IconButton(onPressed: (){}, icon:Icon(CupertinoIcons.mic)),
                                  ],),
                  ))

            ],)
            // Stack(
            //   children:[ GestureDetector(
            //     child: Container(
            //       height:50,
            //       width:MediaQuery.of(context).size.width,alignment:Alignment.centerRight, margin:EdgeInsets.all(10),
            //       child:TextFormField(
            //         cursorColor: Colors.indigo,
            //       style: TextStyle(fontSize: 19),controller: _messagecont,
            //         decoration: InputDecoration(
            //             hintText: "Type your message..",
            //             errorBorder: OutlineInputBorder(
            //                 borderSide: BorderSide(color: Colors.red)),
            //             border: OutlineInputBorder(
            //                 borderRadius: BorderRadius.only(topRight: Radius.circular(50),
            //                   topLeft: Radius.circular(50),
            //                   bottomRight: Radius.circular(50),
            //                   bottomLeft: Radius.circular(50),)),
            //             // suffixIcon:
            //         ),
            //       ),
            //     ),
            //   ),
            //     Align(alignment:Alignment.bottomRight,
            //       child: IconButton(
            //           onPressed: () async {
            //             String documentPath = 'accounts/${auth.currentUser?.email}/mess/${widget.user}';
            //             bool exists = await doesDocumentExist(documentPath);
            //             String documentPath2 = 'accounts/${widget.user}/mess/${auth.currentUser?.email}';
            //             bool exists2 = await doesDocumentExist(documentPath2);
            //             !exists?await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(widget.user).set({"time": DateTime.now()}):null;
            //             !exists2?await FirebaseFirestore.instance.collection("accounts").doc("${widget.user}").collection("mess").doc("${auth.currentUser?.email}").set({"time": DateTime.now()}):null;
            //             print('Document exists: $exists');
            //             await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(widget.user).collection("chat")
            //                 .add({
            //               "text": "${_messagecont.text}",
            //               "sendby": auth.currentUser?.email,
            //               "Time": DateTime.now()
            //             }).then((value) {print("doneeeeee");});
            //             await FirebaseFirestore.instance.collection("accounts").doc(widget.user).collection("mess").doc("${auth.currentUser?.email}").collection("chat")
            //                 .add({
            //               "text": "${_messagecont.text}",
            //               "sendby": auth.currentUser?.email,
            //               "Time": DateTime.now()
            //             }).then((value) {print("doneeeeee");});
            //             _messagecont.clear();
            //           },
            //           icon: Icon(Icons.send, color: Colors.white,size:20,)),
            //     )
            ]),
    );
  }  void _onThemeIconTap() {
    setState(() {
      if (isDarkTheme) {
        theme = LightTheme();
        isDarkTheme = false;
      } else {
        theme = DarkTheme();
        isDarkTheme = true;
      }
    });
  }
}
class messstyle extends StatelessWidget {
  final String text;
  final bool isUser;
  var messageTime;

  messstyle({
    required this.text,
    required this.isUser,
    required this.messageTime,
  });
  @override
  Widget build(BuildContext context) {
    var userColor=theme.replyTitleColor;
    var repleycolor=Colors.white;
    var userIcon=Icon(Icons.person);
    var repleyIcon=Icon(Icons.android);
    // DateTime roundDateTimeToMinute(DateTime dateTime) {
    //   return dateTime.subtract(Duration(
    //       minutes: dateTime.minute % 1,
    //       seconds: dateTime.second,
    //       milliseconds: dateTime.millisecond,
    //       microseconds: dateTime.microsecond));
    // }
    return Column(
      crossAxisAlignment:
      isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isUser)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: userColor,
                    radius: 20.0,
                    child: repleyIcon,
                  ),
                ),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                margin: EdgeInsets.only(top:10),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: isUser ? userColor :  repleycolor,
                  borderRadius: BorderRadius.all(Radius.circular(20))
                ),
                child: isUser?Text(
                  text,style: const TextStyle(color:Colors.white),
                ):Text(
                  text,style: const TextStyle(color:Colors.black),
                ),
              ),
              if (isUser)
                Padding(padding: EdgeInsets.all(5))
            ],
          ),
        ),
      ],
    );
  }


}