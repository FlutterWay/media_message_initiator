import 'package:flutter/material.dart';
import 'package:gallery_picker/gallery_picker.dart';
import 'package:get/get.dart';
import '../controller/camera_page_controller.dart';
import '../models/editable_media.dart';

class ThumbnailWidget extends StatelessWidget {
  final bool isSelected;
  final bool isCameraPage;
  final EditableMedia media;
  final double height;
  const ThumbnailWidget(
      {super.key,
      required this.media,
      required this.isCameraPage,
      this.isSelected = false,
      this.height = 60});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: height,
      height: height,
      decoration: isSelected && !isCameraPage
          ? BoxDecoration(
              border: Border.all(
                  width: 2,
                  color: Get.find<CameraPageController>()
                      .config
                      .selectedThumbnailBorder))
          : null,
      child: Stack(children: [
        SizedBox(
            width: height,
            height: height,
            child: ThumbnailMedia(media: media.mediaFile)),
        if (isSelected && isCameraPage)
          Container(
            width: height,
            height: height,
            color: Colors.black.withOpacity(0.2),
            child: const Center(
              child: Icon(Icons.check, color: Colors.white, size: 30),
            ),
          ),
      ]),
    );
  }
}
