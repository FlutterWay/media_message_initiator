library media_message_initiator;

export 'models/shared_person.dart';
export 'models/editable_media.dart';
export 'models/mode.dart';
export 'models/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji_gif_picker/flutter_emoji_gif_picker.dart'
    as emoji;
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'controller/camera_page_controller.dart';
import 'controller/editor_updater.dart';
import 'models/config.dart';
import 'models/media_msg.dart';
import 'models/mode.dart';
import 'models/shared_person.dart';
import 'views/camera_page/camera_page.dart';

class MediaMessageInitiator {
  static Future<MediaMessage?> generate(
      {required List<Person> people,
      required BuildContext context,
      Config? config}) async {
    config ??= Config();
    MediaMessage? msg;
    Get.put(EditorUpdater());
    var controller = Get.put(CameraPageController(
        onFinished: ((media, message) {
          msg = MediaMessage(text: message, media: media);
        }),
        config: config));
    controller.setSharedPeopleList = people;
    controller.getAvaliableCameras();
    var colors = config.emojiPickerConfig.mode == Mode.dark
        ? emoji.MenuColors.dark()
        : emoji.MenuColors.light();
    colors.backgroundColor =
        config.emojiPickerConfig.backgroundColor ?? colors.backgroundColor;
    colors.searchBarBackgroundColor =
        config.emojiPickerConfig.searchBarBackgroundColor ??
            colors.searchBarBackgroundColor;
    colors.searchBarBorderColor =
        config.emojiPickerConfig.searchBarBorderColor ??
            colors.searchBarBorderColor;
    colors.searchBarEnabledColor =
        config.emojiPickerConfig.searchBarEnabledColor ??
            colors.searchBarEnabledColor;
    colors.searchBarFocusedColor =
        config.emojiPickerConfig.searchBarFocusedColor ??
            colors.searchBarFocusedColor;
    colors.buttonColor =
        config.emojiPickerConfig.buttonColor ?? colors.buttonColor;
    colors.menuSelectedIconColor =
        config.emojiPickerConfig.menuSelectedIconColor ??
            colors.menuSelectedIconColor;
    var textStyles = config.emojiPickerConfig.mode == Mode.dark
        ? emoji.MenuStyles.dark()
        : emoji.MenuStyles.light();
    textStyles.menuSelectedTextStyle =
        config.emojiPickerConfig.menuSelectedTextStyle ??
            textStyles.menuSelectedTextStyle;
    textStyles.menuUnSelectedTextStyle =
        config.emojiPickerConfig.menuUnSelectedTextStyle ??
            textStyles.menuUnSelectedTextStyle;
    textStyles.searchBarHintStyle =
        config.emojiPickerConfig.searchBarHintStyle ??
            textStyles.searchBarHintStyle;
    textStyles.searchBarTextStyle =
        config.emojiPickerConfig.searchBarTextStyle ??
            textStyles.searchBarTextStyle;
    emoji.EmojiGifPickerPanel.setup(
      mode: config.emojiPickerConfig.mode == Mode.light
          ? emoji.Mode.light
          : emoji.Mode.dark,
      colors: colors,
      styles: textStyles,
      texts: emoji.MenuTexts(
        searchEmojiHintText: config.emojiPickerConfig.searchText,
        noRecents: config.emojiPickerConfig.noRecents,
      ),
    );
    await Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft, child: const CameraPage()));
    return msg;
  }
}
