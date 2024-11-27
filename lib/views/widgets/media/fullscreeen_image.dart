import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:stitches_africa/constants/utilities.dart';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  final ImageProvider? imageProvider;

  const FullScreenImage(
      {super.key, required this.imageUrl, this.imageProvider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Hero(
            tag: imageUrl,
            child: PhotoView(
              loadingBuilder: (context, event) => const Center(
                child:
                    CircularProgressIndicator(color: Utilities.backgroundColor),
              ),
              imageProvider: imageProvider ?? NetworkImage(imageUrl),
            ),
          ),
        ),
      ),
    );
  }
}

class FullScreenFileImage extends StatelessWidget {
  final File filePath;
  const FullScreenFileImage({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Hero(
            tag: filePath,
            child: PhotoView(
              loadingBuilder: (context, event) => const Center(
                child:
                    CircularProgressIndicator(color: Utilities.backgroundColor),
              ),
              imageProvider: FileImage(filePath),
            ),
          ),
        ),
      ),
    );
  }
}
