import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:get/get.dart';
import '../../../controller/editor_updater.dart';
import '../../../models/editable_media.dart';
import 'painting_tools.dart';
import 'text_tools.dart';
import '../../../controller/camera_page_controller.dart';
import '../../../models/editor.dart';

class ViewImage extends StatefulWidget {
  final EditableMedia media;
  final Function(EditableMedia media) unSelect;
  final Function() updateEditingStatus;
  const ViewImage(
      {super.key,
      required this.media,
      required this.unSelect,
      required this.updateEditingStatus});

  @override
  State<ViewImage> createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  final controller = Get.find<CameraPageController>();
  late EditableMedia media;
  @override
  void initState() {
    media = widget.media;
    Get.find<EditorUpdater>().addListener(() {
      if (widget.media.mediaFile.id ==
          Get.find<EditorUpdater>().updatedEditor) {
        if (mounted) {
          setState(() {});
        }
      }
    });
    listenFocusNode();
    super.initState();
  }

  void listenFocusNode() {
    media.editor!.textFocusNode.addListener(() {
      if (media.editor!.textFocusNode.hasFocus) {
        print("hasfocus");
        widget.updateEditingStatus();
        swapTextMode();
      } else {
        print("hasfocus2");
        media.editor!.close();
        if (mounted) {
          setState(() {});
          widget.updateEditingStatus();
        }
      }
    });
  }

  bool isKeyboardOpened = false;
  Widget? secondChild;
  CrossFadeState crossFadeState = CrossFadeState.showFirst;
  bool changingMediaProcess = false;
  @override
  Widget build(BuildContext context) {
    if (media != widget.media) {
      listenFocusNode();
      media = widget.media;
    }
    return WillPopScope(
      onWillPop: () async {
        if (widget.media.editor!.isEditting) {
          widget.media.editor!.close();
          widget.updateEditingStatus();
          crossFadeState = CrossFadeState.showFirst;
          setState(() {});
          return false;
        } else {
          if (controller.selectedMedia.length == 1) {
            widget.media.unselect();
          }
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: controller.config.backgroundColor,
        resizeToAvoidBottomInset: false,
        body: Consumer<ScreenHeight>(builder: (context, keyboard, child) {
          checkKeyboard(keyboard);
          return Stack(
            children: [
              if (widget.media.editor!.aspectRatio != null)
                Positioned.fill(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: widget.media.editor!.aspectRatio!,
                      child: FlutterPainter(
                        controller: widget.media.editor!.controller,
                      ),
                    ),
                  ),
                ),
              AnimatedCrossFade(
                  firstChild: standartTopMenu(),
                  secondChild: secondChild ?? const SizedBox(),
                  crossFadeState: crossFadeState,
                  duration: const Duration(milliseconds: 500))
            ],
          );
        }),
      ),
    );
  }

  Widget standartTopMenu() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 10,
            child: IconButton(
                onPressed: () async {
                  controller.backToCamera(context);
                  if (controller.selectedMedia.length == 1) {
                    widget.media.unselect();
                  }
                },
                icon: Icon(
                  Icons.close,
                  color: controller.config.iconColor,
                )),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (controller.selectedMedia.length > 1)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: controller.config.iconColor,
                    ),
                    onPressed: () async {
                      widget.media.unselect();
                      widget.unSelect(widget.media);
                    },
                  ),
                if (widget.media.editor!.canUndo)
                  IconButton(
                    icon: Icon(
                      Icons.undo_outlined,
                      color: controller.config.iconColor,
                    ),
                    onPressed: () {
                      if (mounted) {
                        setState(() {
                          widget.media.editor!.undo();
                        });
                      }
                    },
                  ),
                IconButton(
                  icon: Icon(
                    Icons.crop,
                    color: controller.config.iconColor,
                  ),
                  onPressed: cropImg,
                ),
                IconButton(
                  icon: Text(
                    "Y",
                    style: TextStyle(
                        fontSize: 24,
                        color: controller.config.iconColor,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    swapTextMode();
                    widget.updateEditingStatus();
                    Future.delayed(const Duration(milliseconds: 500))
                        .then((value) => widget.media.editor!.addText());
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    color: controller.config.iconColor,
                  ),
                  onPressed: () async {
                    widget.media.editor!.drawMode();
                    widget.updateEditingStatus();
                    secondChild = PaintingTools(
                        editor: widget.media.editor!,
                        onFinished: () {
                          if (mounted) {
                            setState(() {
                              widget.media.editor!.close();
                              crossFadeState = CrossFadeState.showFirst;
                            });
                          }
                          widget.updateEditingStatus();
                        });
                    if (mounted) {
                      setState(() {
                        crossFadeState = CrossFadeState.showSecond;
                      });
                    }
                  },
                ),
                const VerticalDivider()
              ],
            ),
          )
        ],
      ),
    );
  }

  void swapTextMode() {
    widget.media.editor!.textMode();
    secondChild = TextTools(
        editor: widget.media.editor!,
        onFinished: () {
          if (mounted) {
            setState(() {
              widget.media.editor!.close();
              crossFadeState = CrossFadeState.showFirst;
            });
          }
          widget.updateEditingStatus();
        });
    if (mounted) {
      setState(() {
        crossFadeState = CrossFadeState.showSecond;
      });
    }
  }

  void checkKeyboard(ScreenHeight keyboard) {
    if (isKeyboardOpened && !keyboard.isOpen) {
      widget.media.editor!.close();
      crossFadeState = CrossFadeState.showFirst;
    }
    isKeyboardOpened = keyboard.isOpen;
  }

  Future<void> cropImg() async {
    await controller.cropImage(context: context, media: widget.media);
    if (mounted) {
      setState(() {});
    }
  }
}
