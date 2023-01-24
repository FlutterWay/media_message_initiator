import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers.dart';
import 'package:video_editor/video_editor.dart';

import '../../../controller/camera_page_controller.dart';

class TrimViewer extends StatelessWidget {
  final double height;
  final VideoEditorController controller;
  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

  const TrimViewer({super.key, this.height = 60, required this.controller});

  @override
  Widget build(BuildContext context) {
    var textColor = Get.find<CameraPageController>().config.textColor;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([
            controller,
            controller.video,
          ]),
          builder: (_, __) {
            final duration = controller.videoDuration.inSeconds;
            final pos = controller.trimPosition * duration;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: height / 4),
              child: Row(children: [
                Text(formatter(Duration(seconds: pos.toInt())),
                    style: TextStyle(color: textColor)),
                const Expanded(child: SizedBox()),
                OpacityTransition(
                  visible: controller.isTrimming,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(formatter(controller.startTrim),
                        style: TextStyle(color: textColor)),
                    const SizedBox(width: 10),
                    Text(
                      formatter(controller.endTrim),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ]),
                ),
              ]),
            );
          },
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(vertical: height / 4),
          child: TrimSlider(
            controller: controller,
            height: height,
            horizontalMargin: height / 4,
            child: TrimTimeline(
              controller: controller,
              textStyle: TextStyle(color: textColor),
              padding: const EdgeInsets.only(top: 10),
            ),
          ),
        )
      ],
    );
  }
}
