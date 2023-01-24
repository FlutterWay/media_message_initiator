import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/controller/camera_page_controller.dart';
import '/views/thumbnail_widget.dart';
import '../../models/editable_media.dart';

class ViewThumbnails extends StatelessWidget {
  final double height, width;
  final EditableMedia selectedMedia;
  final void Function(EditableMedia media) onPressed;
  const ViewThumbnails(
      {super.key,
      required this.height,
      required this.width,
      required this.onPressed,
      required this.selectedMedia});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.transparent,
      child: GetBuilder<CameraPageController>(builder: (controller) {
        return Container(
          alignment: Alignment.center,
          child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: [
              for (var media in controller.selectedMedia)
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    onPressed(media);
                  },
                  child: ThumbnailWidget(
                    isCameraPage: false,
                    media: media,
                    isSelected: media == selectedMedia,
                    height: height,
                  ),
                )
            ],
          ),
        );
      }),
    );
  }
}
