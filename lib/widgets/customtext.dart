import 'package:example/Constant/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class customtext extends StatefulWidget {
  // const CustomText({Key? key}) : super(key: key);
  var hinttext;
  final TextEditingController tcontroller;

  customtext(this.hinttext, this.tcontroller);

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

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTapOutside: (v) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      controller: widget.tcontroller,
      obscureText: obscure && widget.hinttext == 'Password' ? true : false,
      style: TextStyle(fontSize: 20, color: Colors.white),
      decoration: InputDecoration(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: 2, color: Colors.white),
        ),
        suffixIcon: widget.hinttext == 'Password'
            ? IconButton(
          icon: !obscure
              ? Icon(Icons.remove_red_eye, color: pinkyy)
              : FaIcon(CupertinoIcons.eye_slash, color: pinkyy),
          onPressed: () {
            setState(() {
              obscure = !obscure;
            });
          },
        )
            : null,
        hintText: widget.hinttext,
        hintStyle: TextStyle(color: Colors.white),
      ),
      cursorRadius: Radius.circular(50),
      validator: _validateInput,
    );
  }
}
