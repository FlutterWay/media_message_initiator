import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '/controller/camera_page_controller.dart';

// ignore: must_be_immutable
class CameraView extends StatefulWidget {
  final CameraPageController controller;

  const CameraView({super.key, required this.controller});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  int pointers = 0;

  double? getAspectRatio() {
    try {
      return widget.controller.cameraController!.value.aspectRatio;
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
                  aspectRatio:
                      widget.controller.cameraController!.value.aspectRatio,
                  child: camera(),
                )
              : const SizedBox(),
        ));
  }

  double? width, area, mini;
  bool scaling = false;
  Widget camera() {
    scaling = true;
    print(widget.controller.currentScale);
    if (width == null) {
      width = MediaQuery.of(context).size.width * 0.85;
      mini = width! * 0.3;
    }
    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onScaleStart: (scaleUpdateDetails) {
          setState(
            () {
              scaling = true;
            },
          );
        },
        onScaleUpdate: (scaleUpdateDetails) {
          print("update");
          widget.controller
              .scaleUpdate(scale: scaleUpdateDetails.scale, pointers: pointers)
              .then((value) => setState((() {})));
        },
        onScaleEnd: ((details) => setState(() {
              widget.controller.scaleEnd();
              scaling = false;
            })),
        child: CameraPreview(
          widget.controller.cameraController!,
          child: Stack(
            children: [
              if (scaling)
                Center(
                  child: Container(
                    width: width,
                    decoration: BoxDecoration(
                      border: Border.all(width: 3, color: Colors.grey),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              if (scaling)
                Center(
                  child: Container(
                    width: mini,
                    decoration: BoxDecoration(
                      border: Border.all(width: 3, color: Colors.grey),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.controller.currentScale.toStringAsFixed(1),
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              if (scaling)
                Center(
                  child: Container(
                    width: mini! +
                        ((width! - mini!) *
                            (widget.controller.currentScale - 1) *
                            0.1),
                    decoration: BoxDecoration(
                      border: Border.all(width: 3, color: Colors.blue[700]!),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  double getArea(double radius) {
    return radius * radius * 3;
  }
}
