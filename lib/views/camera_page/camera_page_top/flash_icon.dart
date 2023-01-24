import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/controller/camera_page_controller.dart';

class FlashIcon extends StatelessWidget {
  final List<IconData> iconDatas = [
    Icons.flash_off,
    Icons.flash_on,
    Icons.flash_auto,
  ];
  late final PageController controller;
  final cameraController = Get.find<CameraPageController>();

  FlashIcon({super.key}) {
    controller = PageController(
        initialPage:
            iconDatas.indexOf(getFlashIcon(cameraController.flashType)));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: PageView(
        controller: controller,
        scrollDirection: Axis.vertical,
        children: [
          for (int i = 0; i < iconDatas.length; i++)
            IconButton(
                onPressed: () {
                  if (i == iconDatas.length - 1) {
                    controller.animateToPage(0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn);
                    cameraController.changeFlashType(FlashType.off);
                  } else {
                    controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn);
                    cameraController.changeFlashType(
                        i == 0 ? FlashType.on : FlashType.auto);
                  }
                },
                icon: Icon(
                  iconDatas[i],
                  size: 25,
                  color: cameraController.config.iconColor,
                ))
        ],
      ),
    );
  }

  IconData getFlashIcon(FlashType type) {
    switch (type) {
      case FlashType.on:
        return Icons.flash_on;
      case FlashType.off:
        return Icons.flash_off;
      case FlashType.auto:
        return Icons.flash_auto;
    }
  }
}

enum FlashType { on, off, auto }
