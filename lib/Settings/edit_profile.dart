import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example/Settings/settings.dart';
import 'package:example/main.dart';
import 'package:example/widgets/custombutton.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  List fields_name=['Name','Email','bio','Password'];
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _bio = TextEditingController();
  final TextEditingController _pass= TextEditingController();
  late List<TextEditingController> fields_controller;
  @override

  final storage=FirebaseStorage.instance.ref().child("images");
  var auth=FirebaseAuth.instance;
  var user= FirebaseFirestore.instance.collection("accounts").doc("${FirebaseAuth.instance.currentUser?.email}");
  File? selectedImage;
  var photo;  var filePath;
  final picker = ImagePicker();
  var result;

var pic,Url;
  _pickFile(var res) async {
    if (res == null) return;
    // final file=File(res!.path!);
    try{
      var Store=FirebaseStorage.instance.ref();
      var r_name=Random().nextInt(100000);
      final pathh="files/$r_name${res.name}";
      final file=File(res!.path!);
    final upload= await Store.child(pathh).putFile(file);
     Url=await Store.child(pathh).getDownloadURL();
        await FirebaseFirestore.instance
            .collection("accounts")
            .doc("${auth.currentUser?.email}").update({
          "name":"${_name.text}",
          "password":"${_pass.text}",
          "bio":"${_bio.text}",
          "photo":"$Url"
        }).then((value)async{
          await auth.currentUser!.updateProfile(displayName: _name.text,photoURL:Url.toString() );
          // auth.currentUser!.updatePhotoURL();
        });
    }
    catch(e){print("ERROR: $e");}

  }
  Future<void> get_password() async {
    try {
      var userEmail = await FirebaseAuth.instance.currentUser?.email;
      if (userEmail != null) {
        var documentSnapshot = await FirebaseFirestore.instance
            .collection('accounts')
            .doc(userEmail)
            .get();

        if (documentSnapshot.exists) {
          setState(() async{
           _pass.text=await documentSnapshot.get('password'); // Access the password field
           _bio.text=await documentSnapshot.get('bio'); // Access the password field
           // photo=await documentSnapshot.get('photo'); // Access the password field
          });
        } else {
          print('Document does not exist');
        }
      }
    } catch (e) {
      print('Error fetching password: $e');
    }
  }
  Future<void> _pickImageFromGallery() async {
    try {
      result = await picker.pickImage(source: ImageSource.gallery);
      if (result != null) {
        setState((){
          selectedImage = File(result.path);
          filePath=selectedImage;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }}
var Photo;
  void initState() {
    // TODO: implement initState
    _name.text=auth.currentUser!.displayName!;
    _email.text=auth.currentUser!.email!;
    Photo=auth.currentUser!.photoURL.toString();
    // filePath= filePath.replaceFirst("File: '", "");
    // filePath= filePath.replaceAll("'", "");
    // selectedImage=File(filePath);
   get_password();

    // _name.text=auth.currentUser!.;
    fields_controller=[_name,_email,_bio,_pass];
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
                gradient: LinearGradient(colors:[accentPurple,pinkyy])
            ),
              // child: Text("Hello! \n ${auth.currentUser!.displayName}",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.white),),
            ),
          ),


          Container(
            height:550,
          padding:const EdgeInsets.fromLTRB(20,5,20,0),
          margin: const EdgeInsets.fromLTRB(20,150,20,0),
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
                    const SizedBox(height:15)
                  ],
                ),
              ],
            ),
          ),


          Container(
            decoration: BoxDecoration(color:pinkyy,
                borderRadius:BorderRadius.circular(100)),
            margin: const EdgeInsets.only(top:80,left:15),
            child:Stack(alignment: Alignment.center,
              children: [
              CircleAvatar(
                  radius:80,backgroundImage:
             selectedImage.toString() =='null'?
             NetworkImage(Photo) as ImageProvider
                  : FileImage(selectedImage!),
             //    ,
                )
                , Container(margin: const EdgeInsets.fromLTRB(110,120,20,0),
                  child: CircleAvatar(backgroundColor: Colors.grey,
                    radius:20,child:IconButton(onPressed: (){
                      _pickImageFromGallery();
                    }, icon:const Icon(CupertinoIcons.camera_fill,size:18,)) ,),
                ),
              ],
            ),
          ),


          Container(margin: EdgeInsets.only(bottom:80),
            child: Align(alignment: Alignment.bottomCenter,
              child:
              CustomButton(onTap: ()async{
                // auth.currentUser!.updateDisplayName(_name.text);
              auth.currentUser!.updatePassword(_pass.text);
              _pickFile(result);
              Fluttertoast.showToast(
                msg: "           Saved           ",
                toastLength: Toast.LENGTH_SHORT,
                textColor: Colors.white,
                fontSize:18,gravity:ToastGravity.CENTER,
                backgroundColor:accentPurpleColor,
              ).then((value) => Get.to(()=>settings("${auth.currentUser!.displayName}","${auth.currentUser!.photoURL}")),);}, text:"Save",width: 150.0,height: 50.0,)
            ),
          ),


          Container(
            margin: const EdgeInsets.fromLTRB(10,30,10,10),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(onPressed: () {
                     // Navigator.of(context).pop();
                      Get.to(()=>settings("${auth.currentUser!.displayName}","${auth.currentUser!.photoURL}"));
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
