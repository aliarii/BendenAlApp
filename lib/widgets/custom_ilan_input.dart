
import 'package:flutter/material.dart';

class CustomIlanInput extends StatelessWidget {
  final String hintText;
  final Function(String) onChanged;
  final Function(String) onSubmitted;
  final FocusNode focusNode;
  final double onHoriz;
  final double onVer;
  final double onHeight;
  final TextInputAction textInputAction;


  CustomIlanInput({this.hintText, this.onChanged, this.onSubmitted, this.focusNode, this.textInputAction,this.onHoriz,this.onVer,this.onHeight});


  @override
  Widget build(BuildContext context) {

    return Container(

      height: onHeight,

      margin: EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 24.0,
      ),
      decoration: BoxDecoration(
          color: Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(12.0)
      ),

      child: TextField(

        keyboardType: TextInputType.multiline,
        maxLines: null,
        focusNode: focusNode,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: textInputAction,

        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText ?? "Hint Text...",

            contentPadding: EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 8.0,

            )
        ),

      ),
    );
  }
}
