import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:gallery_picker/gallery_picker.dart';
import 'editable_media.dart';

class Editor {
  Color color;
  double thickness, fontSize;
  late PainterController controller;

  int? get imageWith => image != null ? image!.width : null;
  int? get imageHeight => image != null ? image!.height : null;
  double? get aspectRatio =>
      image != null ? (image!.width / image!.height) : null;
  bool isEditting = false;
  bool get isDrawMode => controller.freeStyleMode == FreeStyleMode.draw;
  bool get canUndo => controller.canUndo;
  bool get canRedo => controller.canRedo;
  FocusNode textFocusNode = FocusNode();
  ui.Image? image;
  Editor(
      {required this.color, required this.thickness, required this.fontSize}) {
    setEditor();
  }

  setEditor() {
    controller = PainterController(
        settings: PainterSettings(
            text: TextSettings(
              focusNode: textFocusNode,
              textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: fontSize),
            ),
            freeStyle: FreeStyleSettings(
              color: color,
              mode: FreeStyleMode.draw,
              strokeWidth: thickness,
            ),
            shape: ShapeSettings(
              paint: Paint()
                ..strokeWidth = thickness
                ..color = color
                ..style = PaintingStyle.stroke
                ..strokeCap = StrokeCap.round,
            ),
            scale: const ScaleSettings(
              enabled: true,
              minScale: 1,
              maxScale: 5,
            )));
  }

  Future<void> setBackground(Uint8List bytes) async {
    await MemoryImage(bytes).image.then((image) {
      this.image = image;
      controller.background = image.backgroundDrawable;
    });
  }

  void drawMode() {
    isEditting = true;
    controller.freeStyleMode = FreeStyleMode.draw;
  }

  void close() {
    isEditting = false;
    controller.freeStyleMode = FreeStyleMode.none;
  }

  void textMode() {
    isEditting = true;
    controller.freeStyleMode = FreeStyleMode.none;
  }

  void addText() {
    textMode();
    controller.addText();
  }

  void changeFontsize(double fontSize) {
    this.fontSize = fontSize;
    controller.textSettings = controller.textSettings.copyWith(
        textStyle:
            controller.textSettings.textStyle.copyWith(fontSize: fontSize));
  }

  void changeColor(Color color) {
    this.color = color;
    controller.freeStyleColor = color;
    controller.shapePaint!.color = color;
    controller.textSettings = controller.textSettings.copyWith(
        textStyle: controller.textSettings.textStyle.copyWith(color: color));
  }

  void changeThickness(double thickness) {
    this.thickness = thickness;
    controller.freeStyleStrokeWidth = thickness;
  }

  Future<Uint8List?> getData() async {
    if (image != null) {
      var result = await controller
          .renderImage(Size(image!.width.toDouble(), image!.height.toDouble()));
      return await result.pngBytes;
    } else {
      return null;
    }
  }

  void dispose() {
    controller.clearDrawables();
    controller.dispose();
  }

  void clear() {
    dispose();
    setEditor();
  }

  void undo() {
    controller.undo();
  }

  void redo() {
    controller.redo();
  }
}
