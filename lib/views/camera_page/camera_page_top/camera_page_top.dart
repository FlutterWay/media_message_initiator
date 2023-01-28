import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '/controller/camera_page_controller.dart';
import '/views/camera_page/camera_page_top/flash_icon.dart';

class CameraPageTop extends StatefulWidget {
  const CameraPageTop({super.key});

  @override
  State<CameraPageTop> createState() => _CameraPageTopState();
}

class _CameraPageTopState extends State<CameraPageTop> {
  Duration? videoDuration;
  var controller = Get.find<CameraPageController>();
  Timer? _timer;
  CameraLensDirection? direction;
  _CameraPageTopState() {
    direction = controller.cameraLensDirectio;
    controller.addListener(() {
      if (direction != controller.cameraLensDirectio) {
        if (mounted) {
          setState(() {
            direction = controller.cameraLensDirectio;
          });
        }
      }
      if (controller.isRecording && _timer == null) {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          int duration = videoDuration != null ? videoDuration!.inSeconds : 0;
          videoDuration = Duration(seconds: duration + 1);
          if (mounted) {
            setState(() {});
          }
        });
      } else {
        if (_timer != null) {
          videoDuration = null;
          _timer!.cancel();
          _timer = null;
          if (mounted) {
            setState(() {});
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: videoDuration != null ? viewCounter() : viewMenu(),
    );
  }

  Widget viewMenu() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
            controller.onWillPop();
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          },
          icon: Icon(Icons.close, color: controller.config.iconColor),
        ),
        if (controller.cameraLensDirectio == CameraLensDirection.back)
          FlashIcon(),
      ],
    );
  }

  Widget viewCounter() {
    final minutes = videoDuration!.inMinutes;
    final seconds = videoDuration!.inSeconds % 60;
    return Row(
      children: [
        const Spacer(),
        Container(
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.circle,
                  color: Colors.red,
                ),
                Text('$minutes:${checkSeconds(seconds)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ],
            )),
        const Spacer(),
      ],
    );
  }

  String checkSeconds(int second) {
    if (second < 10) {
      return "0$second";
    } else {
      return second.toString();
    }
  }
}
