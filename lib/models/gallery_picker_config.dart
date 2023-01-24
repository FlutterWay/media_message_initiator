import 'package:flutter/material.dart';
import 'mode.dart';

class GalleryPickerConfig {
  final Widget? selectIcon;
  final Color? backgroundColor,
      appbarColor,
      appbarIconColor,
      underlineColor,
      bottomSheetColor;
  final TextStyle? textStyle,
      appbarTextStyle,
      selectedMenuStyle,
      unselectedMenuStyle;
  final String recents,
      recent,
      gallery,
      lastMonth,
      lastWeek,
      tapPhotoSelect,
      selected;
  final List<String> months;
  final Mode mode;

  const GalleryPickerConfig(
      {this.backgroundColor,
      this.appbarColor,
      this.bottomSheetColor,
      this.appbarIconColor,
      this.underlineColor,
      this.selectedMenuStyle,
      this.unselectedMenuStyle,
      this.textStyle,
      this.appbarTextStyle,
      this.recents = "RECENTS",
      this.recent = "Recent",
      this.gallery = "GALLERY",
      this.lastMonth = "Last Month",
      this.lastWeek = "Last Week",
      this.tapPhotoSelect = "Tap photo to select",
      this.selected = "Selected",
      this.months = const [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
      ],
      this.mode = Mode.light,
      this.selectIcon});
}
