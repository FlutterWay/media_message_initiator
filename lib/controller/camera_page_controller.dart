import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_emoji_gif_picker/flutter_emoji_gif_picker.dart'
    as emoji;
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/config.dart';
import '../models/media_file.dart';
import '../models/media_type.dart';
import '../models/mode.dart';
import '/views/camera_page/camera_page.dart';
import '/views/camera_page/camera_page_top/flash_icon.dart';
import '/views/edit_media/crop_image.dart';
import '/views/edit_media/edit_media_page.dart';
import '../models/editor.dart';
import '../models/editable_media.dart';
import '../models/shared_person.dart';
import 'package:gallery_picker/gallery_picker.dart' as gallery_picker;

class CameraPageController extends GetxController {
  CameraController? _cameraController;
  TextEditingController caption = TextEditingController(text: "");
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _baseScale = 1.0;
  double _dynamicScale = 1.0;
  double _currentScale = 1.0;
  List<CameraDescription>? _cameras;

  bool _isRecording = false;
  bool _isTakingPicture = false;
  bool _isInitialized = false;
  CameraLensDirection? _cameraLensDirection;
  FlashType? flashType;
  bool get isRecording => _isRecording;
  bool get isTakingPicture => _isTakingPicture;
  bool get anyProcess => _isTakingPicture || _isRecording;
  bool get isInitialized => _isInitialized;
  CameraController? get cameraController => _cameraController;
  double get currentScale => _currentScale;
  List<EditableMedia> get allMedia => _allMedia;
  List<EditableMedia> get selectedMedia => _selectedMedia;
  CameraLensDirection? get cameraLensDirectio => _cameraLensDirection;
  List<Person> get sharedPeopleList => _sharedPeopleList;
  SharedPreferences? prefs;
  gallery_picker.Config get galleryPickerConfig => gallery_picker.Config(
        mode: config.emojiPickerConfig.mode == Mode.light
            ? gallery_picker.Mode.light
            : gallery_picker.Mode.dark,
        selectIcon: config.galleryPickerConfig.selectIcon,
        backgroundColor: config.galleryPickerConfig.backgroundColor,
        appbarColor: config.galleryPickerConfig.appbarColor,
        bottomSheetColor: config.galleryPickerConfig.bottomSheetColor,
        appbarIconColor: config.galleryPickerConfig.appbarIconColor,
        underlineColor: config.galleryPickerConfig.underlineColor,
        selectedMenuStyle: config.galleryPickerConfig.selectedMenuStyle,
        unselectedMenuStyle: config.galleryPickerConfig.unselectedMenuStyle,
        textStyle: config.galleryPickerConfig.textStyle,
        appbarTextStyle: config.galleryPickerConfig.appbarTextStyle,
        recents: config.galleryPickerConfig.recents,
        recent: config.galleryPickerConfig.recent,
        gallery: config.galleryPickerConfig.gallery,
        lastMonth: config.galleryPickerConfig.lastMonth,
        lastWeek: config.galleryPickerConfig.lastWeek,
        tapPhotoSelect: config.galleryPickerConfig.tapPhotoSelect,
        selected: config.galleryPickerConfig.selected,
        months: config.galleryPickerConfig.months,
      );

  List<Person> _sharedPeopleList = [];
  List<EditableMedia> _allMedia = [];
  List<EditableMedia> cameraMedia = [];
  List<EditableMedia> _selectedMedia = [];

  Function(Person person)? onClickedPerson;

  late Function(List<MediaFile> media, String message) onFinished;
  late Config config;

  void configuration(
      {required dynamic Function(List<MediaFile>, String) onFinished,
      required Config config}) {
    this.onFinished = onFinished;
    this.config = config;
  }

  void updateSelectedMedia(List<gallery_picker.MediaFile> media) {
    var selectedFiles = media
        .where((element) => !_selectedMedia
            .any((selected) => selected.mediaFile.id == element.id))
        .toList();
    var unselectedFiles = _selectedMedia
        .where((selected) =>
            !media.any((element) => element.id == selected.mediaFile.id))
        .toList();
    for (var unselected in unselectedFiles) {
      unselected.dispose();
    }
    for (var selectedEditable in _allMedia
        .where((element) => selectedFiles
            .any((selectedMedia) => selectedMedia.id == element.mediaFile.id))
        .toList()) {
      selectedEditable.initEditor();
    }
    _selectedMedia = _allMedia
        .where((element) => media
            .any((selectedMedia) => selectedMedia.id == element.mediaFile.id))
        .toList();
  }

  set setSharedPeopleList(List<Person> people) {
    _sharedPeopleList = people;
    update();
  }

  void addPerson(Person person) {
    if (!_sharedPeopleList.any((element) => element.name == person.name)) {
      _sharedPeopleList.add(person);
      update();
    }
  }

  void changeFlashType(FlashType mode) {
    flashType = mode;
    setFlashType();
    switch (mode) {
      case FlashType.auto:
        if (cameraController != null && initialized) {
          cameraController!.setFlashMode(FlashMode.auto);
        }
        break;
      case FlashType.on:
        break;
      case FlashType.off:
        if (cameraController != null && initialized) {
          cameraController!.setFlashMode(FlashMode.off);
        }
        break;
    }
  }

