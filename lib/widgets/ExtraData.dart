import 'package:flutter/material.dart';

class ExtraData extends StatelessWidget {
  final String left, right;
  final Function onTap;
  const ExtraData({this.left, this.right, this.onTap});

  @override
  Widget build(BuildContext context) {
      return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 16),
                children: <TextSpan>[
                  TextSpan(
                    text: '$left: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: right),
                ],
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Icon(Icons.close),
        )
      ],
    );
  
  }
}