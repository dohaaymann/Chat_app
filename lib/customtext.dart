import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
class customtext extends StatefulWidget {
  // const customtext({Key? key}) : super(key: key);
  var hinttext, tcontroller;
  customtext(this.hinttext, this.tcontroller);

  @override
  State<customtext> createState() => _customtextState();
}

class _customtextState extends State<customtext> {
  @override
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: () {
        BorderSide(color: Colors.white);
      },
      controller: widget.tcontroller,
      obscureText: obscure&&widget.hinttext == 'Password' ? true : false,
      // cursorColor: Colors.blue,
      style: TextStyle(fontSize: 20, color: Colors.white),
      decoration: InputDecoration(
        enabledBorder: UnderlineInputBorder( //<-- SEE HERE
          borderSide: BorderSide(
              width: 2, color: Colors.white),),
        suffixIcon: widget.hinttext == 'Password' ? IconButton(icon: !obscure
            ? Icon(Icons.remove_red_eye, color: Colors.yellow,)
            :FaIcon(CupertinoIcons.eye_slash,color: Colors.yellow),
          onPressed: () {
            setState(() {
              obscure = !obscure;
            });
          },) : null,
        hintText: widget.hinttext,
        hintStyle: TextStyle(color: Colors.white),

      ),
      cursorRadius: Radius.circular(50),
    );
  }
}