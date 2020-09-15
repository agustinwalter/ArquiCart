import 'package:flutter/material.dart';
import 'CustomTextField.dart';

class ExtraDataDialog extends StatelessWidget {
  final TextEditingController keyCtrl;
  final TextEditingController valueCtrl;
  final FocusNode valueFocus;
  final Function onDataAdded;

  const ExtraDataDialog({this.keyCtrl, this.valueCtrl, this.valueFocus, this.onDataAdded});
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Agrega un nuevo dato"),
      content: ListView(
        shrinkWrap: true,
        children: [
          CustomTextField(
            label: 'Nombre del dato',
            controller: keyCtrl,
            helperText: 'Ej.: "Año de innauguración"',
            autofocus: true,
            onEditingComplete: () => valueFocus.requestFocus(),
          ),
          CustomTextField(
            label: 'Valor',
            controller: valueCtrl,
            focusNode: valueFocus,
            textInputAction: TextInputAction.done,
            helperText: 'Ej: "2008"',
          ),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      actions: <Widget>[
        FlatButton(
          child: Text('CANCELAR'),
          textColor: Colors.grey,
          onPressed: () => Navigator.of(context).pop(),
        ),
        FlatButton(
          child: Text('AGREGAR'),
          onPressed: () {
            if (keyCtrl.text.length > 0 && valueCtrl.text.length > 0) {
              onDataAdded();
            }
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
