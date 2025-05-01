import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final Color? focusLabelColor;
  final String? Function(String?)? validator;

  const CustomTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.isPassword,
    this.focusLabelColor = Colors.black,
    this.validator
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Asegura que la validación se vea debajo del campo
      children: [
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          cursorColor: Colors.black,

          //selectionHandleColor: Colors.black,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            floatingLabelStyle: TextStyle(color: focusLabelColor),
          ),
          validator: validator ?? (value) {
            if (value == null || value.isEmpty) {
              return 'El campo no puede estar vacío';
            }
            return null;
          },
        ),
      ],
    );

  }
}