  Future<void> getAvaliableCameras() async {
    if (_cameras == null || _cameras!.isEmpty) {
      _cameras = await availableCameras();
    }
  }

  Future<void> initializeCamera() async {
    if (_cameras != null &&
        _cameras!
            .any((camera) => camera.lensDirection == _cameraLensDirection)) {
      final camera = _cameras!
          .firstWhere((camera) => camera.lensDirection == _cameraLensDirection);
      _cameraController = CameraController(camera, ResolutionPreset.high);
      if (kDebugMode) {
        print(_cameraLensDirection);
      }
      await _cameraController!.initialize();
      await _cameraController!
          .getMaxZoomLevel()
          .then((double value) => _maxAvailableZoom = value);
      await _cameraController!
          .getMinZoomLevel()
          .then((double value) => _minAvailableZoom = value);
    }
  }

  Future<void> changeCameraLensDirection() async {
    _cameraLensDirection = _cameraLensDirection == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    setCameraDirection();
    await initializeCamera();
    Future.delayed(const Duration(milliseconds: 500)).then((value) => update());
  }

  Future<void> initialize() async {
    await getRecentMedias().then((value) {
      _allMedia = value.map((e) => EditableMedia.mediaFile(e)).toList();
      update();
    });
    prefs ??= await SharedPreferences.getInstance();
    if (flashType == null) {
      await fetchFlashType();
    }
    if (_cameraLensDirection == null) {
      await fetchCameraDirection();
    }
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      await initializeCamera();
    }
    gallery_picker.GalleryPicker.listenSelectedFiles.listen((media) {
      updateSelectedMedia(media);
      update();
    });
    _isInitialized = true;
    update();
  }

  Future<void> fetchFlashType() async {
    String? type = prefs!.getString('flashType');
    if (type != null) {
      flashType = stringToFlashType(type);
    } else {
      flashType = FlashType.off;
      await setFlashType();
    }
  }

  Future<void> fetchCameraDirection() async {
    String? direction = prefs!.getString('cameraDirection');
    if (direction != null) {
      _cameraLensDirection = stringToDirection(direction);
    } else {
      _cameraLensDirection = CameraLensDirection.back;
      await setCameraDirection();
    }
  }

  Future<void> setCameraDirection() async {
    await prefs!
        .setString('cameraDirection', directionToString(_cameraLensDirection!));
  }

  Future<void> setFlashType() async {
    await prefs!.setString('flashType', flashTypeToString(flashType!));
  }

  String directionToString(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.front:
        return "front";
      default:
        return "back";
    }
  }

  CameraLensDirection stringToDirection(String direction) {
    switch (direction) {
      case "front":
        return CameraLensDirection.front;
      default:
        return CameraLensDirection.back;
    }
  }

  String flashTypeToString(FlashType type) {
    switch (type) {
      case FlashType.auto:
        return "auto";
      case FlashType.off:
        return "off";
      case FlashType.on:
        return "on";
    }
  }

  FlashType stringToFlashType(String type) {
    switch (type) {
      case "auto":
        return FlashType.auto;
      case "off":
        return FlashType.off;
      default:
        return FlashType.on;
    }
  }

  Future<void> startVideoRecording() async {
    if (_cameraController != null && !anyProcess) {
      _isRecording = true;
      _isTakingPicture = false;
      update();
      try {
        if (flashType == FlashType.on) {
          cameraController!.setFlashMode(FlashMode.torch);
        }
        await _cameraController!.prepareForVideoRecording();
        await _cameraController!.startVideoRecording();
      } catch (e) {
        _isRecording = false;
        _isTakingPicture = false;
        update();
        if (kDebugMode) {
          print(e);
        }
      }
    }
  }

  Future<void> stopVideoRecording(BuildContext context) async {
    if (_cameraController != null && anyProcess) {
      _isRecording = false;
      _isTakingPicture = false;
      update();
      try {
        if (flashType == FlashType.on) {
          cameraController!.setFlashMode(FlashMode.off);
        }
        XFile xfile = await _cameraController!.stopVideoRecording();
        EditableMedia file = EditableMedia.file(File(xfile.path),
            type: gallery_picker.MediaType.video);
        _allMedia.insert(0, file);
        _selectedMedia.add(file);
        cameraMedia.add(file);
        if (_selectedMedia.length == 1) {
          // ignore: use_build_context_synchronously
          await goToEditMediaPage(context);
        }
        update();
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }
  }

  void unselectMedia(EditableMedia file) {
    print(_selectedMedia.length);
    _selectedMedia
        .removeWhere((element) => element.mediaFile.id == file.mediaFile.id);
    print(_selectedMedia.length);
    update();
  }

  void selectMedia(EditableMedia file) {
    if (!_selectedMedia.any((element) => element == file)) {
      _selectedMedia.add(file);
      if (file.mediaFile.isImage) {
        if (selectedMedia.length == 1) {
          file.initEditor().then((value) => update());
        } else {
          file.initEditor();
          update();
        }
      } else {
        update();
      }
    }
  }

  bool isSelectedMedia(EditableMedia file) {
    return _selectedMedia
        .any((element) => element.mediaFile.id == file.mediaFile.id);
  }

  Future<void> takePhoto(BuildContext context) async {
    if (_cameraController != null && !anyProcess) {
      if (flashType == FlashType.on) {
        cameraController!.setFlashMode(FlashMode.always);
      }
      _isRecording = false;
      _isTakingPicture = true;
      update();
      Future.delayed(const Duration(milliseconds: 200)).then((value) {
        _isTakingPicture = false;
        update();
      });
      XFile xfile = await _cameraController!.takePicture();
      if (flashType == FlashType.on) {
        cameraController!.setFlashMode(FlashMode.off);
      }
      EditableMedia file = EditableMedia.file(File(xfile.path),
          type: gallery_picker.MediaType.image);
      _allMedia.insert(0, file);
      _selectedMedia.add(file);
      cameraMedia.add(file);
      await file.initEditor();
      if (_selectedMedia.length == 1) {
        // ignore: use_build_context_synchronously
        await goToEditMediaPage(context);
      }
      update();
    }
  }

  focus(TapUpDetails details, BuildContext context) async {
    if (cameraController != null) {
      double x = details.localPosition.dx;
      double y = details.localPosition.dy;

      double fullWidth = MediaQuery.of(context).size.width;
      double cameraHeight = fullWidth * cameraController!.value.aspectRatio;

      double xp = x / fullWidth;
      double yp = y / cameraHeight;

      Offset point = Offset(xp, yp);
      await cameraController!.setFocusPoint(point);
    }
  }

  void scaleEnd() {
    _dynamicScale = currentScale;
  }

  Future<void> scaleUpdate(
      {required double scale, required int pointers}) async {
    print("scaleUpdate:$scale");
    if (_cameraController == null || pointers != 2) {
      return;
    }
    double total = _dynamicScale + scale - 1;
    if (total > _maxAvailableZoom) {
      _currentScale = _maxAvailableZoom;
    } else if (total < _minAvailableZoom) {
      _currentScale = _minAvailableZoom;
    } else {
      _currentScale = total;
    }
    await _cameraController!.setZoomLevel(_currentScale);
  }

  Future<List<gallery_picker.MediaFile>> getRecentMedias() async {
    gallery_picker.GalleryMedia? gallery =
        await gallery_picker.GalleryPicker.collectGallery;
    if (gallery != null && gallery.recent != null) {
      return gallery.recent!.files;
    } else {
      return [];
    }
  }

  Future<void> generateMessage(String message, BuildContext context) async {
    List<MediaFile> files = [];
    for (var file in selectedMedia) {
      await file.setEdittedFile();
      files.add(MediaFile(
          originalFile: await file.mediaFile.getFile(),
          type: MediaType.video,
          thumbnail: file.mediaFile.thumbnail,
          medium: file.mediaFile.medium,
          edittedFile: file.edittedFile));
    }
    onFinished(files, message);
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  Future<void> resetScale() async {
    await _cameraController!.setZoomLevel(_baseScale);
  }

  void onViewFinderTap(TapUpDetails details, BoxConstraints constraints) {
    if (_cameraController == null) {
      return;
    }
    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    _cameraController!.setExposurePoint(offset);
    _cameraController!.setFocusPoint(offset);
  }

  Future<void> cropImage(
      {required BuildContext context, required EditableMedia media}) async {
    await Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft, child: CropImage(media)));
  }

  void backToEditMediaPage(BuildContext context) {
    Navigator.pop(
        context,
        PageTransition(
            type: PageTransitionType.leftToRight,
            child: const EditMediaPage()));
  }

  Future<void> goToEditMediaPage(BuildContext context) async {
    resetStatus();
    await Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft,
            child: const EditMediaPage()));
    emoji.EmojiGifPickerPanel.close();
  }

  void backToCamera(BuildContext context) {
    try {
      Navigator.pop(
          context,
          PageTransition(
              type: PageTransitionType.leftToRight, child: const CameraPage()));
      emoji.EmojiGifPickerPanel.close();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> disposeCamera() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
      _isRecording = false;
      _isTakingPicture = false;
      _minAvailableZoom = 1.0;
      _maxAvailableZoom = 1.0;
      _baseScale = 1.0;
      _currentScale = 1.0;
      _dynamicScale = 1.0;
    }
  }

  void clearFiles() {
    _allMedia = [];
    _selectedMedia = [];
    cameraMedia = [];
  }

  void clearPeople() {
    _sharedPeopleList = [];
  }

  void resetStatus() {
    _isRecording = false;
    _isTakingPicture = false;
  }

  void onWillPop() {
    clearFiles();
    clearPeople();
    _isInitialized = false;
    gallery_picker.GalleryPicker.dispose();
    gallery_picker.GalleryPicker.disposeSelectedFilesListener();
  }

  Future<void> disposeController() async {
    clearFiles();
    clearPeople();
    await disposeCamera();
    _isInitialized = false;
    gallery_picker.GalleryPicker.disposeSelectedFilesListener();
    GetInstance().delete<CameraPageController>();
  }
}
