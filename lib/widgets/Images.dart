import 'package:arquicart/screens/ImageView.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class Images extends StatelessWidget {
  final double height;
  final List images;
  final bool fromNetwork;
  final FunctionCallback onRemoveImage;
  const Images({
    @required this.height,
    @required this.images,
    this.fromNetwork: true,
    this.onRemoveImage,
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
          int width;
          if (!fromNetwork) {
            Asset img = images[index];
            width = (img.originalWidth / img.originalHeight * (height - 48))
                .round();
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                elevation: 3,
                child: fromNetwork
                    ? GestureDetector(
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/img/loading.gif',
                          image: images[index],
                          height: height - 24,
                          fit: BoxFit.contain,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageView(images, index),
                            ),
                          );
                        },
                      )
                    : AssetThumb(
                        asset: images[index],
                        height: (height - 48).round(),
                        width: width,
                      ),
              ),
              if (!fromNetwork)
                GestureDetector(
                  onTap: () => onRemoveImage(index),
                  child: Icon(Icons.close),
                )
              else
                SizedBox.shrink()
            ],
          );
        },
      ),
    );
  }
}

typedef FunctionCallback = void Function(int index);
