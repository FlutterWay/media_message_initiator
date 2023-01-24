import 'package:flutter/material.dart';
import 'mode.dart';

class EmojiPickerConfig {
  final Color? backgroundColor,
      searchBarBackgroundColor,
      searchBarBorderColor,
      searchBarEnabledColor,
      searchBarFocusedColor,
      buttonColor,
      menuSelectedIconColor;
  final TextStyle? menuSelectedTextStyle,
      menuUnSelectedTextStyle,
      searchBarTextStyle,
      searchBarHintStyle;
  final String searchText;
  final Widget? noRecents;
  final Mode mode;

  const EmojiPickerConfig(
      {this.backgroundColor,
      this.searchBarBackgroundColor,
      this.searchBarBorderColor,
      this.searchBarEnabledColor,
      this.searchBarFocusedColor,
      this.buttonColor,
      this.menuSelectedIconColor,
      this.menuSelectedTextStyle,
      this.menuUnSelectedTextStyle,
      this.searchBarHintStyle,
      this.searchBarTextStyle,
      this.searchText = "Search Emoji",
      this.mode = Mode.light,
      this.noRecents});
}
