import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String helperText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final int maxLines;
  final FocusNode focusNode;
  final void Function() onEditingComplete;
  final double paddingBottom;
  final bool autofocus, requiredField;

  const CustomTextField({
    this.label,
    this.helperText,
    this.controller,
    this.onEditingComplete,
    this.focusNode,
    this.keyboardType: TextInputType.text,
    this.textInputAction: TextInputAction.next,
    this.maxLines: 1,
    this.paddingBottom: 12,
    this.autofocus: false,
    this.requiredField: false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: paddingBottom),
      child: TextFormField(
        autofocus: autofocus,
        controller: controller,
        focusNode: focusNode,
        textCapitalization: TextCapitalization.sentences,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        minLines: 1,
        maxLines: maxLines,
        onEditingComplete: onEditingComplete,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          isDense: true,
          labelText: label,
          helperText: helperText,
        ),
        validator: (value) {
          if (value.isEmpty && requiredField) {
            return 'Completa este campo';
          }
          return null;
        },
      ),
    );
  }
}
