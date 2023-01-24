import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gallery_picker/gallery_picker.dart';
import 'package:get/get.dart';
import 'package:video_editor/video_editor.dart';
import '../controller/editor_updater.dart';
import '/controller/camera_page_controller.dart';
import 'editor.dart';
import 'trim_slider_style.dart' as trim_slider_style;

class EditableMedia {
  late MediaFile mediaFile;
  Uint8List? edittedFile;
  VideoEditorController? controller;
  bool? videoInitializingFailed;
  Editor? editor;

  EditableMedia.file(File file, {required MediaType type}) {
    mediaFile = MediaFile.file(id: getRandId(), file: file, type: type);
    if (type == MediaType.image) {
      editor = Editor(color: Colors.black, thickness: 2, fontSize: 36);
    }
  }
  EditableMedia.mediaFile(this.mediaFile) {
    if (mediaFile.type == MediaType.image) {
      editor = Editor(color: Colors.black, thickness: 2, fontSize: 36);
    }
  }

  Future<void> initVideoEditorController() async {
    trim_slider_style.TrimSliderStyle? style;
    if (GetInstance().isRegistered<CameraPageController>()) {
      style = Get.find<CameraPageController>().config.trimSliderStyle;
    }
    if (mediaFile.type == MediaType.video) {
      controller = VideoEditorController.file(
        await mediaFile.getFile(),
        minDuration: const Duration(seconds: 1),
        maxDuration: const Duration(seconds: 150),
        trimStyle: TrimSliderStyle(
          background: style != null ? style.background : Colors.black54,
          positionLineWidth: style != null ? style.positionLineWidth : 4,
          lineWidth: style != null ? style.lineWidth : 2,
          borderRadius: style != null ? style.borderRadius : 5.0,
          edgesSize: style?.edgesSize,
          iconSize: style != null ? style.iconSize : 16,
          leftIcon:
              style != null ? style.leftIcon : Icons.arrow_back_ios_rounded,
          rightIcon:
              style != null ? style.rightIcon : Icons.arrow_forward_ios_rounded,
          lineColor: style != null ? style.lineColor : Colors.white,
          onTrimmingColor: style != null ? style.onTrimmingColor : Colors.white,
          onTrimmedColor: style != null ? style.onTrimmedColor : Colors.white,
          iconColor: style != null ? style.iconColor : Colors.black,
          positionLineColor:
              style != null ? style.positionLineColor : Colors.white,
          edgesType: style == null
              ? TrimSliderEdgesType.circle
              : style.edgesType == trim_slider_style.TrimSliderEdgesType.circle
                  ? TrimSliderEdgesType.circle
                  : TrimSliderEdgesType.bar,
        ),
      );
    }
  }

  bool get isEditted => edittedFile != null;

  void editFile(Uint8List bytes) {
    edittedFile = bytes;
  }

  void cropFile(Uint8List bytes) {
    edittedFile = bytes;
    if (editor != null) {
      editor!.setBackground(bytes);
    }
  }

  Future<void> initVideoPlayer() async {
    if (controller == null) {
      await initVideoEditorController();
    }
    if (!controller!.initialized) {
      videoInitializingFailed = false;
      await controller!.initialize().catchError((e) {
        videoInitializingFailed = true;
      });
      controller!.video.setLooping(false);
    }
  }

  Future<void> disposeVideoController() async {
    if (controller != null && controller!.initialized) {
      await controller!.dispose();
      controller = null;
    }
  }

  void unselect() {
    Get.find<CameraPageController>().unselectMedia(this);
    Future.delayed(const Duration(milliseconds: 500))
        .then((value) => dispose());
  }

  void dispose() {
    edittedFile = null;
    if (mediaFile.type == MediaType.video) {
      disposeVideoController();
    } else {
      disposeEditor();
    }
  }

  void disposeEditor() {
    if (editor != null) {
      editor!.dispose();
      editor = null;
    }
  }

  void clearEditor() {
    if (editor != null) {
      editor!.clear();
    }
  }

  Future<void> setEdittedFile() async {
    if (mediaFile.isVideo && controller != null) {
      await controller!.exportVideo(
        onCompleted: (file) => edittedFile = file.readAsBytesSync(),
      );
    } else {
      edittedFile = await editor!.getData();
    }
  }

  void select() {
    Get.find<CameraPageController>().selectMedia(this);
  }

  Future<void> initEditor() async {
    editor ??= Editor(color: Colors.black, thickness: 2, fontSize: 36);
    await editor!.setBackground(await mediaFile.getData());
    Get.find<EditorUpdater>().updateEditor(mediaFile.id);
  }

  Function()? _onFinished;
  Future<void> playVideo({required Function() onFinished}) async {
    _onFinished = onFinished;
    if (controller != null) {
      await controller!.video.play();
      controller!.video.addListener(videoListener);
    }
  }

  bool get isVideoPlaying {
    if (controller != null) {
      return controller!.video.value.isPlaying;
    } else {
      return false;
    }
  }

  void videoListener() {
    if (controller!.video.value.position == controller!.video.value.duration) {
      if (_onFinished != null) {
        _onFinished!();
      }
      controller!.video.removeListener(videoListener);
    }
  }

  void volumeUp() {
    if (controller != null) {
      controller!.video.setVolume(1);
    }
  }

  void volumeMute() {
    if (controller != null) {
      controller!.video.setVolume(0.0);
    }
  }

  bool get isVolumeUp {
    if (controller != null && controller!.video.value.volume != 0.0) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> resetVideo() async {
    if (controller != null) {
      await controller!.video.seekTo(Duration.zero);
      await controller!.initialize();
      await controller!.video.setLooping(false);
    }
  }

  bool get isSelected => Get.find<CameraPageController>().isSelectedMedia(this);
}

String getRandId() {
  const alphabet =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  const length = 20;
  final buffer = StringBuffer();
  final random = Random.secure();

  const maxRandom = alphabet.length;

  for (int i = 0; i < length; i++) {
    buffer.write(alphabet[random.nextInt(maxRandom)]);
  }
  return buffer.toString();
}
