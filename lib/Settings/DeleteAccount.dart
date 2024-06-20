import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example/widgets/customtext.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// import '../Bool.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../Constant/colors.dart';
import '../auth/auth.dart';
import '../widgets/custombutton.dart';

class DeleteAccount extends StatefulWidget {
  @override
  var name, photo, email;
  DeleteAccount(
      this.name,this.email,this.photo
      );

  State<DeleteAccount> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  @override
  final auth = FirebaseAuth.instance;
 var password,obscure = true;
  var pass = TextEditingController();

check_password()async{
    if(pass.text.isEmpty){
      Get.snackbar("Error","Please enter your password",colorText: Colors.white,
          backgroundColor: Colors.red);
    }
    else if(pass.text.toString()==password.toString()){
      Get.defaultDialog(title:"Delete your account?",content:
      Text("you will lose all your data by deleting your account. this action cannot be undone",textAlign: TextAlign.center,),
        textConfirm: "Delete my acount",
        textCancel: "No I've changed my mind",
        onConfirm: ()async{
          await deleteAccount();
        }
      );
    }else if(pass.text.toString()!=password.toString()){
      Get.snackbar("Error","Wrong Password",colorText: Colors.white,
      backgroundColor: Colors.red);
    }
}
  void _initAsync() async {
    await get_data();
  }

  Future<void> get_data() async {
    var userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail != null) {
      var documentSnapshot = await FirebaseFirestore.instance
          .collection('accounts')
          .doc(userEmail)
          .get();

      if (documentSnapshot.exists) {
        String fetchedPassword = documentSnapshot.get('password');
        setState(() {
          password = fetchedPassword; // Access the password field
        });
      }
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initAsync();
  }
  Future<void> deleteAccount() async {
    User? user = FirebaseAuth.instance.currentUser;
    CircularProgressIndicator();
    if (user != null) {
      try {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password!, // Ensure that the password is obtained and stored securely
        );

        await user.reauthenticateWithCredential(credential);

        // After successful reauthentication, delete the user
        await user.delete();

        // Delete the corresponding Firestore document
        await FirebaseFirestore.instance.collection("accounts").doc(user.email).delete();
        print("done");
        CircularProgressIndicator();
        Future.delayed(Duration(seconds: 5),(){
          Get.to(() => auth_p());
        });

      } catch (e) {
        print("#############$e");
        if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
          // Handle the specific case of recent login required
          print('The user needs to reauthenticate.');
        }
      }
    }
  }
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Delete my account",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Container(padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(widget.photo.toString()),
                  ),
                  SizedBox(width: 10,),
                  Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${widget.name}",style: TextStyle(fontSize:20,fontWeight: FontWeight.bold),),
                      Text("${widget.email}",style: TextStyle(fontSize:18),),
                    ],
                  )
                ],
              ),
              Divider(),
              SizedBox(height:5,),
              Text(
                "Confirm Your password",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              SizedBox(height:10,),
              Text(
                "complete the delete process by entering the password associated with your account",
                style: TextStyle(fontSize: 18, color: Colors.black54,fontWeight: FontWeight.w500),
              ),
              SizedBox(height:10,),
              TextFormField(
                controller: pass,
                obscureText: obscure,style: TextStyle(fontSize:18),
                decoration: InputDecoration(
                    border:UnderlineInputBorder(),
                    hintText: "Password",
                    suffixIcon: IconButton(
                      icon: !obscure
                          ? Icon(Icons.remove_red_eye, color: pinkyy)
                          : FaIcon(CupertinoIcons.eye_slash, color: pinkyy),
                      onPressed: () {
                        setState(() {
                          obscure = !obscure;
                        });
                      },
                    )),
              ),
              SizedBox(height: 20,),
              Align(alignment:Alignment.center,child: CustomButton(
                onTap: ()async{await check_password(); }
                ,text: "Delete account",height: 50.0,width:200.0,))
            ],
          ),
        )

        // Container(height: double.infinity,
        //   decoration:BoxDecoration(color:Colors.white),
        //   child: Padding(
        //     padding: const EdgeInsets.all(8.0),
        //     child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [
        //           Text("You are about to delete your account.",style: TextStyle(fontSize: 20),),
        //           Padding(
        //             padding: const EdgeInsets.only(top: 12.0,bottom: 12),
        //             child: Text("Just so you know,whem you delete your account ,you will..",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
        //           ),
        //           SizedBox(height: 400,
        //             child: ListView(children: [
        //               Container(margin: EdgeInsets.only(bottom: 8),height:70,color: Colors.yellow,child: Row(children: [
        //                 Padding(
        //                   padding: const EdgeInsets.only(left: 8,right: 8),
        //                   child: FaIcon(FontAwesomeIcons.table,size:30,),
        //                 ),
        //                 Text("Lose Your order history",style: TextStyle(fontSize: 20),),]),
        //               ),
        //               Container( margin: EdgeInsets.only(bottom: 8),height:70,
        //                 color: Colors.yellow,child: Row(children: [
        //                   Padding(
        //                     padding: const EdgeInsets.only(left: 8,right: 8),
        //                     child: FaIcon(FontAwesomeIcons.user,size:30,),
        //                   ),
        //                   Text("Erase all your personal infornation",style: TextStyle(fontSize: 20),),]),
        //               ),
        //               Container( margin: EdgeInsets.only(bottom: 8),height:70,
        //                 color: Colors.yellow,child: Row(children: [
        //                   Padding(
        //                     padding: const EdgeInsets.only(left: 8,right: 8),
        //                     child: FaIcon(FontAwesomeIcons.heart,size:30,),
        //                   ),
        //                   Text("Lose Your favorites",style: TextStyle(fontSize: 20),),]),
        //               ),
        //             ],),
        //           ),
        //           SizedBox(height:80,),
        //           Card(child:  InkWell(onTap:()async{
        //             await auth.currentUser?.delete().then((value)async {
        //               // await FirebaseFirestore.instance.collection("account").doc(auth.currentUser?.email).delete().then((value) => print("done"));
        //               Get.to(()=>auth_p());
        //             }).catchError((e){print("#############$e");});
        //           },
        //               child: Container(width: double.maxFinite,alignment: Alignment.center,
        //                 decoration:BoxDecoration(borderRadius: BorderRadius.circular(20),color: Colors.grey),
        //                 height:60,child:Text("DELETE ACCOUNT",style: TextStyle(color:Colors.red,fontSize: 23,fontWeight: FontWeight.bold),),)),)
        //         ]),
        //   ),
        // )
        );
  }
}
