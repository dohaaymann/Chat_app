import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Constant/colors.dart';
import '../models/SettingsProvider.dart';

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
    var provide=Provider.of<SettingsProvider>(context);
  return InkWell(
      onTap: widget.onTap,
      child: Container(
        width:widget.width,
        height: widget.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: !provide.isDarkTheme?LinearGradient(
            // begin: Alignment.bottomCenter,end: Alignment.topCenter,
              colors: [
                // LIGHT MODE
                // accentPurple,pinkyy
                Color(0xff543863),
                Color(0xff4CBF87),
              ]):LinearGradient(tileMode: TileMode.mirror,
              colors: [
                // DARK MODE
                Color(0xff7B7794),
                Color(0xff231E73),
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
