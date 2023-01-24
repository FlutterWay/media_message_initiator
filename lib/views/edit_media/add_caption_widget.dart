import 'package:flutter/material.dart';
import 'package:flutter_emoji_gif_picker/flutter_emoji_gif_picker.dart';
import 'package:get/get.dart';
import '/controller/camera_page_controller.dart';

class AddCaptionTextField extends StatelessWidget {
  final void Function(String)? onChanged;
  const AddCaptionTextField({
    super.key,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    var config = Get.find<CameraPageController>().config;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: config.textfieldBackgroundColor),
        child: EmojiGifTextField(
          onChanged: onChanged,
          decoration: InputDecoration(
              suffixIcon: EmojiGifPickerIcon(
                  id: "1",
                  controller: Get.find<CameraPageController>().caption,
                  fromStack: true,
                  viewEmoji: true,
                  viewGif: false,
                  icon: Icon(
                    Icons.emoji_emotions,
                    color: config.textfieldIconColor,
                  )),
              prefixIcon: IconButton(
                onPressed: () =>
                    Get.find<CameraPageController>().backToCamera(context),
                icon: Icon(
                  Icons.add_photo_alternate,
                  color: config.textfieldIconColor,
                ),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
              hintText: config.addCaption,
              hintStyle: config.textfieldHintStyle),
          style: config.textfieldTextStyle,
          id: '1',
        ),
      ),
    );
  }
}
