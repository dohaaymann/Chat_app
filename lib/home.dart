import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:example/chat.dart';
import 'package:example/signup.dart';

class home extends StatelessWidget {
  @override
  var sendto,sendto2,mess;
  home({required this .sendto,required this .sendto2,});

  final _sendto=new TextEditingController();
  final _sendto2=new TextEditingController();
  var idD;
  var docid,messid;
  var h=DateTime.now().hour;
  var m=DateTime.now().minute;

  CollectionReference user=FirebaseFirestore.instance.collection("chats");
  CollectionReference user1=FirebaseFirestore.instance.collection("chats").doc().collection("mess");

  //CollectionReference c= FirebaseFirestore.instance.disableNetwork();

  void messagestream() async{
    await for(var snapshot in user.snapshots()){
      for(var mess in snapshot.docs){
        print(mess.get("sendto"));
      }
    }
  }
  void messagestreammess() async{
    await for(var snapshot in user1.snapshots()){
      for(var mess in snapshot.docs){
        print(mess.get("text"));
      }
    }
  }

  List messchats=[];
  Widget build(BuildContext context) {
    return
      Scaffold( resizeToAvoidBottomInset: false,
          appBar: AppBar(title:Text("Chats"),leading: IconButton(onPressed: ()async{
            Navigator.of(context).pushNamed("face");
            //await user.add({"sendto":"fofaa"});
          }, icon:Icon(Icons.arrow_back_outlined))),
          floatingActionButton: FloatingActionButton(onPressed: ()async{
            return await showDialog(context: context, builder:(context) {
              return AlertDialog(
                shape:UnderlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                title: Text("New Message",textAlign: TextAlign.center,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                actions: [
                  TextFormField( controller: _sendto,
                    onChanged:(value){ sendto=value;},
                    decoration: InputDecoration( hintText:"Send message to..",focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue, width: 3)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          gapPadding: 10,
                          borderSide: BorderSide(color: Colors.grey)),),),


                  Padding(padding: EdgeInsetsDirectional.all(5)),


                  TextFormField( controller: _sendto2,
                    onChanged:(value){ sendto2=value;},
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
                            // then((DocumentReference doc) async{
                            //    idD=doc.id;
                            //     print("The Document id :${doc.id}");
                            //     print("---------------");
                            //     print(user.id);
                            //     print( user.doc().id);
                            //     print(user.get());
                            //     print(user.path);
                            //     print(user.hashCode);
                            //     print(user.doc());
                            //     print(doc.id.toString());
                            //     print("[][]][[][][]][][][][][][][]");
                            //     print(_sendto.text);
                            //    print(_sendto2.text);
                            //    print(docid.id);
                            //     print("---------------");
                            //      messid=await user.doc(docid.id).collection("mess").add({"text":"${_sendto2.text}"});
                            //    Navigator.of(context).push(MaterialPageRoute(builder: (context) => chat(sendto:_sendto.text,message: _sendto2.text,Id:docid.toString()),));
                            //    print("============================================");
                            //    print("============================================");
                            //  //
                                //var v=await FirebaseFirestore.instance.collection("chats").doc(idD).collection("mess").add({"text":"${_sendto2.text}"});                               print(v);



                            // if({_sendto.text}==null){
                            //   print("nulllllllll");
                            // }
                            // else  if({_sendto.text}==" "&&{_sendto2.text}==" "){
                            //   print("1");
                            //   print("${_sendto.text}");
                            //
                            // } else  if({_sendto.text}==""&&{_sendto2.text}==""){
                            //   print("1");
                            //   print("${_sendto.text}");
                            //
                            // } else if({_sendto.selection}=="TextSelection.invalid"){
                            //   print("7");
                            // }
                            //
                            // else  if({_sendto.text}!='┤├'&&{_sendto2.text}!='┤├'){
                            //   print("2");
                            //   print("${_sendto.text}");
                            //   print("${_sendto2.text}");
                            //   print("${_sendto.value}");
                            //   print("${_sendto.selection}");
                            // }
                            // else  if(sendto2==""){
                            //   print("3");
                            // }else  if({sendto}==""){
                            //   print("4");
                            // }

                            //
                            docid= await FirebaseFirestore.instance.collection("chats").add({"sendto":"${_sendto.text}"});
                            messid=await user.doc(docid.id).collection("mess").add({"text":"${_sendto2.text}"});

                            try{
                              // Navigator.of(context).push(MaterialPageRoute(builder: (context) => chat(sendto:_sendto.text,message: _sendto2.text,Id:docid.id),));
                            print("senddddddd: ${_sendto.text}");
                            print("senddddddd2: ${_sendto2.text}");
                            print("Id:${docid.id}");
                            } catch(e){
                              print("========================");
                              print(e);
                              print("========================");
                            }
                            // Navigator.of(context).push(MaterialPageRoute(builder: (context) => chat(sendto:_sendto.text,message: _sendto2.text,Id:docid.id),)).
                            //                     then((value) {
                            //                       _sendto2.clear();
                            //                       _sendto.clear();
                            //                       print("senddddddd: ${_sendto.text}");
                            //                       print("senddddddd2: ${_sendto2.text}");
                            //                       print(_sendto2.text);
                            //                     });
                            print("---------------");
                            print(_sendto.text);
                            print(_sendto2.text);
                            print(docid.id);
                            print("---------------");

                          },
                          child:Text("Done",textAlign: TextAlign.center,style: TextStyle(fontSize: 20),))),
                    ],)],
              );
            },);

          },
              child: Icon(Icons.add,size:35,)),
          body:
          Column(
            children: [ ElevatedButton(onPressed: ()async{
              try {
                var z = FirebaseAuth.instance.currentUser!.email;
                print(z);
              }catch(e){
                print(e);
              }


    }, child:Text("click")),
              Expanded(
                child: StreamBuilder(
                  stream: user.snapshots()!
                 // stream: user.doc(Id).collection("mess").snapshots()
                  ,builder: (context, snapshot) {
                  List<Text>messageT=[];
                  for(var message in snapshot.data!.docs) {
                    final messageget=message.get("sendto");
                    final messagew=Text("$messageget");
                    messageT.add(messagew);
                  }
                  return ListView.builder(
                    itemCount:snapshot.data!.docs.length ,shrinkWrap: true,
                    itemBuilder: (context, i) {
                      DocumentSnapshot data=snapshot.data!.docs[i];
                      return Container(  margin: EdgeInsets.all(10),decoration:
                      BoxDecoration(borderRadius:BorderRadiusDirectional.circular(25),color: Colors.teal),
                        child: InkWell(
                          onLongPress: () async {print("---------------");
                          // CollectionReference user1=FirebaseFirestore.instance.collection("chats").doc().collection("mess");
                        //  DocumentSnapshot data1=snapshot.data!.docs[i].data!.doc[i];
                         // print(data1['text'].toString());
                          var c=await FirebaseFirestore.instance.collection("chats").doc(data.id).collection("mess");
                          print(data.id);
                          print(c.id);
                          print("---------------");
                          },
                          onTap: () {
                            print("tape");
                            try{
                            //   Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                            //     chat(sendto:data['sendto'],message:null,Id:data.id),)).
                            // then((value) => print("dona y btttttttttttttttttttt"));

                            }
                            catch(e){
                              print("========================");
                              print(e);
                              print("========================");
                            }




                          },child: ListTile(
                          // subtitle: Text(data['acc'],style: TextStyle(color: Colors.white),),
                          title: Text((data['sendto']!).toString(),style: TextStyle(color: Colors.white,fontSize: 25,),),
                          // leading: Text("$h:$m",style: TextStyle(color: Colors.white),),
                          trailing: IconButton(onPressed:() async{
                            //  docid= await FirebaseFirestore.instance.collection("chats").add({"sendto":"${_sendto.text}"});
                            // messid=await user.doc(docid.id).collection("mess").add({"text":"${_sendto2.text}"});

                            // docid= await FirebaseFirestore.instance.collection("chats").add({"sendto":"marwannnnnn"});
                            // messid=await user.doc(docid.id).collection("mess").add({"text":"Fuckkkkkkkk"});

                            await user.doc(snapshot.data!.docs[i].id).delete();
                            await user.doc(snapshot.data!.docs[i].id).collection("mess").doc(snapshot.data!.docs[i].id).delete();
                          }, icon: Icon(Icons.delete,color: Colors.white,)),
                        ),
                        ),
                      );
                    },
                  );
                },),
              )
            ],
          )
      );
  }}