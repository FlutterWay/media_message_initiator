import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '/controller/camera_page_controller.dart';

// ignore: must_be_immutable
class CameraView extends StatelessWidget {
  final CameraPageController controller;
  int pointers = 0;
  CameraView({super.key, required this.controller});
  double? getAspectRatio() {
    try {
      return controller.cameraController!.value.aspectRatio;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    double? aspectRatio = getAspectRatio();
    return SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Listener(
          onPointerDown: (_) => pointers++,
          onPointerUp: (_) => pointers--,
          child: aspectRatio != null
              ? AspectRatio(
                  aspectRatio: controller.cameraController!.value.aspectRatio,
                  child: camera(),
                )
              : const SizedBox(),
        ));
  }

  Widget camera() {
    return Stack(
      children: [
        Center(
          child: CameraPreview(
            controller.cameraController!,
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onScaleStart: (scaleUpdateDetails) => controller.resetScale(),
                onScaleUpdate: (scaleUpdateDetails) => controller.scaleUpdate(
                    scale: scaleUpdateDetails.scale, pointers: pointers),
                onTapDown: (TapDownDetails details) =>
                    controller.onViewFinderTap(details, constraints),
              );
            }),
          ),
        ),
      ],
    );
  }
}
