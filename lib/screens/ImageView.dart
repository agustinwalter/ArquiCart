import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageView extends StatefulWidget {
  final List<dynamic> images;
  final int initialPage;
  ImageView(this.images, this.initialPage);
  @override
  _ImageViewState createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  PageController pageController;

  @override
  void initState() {
    pageController = PageController();
    Future.delayed(Duration.zero, () => pageController.jumpToPage(widget.initialPage));
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PhotoViewGallery.builder(
        itemCount: widget.images.length,
        pageController: pageController,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: CachedNetworkImageProvider(widget.images[index]),
          );
        },
      ),
    );
  }
}
