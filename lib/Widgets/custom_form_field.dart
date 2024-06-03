import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final String hintText;
  final double height;
  final RegExp validationRegExp;

  const CustomFormField({
    super.key,
    required this.hintText,
    required this.height,
    required this.validationRegExp
  });

  @override
  Widget build(BuildContext context) {
    print('Validation regex: $validationRegExp');
    return SizedBox(
      height: height,
      child: TextFormField(

        validator: (val){
          print('Validator called');
          if(val != null && validationRegExp.hasMatch(val)){
            print('Input is valid');

            return null;
          }
          print('Input is invalid');
          return "Enter a valid ${hintText.toLowerCase()}";
        },
        decoration: InputDecoration(
          hintText: hintText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
