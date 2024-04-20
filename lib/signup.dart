import 'package:example/face.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home.dart';


class signup extends StatelessWidget {
  @override
  var email,pass;
  var showpass=true;
  final auth=FirebaseAuth.instance;
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign up Now",style:TextStyle(fontSize: 20))),
      body:
      Center(
          child:Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(margin:EdgeInsets.all(10),child:
              Text("Creat an account",style:TextStyle(fontSize: 30,fontWeight: FontWeight.bold),)),


              Container( alignment: Alignment.centerLeft,margin: EdgeInsets.only(left: 10,),
                  child: Text("Email",style:TextStyle(fontSize: 20),)),


              Container( margin: EdgeInsets.all(8),
                  child: TextFormField(onChanged:(value) => email=value,cursorColor: Colors.indigo,
                      decoration:InputDecoration(border: OutlineInputBorder(borderRadius:BorderRadius.circular(20)),
                        hintText: "Enter your email",
                      ))),

              Container( alignment: Alignment.centerLeft,margin: EdgeInsets.only(left: 10,),
                  child: Text("Password",style:TextStyle(fontSize: 20),)),


              Container( margin: EdgeInsets.all(8),
                  child: TextFormField(onChanged: (value) => pass=value,cursorColor: Colors.indigo,obscureText:showpass,
                      decoration:InputDecoration(suffixIcon: IconButton(onPressed: (){                          // (() {
                        // showpass=false;
                      }, icon:Icon(Icons.password)),border: OutlineInputBorder(borderRadius:BorderRadius.circular(20)),
                        hintText: "Enter your password",
                      ))),

              ElevatedButton(onPressed:() async {
                var user=await auth.createUserWithEmailAndPassword(email: email, password: pass);
                await FirebaseFirestore.instance.collection("accounts").doc("${email}").set(
                    {"time":DateTime.now()});
                print("-------------");
                print("email: "+"$email");
                print("pass: "+"$pass");
                if(user!=null){
                 Navigator.of(context).push(MaterialPageRoute(builder: (context) => face()));
                }},
                  child:Text("Create account")),
              Row( mainAxisAlignment:MainAxisAlignment.center,children: [Text("Already have an account?"),
                TextButton(onPressed: (){ Navigator.of(context).pushNamed("MyHomePage");},
                    child: Text("Sign in",style:TextStyle(fontWeight: FontWeight.bold),))],),

            ],
          )
      ),
    );}}