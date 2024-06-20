import 'package:flutter/material.dart';
import '../Constant/colors.dart';

class CustomButton extends StatefulWidget {
  final Function()? onTap;
  final String text;
  var width,height;

  CustomButton({
    required this.onTap,
    required this.text,
    this.height,this.width
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        width:widget.width,
        height: widget.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(colors: [
            accentPurple,
            pinkyy,
          ]),
        ),
        child: Text(
          widget.text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
    );
  }
}
