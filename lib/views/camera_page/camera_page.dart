import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gallery_picker/gallery_picker.dart';
import 'package:get/get.dart';
import '/views/camera_page/camera_page_bottom/camera_page_bottom.dart';
import '/views/camera_page/camera_page_top/camera_page_top.dart';
import '/views/edit_media/edit_media_page.dart';
import '../../controller/camera_page_controller.dart';
import '../../models/editable_media.dart';
import 'camera_view.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  var controller = Get.find<CameraPageController>();
  List<MediaFile> selectedMedia = [];
  GalleryMedia? gallery;
  Future<void>? initalizing;
  @override
  void initState() {
    initalizing = !controller.isCameraInitialized
        ? controller.initialize().then((value) {
            if (mounted) {
              setState(() {});
            }
          })
        : null;
    super.initState();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CameraPageController>(builder: (controller) {
      return PickerScaffold(
        backgroundColor: controller.config.backgroundColor,
        initSelectedMedia:
            controller.selectedMedia.map((e) => e.mediaFile).toList(),
        extraRecentMedia:
            controller.cameraMedia.map((e) => e.mediaFile).toList(),
        onSelect: ((selectedMedia) {}),
        config: controller.galleryPickerConfig,
        multipleMediaBuilder: (media, context) {
          controller.updateSelectedMedia(media);
          return const EditMediaPage();
        },
        body: Stack(
          children: [
            if (controller.isCameraInitialized)
              CameraView(controller: controller),
            const CameraPageTop(),
            SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: CameraPageBottom(
                  controller: controller,
                ),
              ),
          ],
        ),
      );
    });
  }
}
