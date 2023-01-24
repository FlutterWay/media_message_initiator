import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/camera_page_controller.dart';

class BottomIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Function() onPressed;
  const BottomIcon(
      {super.key,
      required this.icon,
      required this.onPressed,
      required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Get.find<CameraPageController>()
              .config
              .backgroundColor
              .withOpacity(0.5),
          shape: BoxShape.circle),
      child: TextButton(
        onPressed: onPressed,
        child: Icon(
          icon,
          size: size,
          color: Get.find<CameraPageController>().config.iconColor,
        ),
      ),
    );
  }
}
