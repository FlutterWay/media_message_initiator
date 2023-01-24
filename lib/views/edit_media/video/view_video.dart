import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_editor/video_editor.dart';
import '/controller/camera_page_controller.dart';
import '../../../models/editable_media.dart';
import 'trim_viewer.dart';

class ViewVideo extends StatefulWidget {
  final EditableMedia media;
  final Function(EditableMedia media) unSelect;
  const ViewVideo({super.key, required this.media, required this.unSelect});

  @override
  State<ViewVideo> createState() => _ViewVideoState();
}

class _ViewVideoState extends State<ViewVideo> {
  late EditableMedia media;
  var controller = Get.find<CameraPageController>();
  @override
  void initState() {
    media = widget.media;
    initPlayer();
    super.initState();
  }

  void initPlayer() {
    if (media.controller == null || media.videoInitializingFailed == true) {
      media.initVideoPlayer().then((value) {
        if (mounted) setState(() {});
      });
    }
  }

  void checkFile() {
    if (widget.media != media) {
      media.resetVideo();
      media = widget.media;
      updateMedia();
      initPlayer();
    }
  }

  @override
  void dispose() {
    media.resetVideo();
    super.dispose();
  }

  bool updating = false;

  updateMedia() async {
    if (mounted) {
      setState(() {
        updating = true;
      });
    }
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() {
        updating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    checkFile();
    return media.controller != null && media.controller!.initialized
        ? WillPopScope(
            onWillPop: (() async {
              if (Get.find<CameraPageController>().selectedMedia.length == 1) {
                media.unselect();
              }
              return true;
            }),
            child: Scaffold(
              backgroundColor: controller.config.backgroundColor,
              resizeToAvoidBottomInset: false,
              body: !updating
                  ? Stack(
                      children: [
                        Center(
                          child: AspectRatio(
                            aspectRatio: media.controller!.videoWidth /
                                media.controller!.videoHeight,
                            child: Stack(
                              children: [
                                Center(
                                  child: CropGridViewer.preview(
                                      controller: media.controller!),
                                ),
                                Center(
                                  child: MaterialButton(
                                    color: Colors.black.withOpacity(0.5),
                                    padding: const EdgeInsets.all(15),
                                    onPressed: playPause,
                                    shape: const CircleBorder(),
                                    child: Icon(
                                      media.isVideoPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 40,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            color: Colors.transparent,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              if (controller
                                                      .selectedMedia.length ==
                                                  1) {
                                                media.unselect();
                                              }
                                              controller.backToCamera(context);
                                            },
                                            icon: Icon(
                                              Icons.close,
                                              color:
                                                  controller.config.iconColor,
                                            )),
                                        if (controller.selectedMedia.length > 1)
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete_outline,
                                              color:
                                                  controller.config.iconColor,
                                            ),
                                            onPressed: () async {
                                              media.unselect();
                                              widget.unSelect(media);
                                            },
                                          ),
                                      ],
                                    ),
                                    TrimViewer(controller: media.controller!),
                                    IconButton(
                                        onPressed: () {
                                          if (media.isVolumeUp) {
                                            media.volumeMute();
                                          } else {
                                            media.volumeUp();
                                          }
                                          setState(() {});
                                        },
                                        icon: Icon(
                                          media.isVolumeUp
                                              ? Icons.volume_up
                                              : Icons.volume_mute,
                                          color: controller.config.iconColor,
                                        ))
                                  ]),
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }

  Future<void> playPause() async {
    if (!media.controller!.isPlaying) {
      await media.playVideo(onFinished: () async {
        await media.resetVideo();
        setState(() {});
      });
    } else {
      await media.controller!.video.pause();
    }
    setState(() {});
  }
}
