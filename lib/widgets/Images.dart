import 'package:flutter/material.dart';

class Images extends StatelessWidget {
  final double height;
  final List images;
  final bool fromNetwork;

  const Images({
    @required this.height,
    @required this.images,
    this.fromNetwork: true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: ListView.builder(
        padding: EdgeInsets.all(8),
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3,
            child: fromNetwork
                ? Image.network(
                    images[index],
                    fit: BoxFit.contain,
                  )
                : Image.file(
                    images[index],
                    fit: BoxFit.contain,
                  ),
          );
        },
      ),
    );
  }
}
