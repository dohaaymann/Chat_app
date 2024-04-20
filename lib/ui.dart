import 'package:example/links.dart';
import 'package:example/ne.dart';
import 'package:example/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class ui extends StatefulWidget {
  final id;
 ui(this.id);

  @override
  State<ui> createState() => _uiState();
}
var auth=FirebaseAuth.instance;
// var user=FirebaseFirestore.instance.collection(widget.id);
var acc=FirebaseFirestore.instance.collection("accounts");
// stream:FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").snapshots(),


class _uiState extends State<ui> {
  @override
  final _sendto=new TextEditingController();
  final _message=new TextEditingController();
  var idD;
  var docid,messid;
  var h=DateTime.now().hour;
  var m=DateTime.now().minute;
  bool visable=false,issearch=false;
  List s_list=[];
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
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:  FloatingActionButton(onPressed: ()async{
      return await showDialog(context: context, builder:(context) {
        return AlertDialog(
          shape:UnderlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
          title: Text("New Message",textAlign: TextAlign.center,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          actions: [
            TextFormField( controller: _sendto,
              decoration: InputDecoration( hintText:"Send message to..",focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue, width: 3)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    gapPadding: 10,
                    borderSide: BorderSide(color: Colors.grey)),),),


            Padding(padding: EdgeInsetsDirectional.all(5)),


            TextFormField( controller: _message,
              decoration: InputDecoration( hintText:"The Message..",focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue, width: 3)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    gapPadding: 10,
                    borderSide: BorderSide(color: Colors.grey)),),),
            Row( mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container( margin:EdgeInsetsDirectional.only(top: 10,end: 5),child: ElevatedButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child:Text("Cancel",textAlign: TextAlign.center,style: TextStyle(fontSize: 20),))),

                Container( margin:EdgeInsetsDirectional.only(top: 10,end: 5),child: ElevatedButton(
                    onPressed: () async{
                      // await user.doc(_sendto.text).set({"time": FieldValue.serverTimestamp()});
                      // await user.doc(_sendto.text).collection("mess").doc().set({
                      //   "sendby":auth.currentUser?.email,
                      //   "text":_message.text,
                      //   "time": FieldValue.serverTimestamp(),
                      // });
                    },
                    child:Text("Done",textAlign: TextAlign.center,style: TextStyle(fontSize: 20),))),
              ],)],
        );
      },);

    },
    child: Icon(Icons.add,size:35,)),
      appBar: AppBar(
        backgroundColor: Colors.green,centerTitle: true,
       title: Text("Chats",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize:25),),
       actions: [
         IconButton(onPressed: (){
           setState(() {
             visable=!visable;
             issearch=!issearch;
           });
           print("${auth.currentUser?.email}");
           print("${auth.currentUser?.uid}");
           // print(chats);
         }, icon:Icon(Icons.search,color: Colors.white,size: 30,)),],
      ),
      body:StreamBuilder<QuerySnapshot>(
          stream:FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.data != null) {
            return issearch?
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
                            Get.to(()=>chat(s_list[index],s_list[index].toString()));
                          },
                          child: ListTile(title:Text(s_list[index].toString()),));
                    },),
                ],)
                :ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                return Container(color: Colors.yellow,margin: EdgeInsets.all(10),padding: EdgeInsets.all(10),
                    child: InkWell(onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => chat(doc.id,doc.id.toString()),));
                    print(snapshot.data!.docs[index].id);
                    },
                        child: Text("${doc.id}",style: TextStyle(fontSize: 22),)));
              },
            );
          } else {
            return Container(color: Colors.red,);
          }
        },
      )
    );
  }
}
class messstyle extends StatelessWidget {
  final String? text,sender;
  final bool isme;
  messstyle({required this.text,required this.sender,required this.isme});
  @override
  Widget build(BuildContext context) {
    return
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment:isme? CrossAxisAlignment.end:CrossAxisAlignment.start,
          children: [
            Text(sender!,style: TextStyle(color: Colors.orange),),
            Padding(padding: EdgeInsetsDirectional.all(1)),
            InkWell( onLongPress: (){
              showDialog(context: context, builder:(context) {
                return AlertDialog(
                    shape:UnderlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                    //OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    title: Text("Delete Message ?",textAlign: TextAlign.center,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                    actions:[
                      Column(
                        children:[
                          Text("This message will be deleted for you and other people",style: TextStyle(fontSize: 18),textAlign:TextAlign.center),
                          Padding(padding: EdgeInsetsDirectional.all(5)),
                          Row( mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container( margin:EdgeInsetsDirectional.only(top: 10,end: 5),child: ElevatedButton(
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                  child:Text("Cancel",textAlign: TextAlign.center,style: TextStyle(fontSize: 20),))),


                              Container( margin:EdgeInsetsDirectional.only(top: 10,end: 5),child: ElevatedButton(
                                  onPressed: () async{

                                  },
                                  child:Text("Delete",textAlign: TextAlign.center,style: TextStyle(fontSize: 20),))),
                            ],)],
                      ),
                    ]
                );
              },);},
              child: Material(
                color: isme?Colors.teal:Colors.cyan,
                borderRadius:isme?
                BorderRadiusDirectional.only(
                    topEnd: Radius.circular(1),topStart:Radius.circular(25),bottomEnd: Radius.circular(15),bottomStart: Radius.circular(25) ):
                BorderRadiusDirectional.only(
                    topEnd: Radius.circular(25),topStart:Radius.circular(1),bottomEnd: Radius.circular(25),bottomStart: Radius.circular(15) )
                ,
                //   shape:
                // OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text("$text",style: TextStyle(fontSize: 20,color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      );
  }}