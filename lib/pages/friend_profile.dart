import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example/Constant/colors.dart';
import 'package:example/messages.dart';
import 'package:example/models/sql.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../chatscreen.dart';
import '../models/SettingsProvider.dart';
import '../models/theme.dart';

class friend_profile extends StatefulWidget {
  var name,email,bio,photo,isBlock;
  friend_profile(this.name,this.email,this.bio,this.photo,this.isBlock);

  @override
  State<friend_profile> createState() => _friend_profileState();
}
var auth=FirebaseAuth.instance;

class _friend_profileState extends State<friend_profile> {
  @override
  var sql=SQLDB();
  Block_function()async{
  await FirebaseFirestore.instance
      .collection("accounts")
      .doc("${auth.currentUser?.email}")
      .collection("Blocks").doc("${widget.email}").set({
        'name':widget.name,
        'photo':'${widget.photo}',
      }).then((value)async{
    await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").
            collection("mess").doc('${widget.email}').update({"isblocked":true});
    widget.isBlock=true;
    // await sql.update_isblock(true);
  print("Doneee");
  },);
}
  unblock_function()async{
    await FirebaseFirestore.instance
        .collection("accounts")
        .doc("${auth.currentUser?.email}")
        .collection("Blocks").doc("${widget.email}").delete().then((value)async{
      await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").
      collection("mess").doc("${widget.email}").update({"isblocked":false});
      print("donee");
      widget.isBlock=false;
    },);
  }
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  Widget build(BuildContext context) {
    var provide=Provider.of<SettingsProvider>(context);
    var theme = provide.isDarkTheme ? DarkTheme() : LightTheme();
    return Scaffold(backgroundColor: theme.backgroundhome,
         appBar: AppBar(backgroundColor:theme.backgroundhome,
         automaticallyImplyLeading: false,
           leading: IconButton(onPressed: (){
             Navigator.of(context).pop();
           },icon:Icon(Icons.arrow_back_sharp,color: theme.backArrowColor,size:30,)),
         ),
         body: Center(
           child: Column(
             children: [
               // SizedBox(height:15,),
               Container(padding:EdgeInsets.all(5),decoration: BoxDecoration(color:provide.isDarkTheme?Color(0xff564FF4):Color(0xff6A53A1),
                   borderRadius:BorderRadius.circular(100)),
                 child:
                 CircleAvatar(
                   radius: 80,
                   backgroundImage:NetworkImage("${widget.photo}"),
                   child: FullScreenWidget(
                     disposeLevel: DisposeLevel.High,
                     child: Hero(
                       transitionOnUserGestures: true,
                       tag: "s",
                       child: Container(
                         width: 160,
                         height: 160,
                         decoration: BoxDecoration(
                           shape: BoxShape.circle,
                           image: DecorationImage(
                             image:NetworkImage("${widget.photo}"),
                             fit: BoxFit.cover,
                           ),
                         ),
                       ),
                     ),
                   ),
                 )
               )
               ,Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Text("${widget.name}",style: TextStyle(color:theme.textFieldTextColor,fontSize:25,fontWeight: FontWeight.bold),),
               ),
               Container(
                   margin:EdgeInsets.all(12),padding: EdgeInsets.all(12),
                   decoration: BoxDecoration(
                 color:lightwhite
                       ,borderRadius: BorderRadius.all(Radius.circular(15))
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
                             Navigator.of(context).pop();
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

                   !widget.isBlock?Container(
                       margin:EdgeInsets.fromLTRB(0,10,0,6),
                       child:InkWell(onTap: () {
                         Get.defaultDialog(title: "Block user",titleStyle: TextStyle(fontWeight: FontWeight.bold),
                             content: Text("This user will not able to send you and receive messages from you.",textAlign: TextAlign.center,
                               style:TextStyle(fontSize:16) ,),
                           buttonColor: Colors.red,
                           textConfirm: "Block",
                           onCancel: (){},
                           onConfirm:()async{
                                await Block_function();
                                setState(() {
                                  provide.set_isblock(true);
                                  provide.set_blocks('Blockhim');
                                });
                                Navigator.of(context).pop();
                             },
                         );
                       },
                   child: Text("Block User",style:TextStyle(color:Colors.red,fontSize:20,fontWeight: FontWeight.w500)),)):
                   Container(
                       margin:EdgeInsets.fromLTRB(0,10,0,6),
                       child:InkWell(onTap: () {
                         Get.defaultDialog(title: "Unblock user",titleStyle: TextStyle(fontWeight: FontWeight.bold),
                           content: Text("Do you sure that you want to unblock this user?",textAlign: TextAlign.center,
                             style:TextStyle(fontSize:16) ,),
                           buttonColor: Colors.red,
                           textConfirm: "Unblock",
                           onCancel: (){},
                           onConfirm:()async{
                             await unblock_function();
                             setState(() {
                               provide.set_isblock(false);
                               provide.set_blocks('none');
                             });
                             Navigator.of(context).pop();
                           },
                         );
                       },
                         child: Text("Unblock user",style:TextStyle(color:Colors.red,fontSize:20,fontWeight: FontWeight.w500)),))
               ],),),


               ],

           ),
         ),
    );
  }
}
