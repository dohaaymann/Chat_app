import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example/Constant/colors.dart';
import 'package:example/messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../chatscreen.dart';

class friend_profile extends StatefulWidget {
  var name,email,bio,photo;
  friend_profile(this.name,this.email,this.bio,this.photo);

  @override
  State<friend_profile> createState() => _friend_profileState();
}

class _friend_profileState extends State<friend_profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: theme.replyDialogColor,
         appBar: AppBar(backgroundColor:theme.replyDialogColor,
         automaticallyImplyLeading: false,
           leading: IconButton(onPressed: (){
             Navigator.of(context).pop();
           },icon:Icon(Icons.arrow_back_sharp,color: theme.backArrowColor,size:30,)),
         ),
         body: Center(
           child: Column(
             children: [
               // SizedBox(height:15,),
               Container(padding:EdgeInsets.all(5),decoration: BoxDecoration(color:theme.repliedMessageColor,
                   borderRadius:BorderRadius.circular(100)),
                 child: CircleAvatar(radius:80,backgroundColor: Colors.pinkAccent,backgroundImage:
                 NetworkImage("${widget.photo}"),),
               )
               ,Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Text("${widget.name}",style: TextStyle(color:theme.textFieldTextColor,fontSize:25,fontWeight: FontWeight.bold),),
               ),
               Container(
                   margin:EdgeInsets.all(12),padding: EdgeInsets.all(12),
                   decoration: BoxDecoration(
                 color:lightwhite,borderRadius: BorderRadius.all(Radius.circular(15))
               ),
                 child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                     Container(
                   margin:EdgeInsets.only(bottom:5),
                   child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                     Text("email",style:TextStyle(fontSize:19)),
                     Text("${widget.email}",style:TextStyle(fontSize:20,fontWeight: FontWeight.bold)),
                     Divider(height: 5,),
                     ],)),

                   
                   Container(
                   margin:EdgeInsets.only(bottom:5),
                   child:const Column(crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                     Text("bio",style:TextStyle(fontSize:19)),
                     Text("Nothing to say.",style:TextStyle(fontSize:20,fontWeight: FontWeight.bold)),
                     Divider(height: 5,),
                     ],)),

                   Container(
                   margin:EdgeInsets.fromLTRB(0,6,0,6),
                   child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       InkWell(
                         onTap:(){
                           Get.defaultDialog(title:"Clear chat",content:Text("Are you Sure you want to clear chat?",textAlign:TextAlign.center,style: TextStyle(fontSize:20),),
                           titleStyle: TextStyle(fontWeight: FontWeight.bold),
                           textConfirm:"Yes",buttonColor:theme.buttonColor,
                           onCancel: () {},
                             onConfirm: ()async{
                             print(widget.email);
                               CollectionReference chatCollection = FirebaseFirestore.instance
                                   .collection("accounts")
                                   .doc("${FirebaseAuth.instance.currentUser?.email}")
                                   .collection("mess")
                                   .doc(widget.email)
                                   .collection("chat");

                               QuerySnapshot chatSnapshot = await chatCollection.get();

                               for (DocumentSnapshot doc in chatSnapshot.docs) {
                                 await doc.reference.delete();
                               }
                             await FirebaseFirestore.instance
                                 .collection("accounts")
                                 .doc("${FirebaseAuth.instance.currentUser?.email}")
                                 .collection("mess")
                                 .doc(widget.email).delete().then((value) => Get.to(()=>messages({"${FirebaseAuth.instance.currentUser!.uid}"})));

                             },
                           );
                         },
                         child: Text("Clear Chat",style:TextStyle(fontSize:20,fontWeight: FontWeight.w500))),
                     ],)),
                   Divider(height: 5,),

                   Container(
                       margin:EdgeInsets.fromLTRB(0,10,0,6),
                       child:InkWell(
                   child: Text("Report User",style:TextStyle(fontSize:20,fontWeight: FontWeight.w500)),)),
                   Divider(height: 5,),

                   Container(
                       margin:EdgeInsets.fromLTRB(0,10,0,6),
                       child:InkWell(
                   child: Text("Block User",style:TextStyle(color:Colors.red,fontSize:20,fontWeight: FontWeight.w500)),)),
               ],),),


               ],

           ),
         ),
    );
  }
}
