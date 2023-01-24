import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:photo_gallery/photo_gallery.dart';

import 'media_type.dart';

class MediaFile {
  File originalFile;
  Uint8List? edittedFile;
  Uint8List? thumbnail;
  MediaType type;
  Medium? medium;
  
  MediaFile({
    required this.originalFile,
    this.edittedFile,
    this.thumbnail,
    required this.type,
    this.medium,
  });

  

  bool get isVideo => type == MediaType.video;
  bool get isImage => type == MediaType.image;

}
