import 'package:flutter/material.dart';
import 'package:flutter_emoji_gif_picker/flutter_emoji_gif_picker.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:get/get.dart';
import '/views/edit_media/image/view_image.dart';
import '/views/edit_media/shared_people.dart';
import '/views/edit_media/video/view_video.dart';
import '../../controller/camera_page_controller.dart';
import '../../models/editable_media.dart';
import 'add_caption_widget.dart';
import 'view_thumbnails.dart';

class EditMediaPage extends StatefulWidget {
  const EditMediaPage({
    super.key,
  });
  @override
  State<EditMediaPage> createState() => _EditMediaPageState();
}

class _EditMediaPageState extends State<EditMediaPage> {
  bool videoEnded = false;
  bool isVideoPlaying = false;
  bool playButtonVisiblity = true;
  String messageText = "";
  var controller = Get.find<CameraPageController>();
  late EditableMedia selectedMedia;

  @override
  void initState() {
    selectedMedia = controller.selectedMedia.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardSizeProvider(
      child: Stack(
        children: [
          WillPopScope(
            onWillPop: (() async {
              return EmojiGifPickerPanel.onWillPop();
            }),
            child: Scaffold(
                backgroundColor: controller.config.backgroundColor,
                resizeToAvoidBottomInset: false,
                body: GetBuilder<CameraPageController>(builder: (controller) {
                  return GestureDetector(
                    onTap: () {
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (currentFocus.hasFocus &&
                          (selectedMedia.mediaFile.isVideo ||
                              (selectedMedia.editor != null &&
                                  !selectedMedia.editor!.isDrawMode))) {
                        print("UNFOCUSSSSSSSSSSSS");
                        currentFocus.unfocus();
                        if (selectedMedia.mediaFile.isImage) {
                          selectedMedia.editor!.close();
                          if (mounted) {
                            setState(() {});
                          }
                        }
                      }
                    },
                    child: Stack(
                      fit: StackFit.passthrough,
                      children: [
                        if (selectedMedia.mediaFile.isVideo)
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: ViewVideo(
                              media: selectedMedia,
                              unSelect: ((media) {
                                if (controller.selectedMedia.isNotEmpty) {
                                  setState(() {
                                    selectedMedia =
                                        controller.selectedMedia.last;
                                  });
                                } else {
                                  controller.backToCamera(context);
                                }
                              }),
                            ),
                          )
                        else
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: selectedMedia.editor != null
                                ? ViewImage(
                                    media: selectedMedia,
                                    updateEditingStatus: () =>
                                        setState((() {})),
                                    unSelect: ((media) {
                                      if (controller.selectedMedia.isNotEmpty) {
                                        setState(() {
                                          selectedMedia =
                                              controller.selectedMedia.last;
                                        });
                                      } else {
                                        controller.backToCamera(context);
                                      }
                                    }),
                                  )
                                : null,
                          ),
                        if (selectedMedia.mediaFile.isVideo ||
                            (selectedMedia.editor != null &&
                                !selectedMedia.editor!.isEditting))
                          Consumer<ScreenHeight>(
                              builder: (context, keyboard, child) {
                            return EmojiGifPickerBuilder(
                                id: "1",
                                builder: (isOpened) {
                                  return Positioned(
                                    bottom: keyboard.keyboardHeight +
                                        (isOpened && keyboard.isOpen
                                            ? 150
                                            : isOpened && !keyboard.isOpen
                                                ? EmojiGifPickerPanel
                                                    .sizes.height
                                                : 0),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10.0),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Column(children: [
                                          if (controller.selectedMedia.length >
                                              1)
                                            ViewThumbnails(
                                              selectedMedia: selectedMedia,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              onPressed: (file) async {
                                                selectedMedia = file;
                                                setState(() {});
                                              },
                                              height: 40,
                                            ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          AddCaptionTextField(
                                            onChanged: (text) {
                                              messageText = text;
                                            },
                                          ),
                                          Row(
                                            children: [
                                              const Expanded(
                                                child: SharedPeopleWidget(
                                                  fontSize: 16,
                                                ),
                                              ),
                                              MaterialButton(
                                                onPressed: () {
                                                  controller.generateMessage(
                                                      messageText);
                                                },
                                                color: controller.config
                                                    .floatingActionButtonColor,
                                                padding:
                                                    const EdgeInsets.all(16),
                                                shape: const CircleBorder(),
                                                child: const Icon(
                                                  Icons.send,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              )
                                            ],
                                          )
                                        ]),
                                      ),
                                    ),
                                  );
                                });
                          }),
                      ],
                    ),
                  );
                })),
          ),
          const EmojiGifMenuStack()
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
