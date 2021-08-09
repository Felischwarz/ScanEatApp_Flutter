import 'package:flutter/material.dart';

import '../style.dart';

class SEATextFormField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final Function validator;

  SEATextFormField({this.labelText, this.controller, this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: ScanEatAppStyle.currentTheme.textTheme.subtitle1,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: ScanEatAppStyle.currentTheme.textTheme.subtitle1.color,
              width: 0.0),
        ),
      ),
      controller: controller,
      validator: validator,
    );
  }
}
