import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTap;
  final String? Function(String?)? validator;
  final String? labelText;

  const CustomDatePicker({
    super.key,
    required this.selectedDate,
    required this.onTap,
    this.validator,
    this.labelText = ""
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText!,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 10),
        FormField<String>(
          validator: validator,
          builder: (FormFieldState<String> state) {
            return Column(
              children: <Widget>[
                 SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      backgroundColor: Theme.of(context).canvasColor, // Color uniforme con los TextFormField
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.black), // Borde negro
                      ),
                    ),
                    onPressed: onTap,
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(selectedDate),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      state.errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}