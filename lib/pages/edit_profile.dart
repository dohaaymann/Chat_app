import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example/pages/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../Constant/colors.dart';

class edit_profile extends StatefulWidget {
  const edit_profile({Key? key}) : super(key: key);

  @override
  State<edit_profile> createState() => _edit_profileState();
}

class _edit_profileState extends State<edit_profile> {
  @override
  bool obscure=true;
  List fields_name=['Name','Email','Password'];
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass= TextEditingController();
  late List<TextEditingController> fields_controller;
  @override

  final storage=FirebaseStorage.instance.ref().child("images");
  var auth=FirebaseAuth.instance;
  var user= FirebaseFirestore.instance
      .collection("accounts")
      .doc("${FirebaseAuth.instance.currentUser?.email}");
  Future<void> get_password() async {
    try {
      var userEmail = FirebaseAuth.instance.currentUser?.email;
      if (userEmail != null) {
        var documentSnapshot = await FirebaseFirestore.instance
            .collection('accounts')
            .doc(userEmail)
            .get();

        if (documentSnapshot.exists) {
          setState(() {
           _pass.text=documentSnapshot.get('password'); // Access the password field
          });
        } else {
          print('Document does not exist');
        }
      }
    } catch (e) {
      print('Error fetching password: $e');
    }
  }
  File? selectedImage;
  var photo;
  late String _responseText;
  final picker = ImagePicker();

  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          selectedImage = File(pickedFile.path);
          // auth.currentUser!.updatePhotoURL(selectedImage.toString());
          photo=selectedImage;
        });
        print("///////////////");
        print("$selectedImage");
        print("///////////////");
      }
    } catch (e) {
      print('Error picking image: $e');
    }}
  void initState() {
    // TODO: implement initState
    _name.text=auth.currentUser!.displayName!;
    _email.text=auth.currentUser!.email!;
    var filePath=auth.currentUser!.photoURL.toString();
    filePath= filePath.replaceFirst("File: '", "");
    filePath= filePath.replaceAll("'", "");
    photo=File(filePath);
   get_password();
    // _name.text=auth.currentUser!.;
    fields_controller=[_name,_email,_pass];
    super.initState();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body:Stack(
        children: [
          Align( alignment :Alignment.bottomRight,
            child: Container(
              // margin: const EdgeInsets.only(top:200),
              decoration: const BoxDecoration(shape: BoxShape.rectangle,
                color:Color(0xffFCD8DC),
                // borderRadius: BorderRadius.vertical(top: Radius.circular(20))
              ),),
          ),
          ClipPath(
            clipper: WaveClipperOne(),
            child: Container(height:200,decoration: BoxDecoration(
                gradient: LinearGradient(colors: [pinkyy,pinkyy,accentPinkColor,lightpinkyy])
            ),
              // child: Text("Hello! \n ${auth.currentUser!.displayName}",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.white),),
            ),
          ),


          Container(
            height: 500,
          padding:const EdgeInsets.fromLTRB(20,5,20,0),
          margin: const EdgeInsets.fromLTRB(20,200,20,0),
          decoration: const BoxDecoration(
            color: Colors.white
          ),
            child:Column(
              children: [
                Align(alignment:Alignment.topRight,child: Text("Hello.. \n    ${auth.currentUser!.displayName}",style: TextStyle(fontSize:20,fontWeight: FontWeight.bold,color:accentPurpleColor),)),
                const SizedBox(height:60,),
                for(int i=0;i<fields_name.length;i++)
                Column(crossAxisAlignment:CrossAxisAlignment.start,
                  children: [
                    Text(fields_name[i],style: const TextStyle(fontWeight: FontWeight.bold,fontSize:20,color:Colors.grey),),
                    Container(
                      height: 50,
                      child: TextFormField(controller: fields_controller[i],readOnly:fields_name[i]=='Email'?true:false,
                        style: TextStyle(fontSize:20, color: fields_name[i]=='Email'?Colors.black87:Colors.black,fontWeight: FontWeight.bold),
                        obscureText:fields_name[i]=='Password'?obscure:false,
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(),suffixIcon:fields_name[i]=='Password'? IconButton(onPressed: (){
                            setState(() {
                              obscure=!obscure;
                            });
                        }, icon:obscure?Icon(CupertinoIcons.eye_slash_fill,color: pinkyy,):Icon(CupertinoIcons.eye,color: pinkyy,)):null,
                          hintText: fields_name[i],hintStyle: TextStyle(fontSize: 20)
                        ),
                      ),
                    ),
                    const SizedBox(height:30)
                  ],
                ),
              ],
            ),
          ),


          Container(
            decoration: BoxDecoration(color:accentPurpleColor,
                borderRadius:BorderRadius.circular(100)),
            margin: const EdgeInsets.only(top:130,left:15),
            child:Stack(alignment: Alignment.center,
              children: [
              CircleAvatar(
                  radius:80,backgroundImage:
              FileImage(photo!),
                )
                , Container(margin: const EdgeInsets.fromLTRB(110,120,20,0),
                  child: CircleAvatar(backgroundColor: Colors.grey,
                    radius:20,child:IconButton(onPressed: (){
                      _pickImageFromGallery();
             print("${auth.currentUser!.photoURL}");

                    }, icon:const Icon(CupertinoIcons.camera_fill,size:18,)) ,),
                ),
              ],
            ),
          ),


          Align(alignment: Alignment.bottomCenter,
            child: InkWell(onTap: (){
              auth.currentUser!.updateDisplayName(_name.text);
              auth.currentUser!.updatePassword(_pass.text);
              auth.currentUser!.updatePhotoURL(selectedImage.toString());
              // Get.showSnackbar(GetSnackBar(title:"sssss",));
            }, child:Container(
              margin: const EdgeInsets.only(bottom: 80),
              width: 150,height:50,alignment: Alignment.center,
                decoration:BoxDecoration(borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(colors: [accentPurpleColor,pinkyy,pinkyy,accentPurpleColor])
            ),
                child: const Text("Save",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 22),))
            ),
          ),


          Container(
            margin: const EdgeInsets.fromLTRB(10,25,10,10),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(onPressed: () {
                     // Navigator.of(context).pop();
                      Get.to(()=>settings());
                    }, icon:const Icon(Icons.arrow_back_ios,color: Colors.white,)),
                    const  SizedBox(width:100,),
                    const Text("Profile",style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold,color: Colors.white),)
                  ],),
                const SizedBox(height:30,),

              ],
            ),
          )
        ],
      ),

    );
  }
}
