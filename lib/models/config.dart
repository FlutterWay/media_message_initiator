import 'package:flutter/material.dart';
import 'emoji_picker_config.dart';
import 'gallery_picker_config.dart';
import 'mode.dart';
import 'trim_slider_style.dart';

class Config {
  final Color backgroundColor,
      iconColor,
      textColor,
      textfieldBackgroundColor,
      textfieldIconColor,
      floatingActionButtonColor,
      selectedThumbnailBorder;
  final TextStyle textfieldTextStyle, textfieldHintStyle;
  final String addCaption, finish, cancel;
  final GalleryPickerConfig galleryPickerConfig;
  final EmojiPickerConfig emojiPickerConfig;
  final TrimSliderStyle trimSliderStyle;
  final Mode mode;
  Config({
    this.mode = Mode.light,
    Color? backgroundColor,
    Color? iconColor,
    Color? textColor,
    this.textfieldBackgroundColor = const Color.fromARGB(255, 31, 44, 52),
    this.textfieldIconColor = const Color.fromARGB(255, 255, 255, 255),
    this.floatingActionButtonColor = const Color.fromARGB(255, 0, 168, 132),
    this.selectedThumbnailBorder = const Color.fromARGB(255, 0, 168, 132),
    this.textfieldTextStyle = const TextStyle(color: Colors.white),
    this.textfieldHintStyle = const TextStyle(color: Colors.white),
    this.addCaption = 'Add a caption...',
    this.finish = "Finish",
    this.cancel = "Cancel",
    GalleryPickerConfig? galleryPickerConfig,
    EmojiPickerConfig? emojiPickerConfig,
    TrimSliderStyle? trimSliderStyle,
  })  : backgroundColor = backgroundColor ??
            (mode == Mode.light ? Colors.white : Colors.black),
        galleryPickerConfig =
            galleryPickerConfig ?? GalleryPickerConfig(mode: mode),
        emojiPickerConfig = emojiPickerConfig ?? EmojiPickerConfig(mode: mode),
        trimSliderStyle = trimSliderStyle ?? TrimSliderStyle(mode: mode),
        iconColor =
            iconColor ?? (mode == Mode.light ? Colors.black : Colors.white),
        textColor=
            textColor ?? (mode == Mode.light ? Colors.black : Colors.white);
}
