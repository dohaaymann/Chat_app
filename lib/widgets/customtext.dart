import 'package:example/Constant/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../models/SettingsProvider.dart';
import '../models/theme.dart';

class customtext extends StatefulWidget {
  // const CustomText({Key? key}) : super(key: key);
  var hinttext;
  final TextEditingController tcontroller;
  final TextEditingController? passwordController;
  customtext(this.hinttext, this.tcontroller, {this.passwordController});

  @override
  State<customtext> createState() => _CustomTextState();
}

class _CustomTextState extends State<customtext> {
  bool obscure = true;

  String? _validateInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty';
    }
    if (widget.hinttext == 'Email' && !GetUtils.isEmail(value)) {
      return 'Please enter a valid email address';
    }
    if (widget.hinttext == 'Password' && value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    if (widget.hinttext == 'Name' && value.length < 4) {
      return 'Name must be at least 2 characters long';
    }
    if (widget.hinttext == 'Confirm password') {
      if (widget.passwordController != null &&
          widget.passwordController!.text != value) {
        return 'Passwords do not match';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SettingsProvider>(context);
    return TextFormField(
      onTapOutside: (v) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      controller: widget.tcontroller,
      obscureText: obscure && widget.hinttext == 'Password'||widget.hinttext=='Confirm password' ? true : false,
      style: TextStyle(fontSize: 20, color: Colors.black),
      decoration: InputDecoration(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: 2, color:provider.isDarkTheme?Colors.white60:Colors.black54),
        ),
        suffixIcon: widget.hinttext == 'Password'
            ? IconButton(
          icon: !obscure
              ? Icon(Icons.remove_red_eye, color:provider.isDarkTheme?Colors.white54:Colors.black54)
              : FaIcon(CupertinoIcons.eye_slash, color:provider.isDarkTheme?Colors.white54:Colors.black54),
          onPressed: () {
            setState(() {
              obscure = !obscure;
            });
          },
        )
            : null,
        hintText: widget.hinttext,
        prefixIcon:widget.hinttext == 'Password'||widget.hinttext=='Confirm password'?Icon(Icons.lock):
                    widget.hinttext=='Email'?Icon(Icons.email):
                    widget.hinttext=='Name'?Icon(Icons.person):null,
        hintStyle: TextStyle(color:Colors.grey),
      ),
      cursorRadius: Radius.circular(50),
      validator: _validateInput,
    );
  }
}
