import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/controller/camera_page_controller.dart';
import '/views/thumbnail_widget.dart';

class ViewThumbnails extends StatelessWidget {
  final double height, width;
  const ViewThumbnails({super.key, required this.height, required this.width});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.transparent,
      child: GetBuilder<CameraPageController>(builder: (controller) {
        return ListView(
          scrollDirection: Axis.horizontal,
          children: [
            for (var file in controller.allMedia)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: GestureDetector(
                  onTap: () {
                    if (file.isSelected) {
                      file.unselect();
                    } else {
                      file.select();
                      if (controller.selectedMedia.length == 1) {
                        controller.goToEditMediaPage(context);
                      }
                    }
                  },
                  onLongPress: () {
                    if (file.isSelected) {
                      file.unselect();
                    } else {
                      file.select();
                    }
                  },
                  child: ThumbnailWidget(
                    media: file,
                    isCameraPage: true,
                    height: height,
                    isSelected: controller.isSelectedMedia(file),
                  ),
                ),
              )
          ],
        );
      }),
    );
  }
}
