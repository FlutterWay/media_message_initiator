import 'package:flutter/material.dart';
import 'package:gallery_picker/gallery_picker.dart';
import 'package:get/get.dart';
import '/views/camera_page/camera_page_bottom/bottom_icon.dart';
import '/views/camera_page/view_thumbnails.dart';
import '../../../controller/camera_page_controller.dart';

class CameraPageBottom extends StatelessWidget {
  const CameraPageBottom({super.key, required this.controller});
  final CameraPageController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BottomSheetBuilder(builder: (status, context) {
          return Positioned(
            bottom: status.height > 150 ? status.height : 150,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 85,
              child: Stack(children: [
                Positioned(
                  bottom: 0,
                  child: ViewThumbnails(
                      height: MediaQuery.of(context).size.width / 5.7,
                      width: MediaQuery.of(context).size.width),
                ),
                controller.selectedMedia.isNotEmpty
                    ? Positioned(
                        top: 0,
                        right: 5,
                        child: MaterialButton(
                          padding: const EdgeInsets.all(12),
                          shape: const CircleBorder(),
                          color: controller.config.floatingActionButtonColor,
                          onPressed: () {
                            controller.goToEditMediaPage(context);
                          },
                          child: Stack(children: [
                            const Center(
                              child: Icon(Icons.check, color: Colors.white),
                            ),
                            Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, top: 10),
                                child: Text(
                                  controller.selectedMedia.length.toString(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                          ]),
                        ))
                    : const SizedBox(),
              ]),
            ),
          );
        }),
        Positioned(
          bottom: 80,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: GetBuilder<CameraPageController>(builder: (controller) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: controller.anyProcess ? 0 : 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: BottomIcon(
                        icon: Icons.image,
                        onPressed: () {
                          GalleryPicker.openSheet();
                        },
                        size: 20,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await controller.takePhoto(context);
                    },
                    onLongPressStart: (value) {
                      controller.startVideoRecording();
                    },
                    onLongPressEnd: (value) async {
                      await controller.stopVideoRecording(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(width: 2, color: Colors.white)),
                      width: controller.isRecording ? 75 : 60,
                      height: controller.isRecording ? 75 : 60,
                      child: Container(
                        decoration: BoxDecoration(
                          color: controller.anyProcess
                              ? Colors.red
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: controller.anyProcess ? 0 : 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: BottomIcon(
                        icon: Icons.cameraswitch,
                        onPressed: controller.changeCameraLensDirection,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
