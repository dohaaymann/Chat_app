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
import 'package:full_screen_image/full_screen_image.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';

import '../Constant/colors.dart';
import '../auth/auth.dart';
import '../models/SettingsProvider.dart';
import '../models/theme.dart';
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
      Get.defaultDialog(
          title:"Delete your account?",content:
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
    var v=Provider.of<SettingsProvider>(context);
    var theme = v.isDarkTheme ? DarkTheme() : LightTheme();
    return Scaffold(
      backgroundColor: theme.backgroundhome,resizeToAvoidBottomInset: false,
        appBar: AppBar(backgroundColor:theme.backgroundhome ,automaticallyImplyLeading: false,
          leading: IconButton(onPressed: (){Navigator.of(context).pop();}, icon:Icon(CupertinoIcons.back,color: theme.TextColor,size:25,)),
          title: Text(
            "Delete my account",
            style: TextStyle(color:theme.TextColor,fontWeight: FontWeight.bold),
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
                      Text("${widget.name}",style: TextStyle(color:theme.TextColor,fontSize:20,fontWeight: FontWeight.bold),),
                      Text("${widget.email}",style: TextStyle(color:theme.TextColor,fontSize:18),),
                    ],
                  )
                ],
              ),
              Divider(),
              SizedBox(height:5,),
              Text(
                "Confirm Your password",
                style: TextStyle(color:theme.TextColor,fontWeight: FontWeight.bold, fontSize: 22),
              ),
              SizedBox(height:10,),
              Text(
                "complete the delete process by entering the password associated with your account",
                style: TextStyle(fontSize: 18, color: v.isDarkTheme?Colors.white60:Colors.black54,fontWeight: FontWeight.w500),
              ),
              SizedBox(height:10,),
              TextFormField(
                onTapOutside: (v){FocusManager.instance.primaryFocus?.unfocus();},
                controller: pass,
                obscureText: obscure,style: TextStyle(color:theme.TextColor,fontSize:18),
                decoration: InputDecoration(
                    border:UnderlineInputBorder(),
                    hintText: "Password",hintStyle: TextStyle(color: theme.TextColor),
                    suffixIcon: IconButton(
                      icon: !obscure
                          ? Icon(Icons.remove_red_eye, color:v.isDarkTheme?Color(0xff2393FF):accentPurple,)
                          : FaIcon(CupertinoIcons.eye_slash,color:v.isDarkTheme?Color(0xff2393FF):accentPurple,),
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
                ,text: "Delete account",height: 50.0,width:200.0,)),

      ],
          ),
        )

        );
  }
}
