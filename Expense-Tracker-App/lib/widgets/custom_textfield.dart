import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  CustomTextField({
    Key? key,
    this.label,
    this.textColor = Colors.black,
    this.textFieldColor = Colors.white,
    this.prefixIcon,
    this.onChange,
    this.validateField,
    this.isPassword = false, // New parameter for password functionality
  }) : super(key: key);

  final String? label;
  final IconData? prefixIcon;
  final Color? textColor, textFieldColor;
  final Function(String)? onChange;
  String? Function(String?)? validateField;
  final bool isPassword; // Indicates whether it's a password field

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool passwordVisible = false; // Local state for password visibility

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: widget.isPassword ? !passwordVisible : false,
      validator: widget.validateField,
      onChanged: widget.onChange,
      keyboardType: TextInputType.text,
      style: TextStyle(color: widget.textColor),
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30),
        filled: true,
        hintText: widget.label,
        fillColor: widget.textFieldColor,
        prefixIcon: Icon(
          widget.prefixIcon,
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                    passwordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    passwordVisible = !passwordVisible;
                  });
                },
              )
            : null, // Only show suffixIcon for password fields
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
