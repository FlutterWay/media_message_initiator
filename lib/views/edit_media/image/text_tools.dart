import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/camera_page_controller.dart';
import '../../../models/editor.dart';

class TextTools extends StatefulWidget {
  final Editor editor;
  final Function() onFinished;
  const TextTools({
    super.key,
    required this.editor,
    required this.onFinished,
  });

  @override
  State<TextTools> createState() => _TextToolsState();
}

class _TextToolsState extends State<TextTools> {
  late double colorValue;

  var controller = Get.find<CameraPageController>();
  final List<Color> hueColors = const [
    Color.fromRGBO(0, 0, 0, 1),
    Color.fromRGBO(158, 158, 158, 1),
    Color.fromRGBO(255, 255, 255, 1),
    Color.fromRGBO(255, 82, 82, 1),
    Color.fromRGBO(244, 67, 54, 1),
    Color.fromRGBO(255, 152, 0, 1),
    Color.fromRGBO(255, 235, 59, 1),
    Color.fromRGBO(105, 240, 174, 1),
    Color.fromRGBO(76, 175, 80, 1),
    Color.fromRGBO(3, 169, 244, 1),
    Color.fromRGBO(33, 150, 243, 1),
    Color.fromRGBO(156, 39, 176, 1),
    Color.fromRGBO(103, 58, 183, 1),
    Color.fromRGBO(224, 64, 251, 1),
    Color.fromRGBO(233, 30, 99, 1)
  ];

  @override
  void initState() {
    colorValue =
        hueColors.indexOf(widget.editor.color) / (hueColors.length - 1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: TextButton(
                  onPressed: () {
                    widget.onFinished();
                  },
                  child: Container(
                    width: 60,
                    height: 30,
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 1, color: controller.config.textColor),
                        borderRadius: BorderRadius.circular(20)),
                    alignment: Alignment.center,
                    child: Text(
                      controller.config.finish,
                      style: TextStyle(color: controller.config.textColor),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              if (widget.editor.controller.canUndo)
                TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.only(top: 10),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      widget.editor.undo();
                    },
                    child: Icon(
                      Icons.undo,
                      color: controller.config.iconColor,
                    )),
              Column(
                children: [
                  MaterialButton(
                    onPressed: () {},
                    color: widget.editor.color,
                    padding: const EdgeInsets.all(8),
                    shape: const CircleBorder(),
                    child: Text(
                      "Y",
                      style: TextStyle(
                          fontSize: 24,
                          color: controller.config.textColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(),
                  SizedBox(
                    width: 20,
                    height: 200,
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: SliderPicker(
                        min: 0.0,
                        max: 1.0,
                        value: colorValue,
                        onChanged: (value) {
                          setState(() {
                            colorValue = value;
                            widget.editor.changeColor(
                                hueColors[(colorValue * 14).round()]);
                          });
                        },
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: hueColors),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Consumer<ScreenHeight>(builder: (context, keyboard, child) {
            return Padding(
              padding: EdgeInsets.only(bottom: keyboard.keyboardHeight + 20),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Slider(
                  value: widget.editor.fontSize,
                  onChanged: (value) => setState(() {
                    widget.editor.changeFontsize(value);
                  }),
                  min: 36,
                  max: 80,
                ),
              ),
            );
          })
        ],
      ),
    );
  }
}
