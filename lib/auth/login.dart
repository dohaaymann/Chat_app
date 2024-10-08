import 'dart:ui';
import 'package:example/messages.dart';
import 'package:example/widgets/customtext.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Constant/colors.dart';
import '../widgets/custombutton.dart';
import 'change_password.dart';
class login extends StatefulWidget {
  const login({Key? key}) : super(key: key);

  @override
  State<login> createState() => _loginState();
}
var n=1;
class _loginState extends State<login> {
  @override
  final _formKey = GlobalKey<FormState>();
  final lemail=TextEditingController();
  final lpass=TextEditingController();
  var auth=FirebaseAuth.instance;
  bool l=true,waitt=true;

  Widget build(BuildContext context) {

    login() async {
      if (_formKey.currentState!.validate()) {
        var user;
        try {
          user = await auth.signInWithEmailAndPassword(
              email: lemail.text, password: lpass.text)
              .catchError((err) {
            if (err.code == "invalid-email") {
              return Get.snackbar(
                  "Error", "Please enter a valid email address",colorText: Colors.white,
                  backgroundColor: Colors.red);
            }
            if (err.message ==
                "The password is invalid or the user does not have a password.") {
              return Get.snackbar(
                  "Error", "ًWrong email address or password",colorText: Colors.white,
                  backgroundColor: Colors.red);
            }
            if (err.message ==
                "There is no user record corresponding to this identifier. The user may have been deleted.") {
              return Get.snackbar(
                  "Error", "Email is not register with us",colorText: Colors.white,
                  backgroundColor: Colors.red);
            }
            return Get.snackbar("Error", err.message,
                backgroundColor: Colors.red);
          });
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found') {
            print('No user found for that email.');
          } else if (e.code == 'wrong-password') {
            print('Wrong password provided for that user.');
          }
        }
        if (user != null) {
          print("------ login successfuly-------");
          print("email: " + "${lemail.text}");
          print("pass: " + "${lpass.text}");
          setState(() {
            waitt=!waitt;
          });
          Future.delayed(const Duration(seconds:5), () {
          Get.to(()=> messages({"${FirebaseAuth.instance.currentUser!.uid}"}));
          });
        }
      }
    }

    return Column(children: [
      SizedBox(height:80,),

          // Container( margin: EdgeInsets.only(left:10,bottom: 5),alignment: Alignment.topLeft,
          //     child: Text('Hello!',style: TextStyle(fontFamily:"ProtestStrike-Regular",fontSize:35,color: Colors.white),)),
          Container( margin: EdgeInsets.only(left:10,bottom: 5),alignment: Alignment.topLeft,
              child: Text("Welcome \nBack..",style: TextStyle(fontFamily:"ProtestStrike-Regular",letterSpacing:5,fontSize:45,color: Colors.white,fontWeight: FontWeight.bold),)),

          SizedBox(height:200,),
          SingleChildScrollView(physics: AlwaysScrollableScrollPhysics(),
            child: Form(
              key:_formKey,
              child: Column(
                  children: [
                    Container(
                        margin: EdgeInsets.only(left: 10,right: 10),
                        child:customtext("Email",lemail)
                    ),
                    Container(
                      margin: EdgeInsets.only(top:30,left: 10,right: 10),
                      child: customtext("Password",lpass),
                    ),

                    Align(alignment:Alignment.topRight,child: TextButton(onPressed: (){
                      Get.to(()=>change_pass());
                      }, child: Text("Forget Password?",style:TextStyle(fontSize:17,color: Colors.black54,fontWeight: FontWeight.bold),))),
                    SizedBox(height:8,),
                    waitt? CustomButton(text: "Login",onTap:()async{
                      await login();
                    },height:50.0,width:150.0):CircularProgressIndicator()]
              ),
            ),
          ),
        ],);
  }
}

