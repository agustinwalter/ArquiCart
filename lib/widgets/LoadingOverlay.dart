import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool show, isDone;
  const LoadingOverlay(this.show, this.isDone);

  @override
  Widget build(BuildContext context) {
    if (show) {
      return Material(
        color: Colors.white.withOpacity(.8),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isDone)
                Icon(
                  Icons.done,
                  size: 60,
                  color: Colors.green,
                )
              else
                CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Text(
                  isDone
                      ? '¡Listo! Los datos del edificio se han enviado a revisión, pronto estarán publicados.'
                      : 'Los datos se están publicando, no cierres esta pantalla hasta que finalice el proceso.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ),
              if (isDone)
                RaisedButton(
                  onPressed: () => Navigator.pop(context),
                  color: Color(0xFF3c8bdc),
                  textColor: Colors.white,
                  child: Text('IR AL INICIO'),
                )
              else
                SizedBox.shrink(),
            ],
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }
}
