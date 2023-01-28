import 'dart:typed_data';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import '../../models/config.dart';
import '/controller/camera_page_controller.dart';
import '../../models/editable_media.dart';

class CropImage extends StatefulWidget {
  final EditableMedia media;
  const CropImage(this.media, {super.key});

  @override
  State<CropImage> createState() => _CropImageState();
}

class _CropImageState extends State<CropImage> {
  int sayac = 0;
  double girth = 3, length = 30;
  Uint8List? rotatedImage;
  final _controller = CropController();
  Config config = Get.find<CameraPageController>().config;
  bool rotating = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: config.backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: !rotating
                ? FutureBuilder(
                    future: widget.media.mediaFile.getData(),
                    builder: (context, data) {
                      return data.data != null
                          ? Crop(
                              image: rotatedImage ?? data.data!,
                              withCircleUi: false,
                              baseColor: config.backgroundColor,
                              controller: _controller,
                              cornerDotBuilder: (x, y) {
                                sayac++;
                                if (sayac == 5) sayac = 1;
                                return Stack(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          sayac == 1 || sayac == 2
                                              ? CrossAxisAlignment.start
                                              : CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          width: sayac == 2 || sayac == 4
                                              ? length
                                              : girth,
                                          height: sayac == 2 || sayac == 4
                                              ? girth
                                              : length,
                                          color: config.iconColor,
                                          child: const SizedBox(),
                                        ),
                                        Container(
                                          width: sayac == 2 || sayac == 4
                                              ? girth
                                              : length,
                                          height: sayac == 2 || sayac == 4
                                              ? length
                                              : girth,
                                          color: config.iconColor,
                                          child: const SizedBox(),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          sayac == 1 || sayac == 2
                                              ? CrossAxisAlignment.start
                                              : CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          width: sayac == 2 || sayac == 4
                                              ? length
                                              : 30,
                                          height: sayac == 2 || sayac == 4
                                              ? 30
                                              : length,
                                          color: Colors.transparent,
                                          child: const SizedBox(),
                                        ),
                                        Container(
                                          width: sayac == 2 || sayac == 4
                                              ? 30
                                              : length,
                                          height: sayac == 2 || sayac == 4
                                              ? length
                                              : 30,
                                          color: Colors.transparent,
                                          child: const SizedBox(),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                              onCropped: (image) async {
                                widget.media.editor!.clear();
                                await widget.media.editor!.setBackground(image);
                                // ignore: use_build_context_synchronously
                                Get.find<CameraPageController>()
                                    .backToEditMediaPage(context);
                              })
                          : const Center(
                              child: CircularProgressIndicator(),
                            );
                    })
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
          SizedBox(
            height: 60,
            width: MediaQuery.of(context).size.width,
            child: Row(children: [
              Expanded(
                child: Center(
                    child: TextButton(
                  onPressed: () {
                    Get.find<CameraPageController>()
                        .backToEditMediaPage(context);
                  },
                  child: Text(
                    config.cancel,
                    style: TextStyle(color: config.textColor),
                  ),
                )),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () async {
                    setState(() {
                      rotating = true;
                    });
                    var data = rotatedImage ??
                        (await widget.media.mediaFile.getData());
                    final originalImage = img.decodeImage(data);
                    var rotImg = img.copyRotate(originalImage!, angle: -90);
                    rotatedImage = img.encodeJpg(rotImg);
                    await Future.delayed(const Duration(milliseconds: 300));
                    setState(() {
                      rotating = false;
                    });
                  },
                  icon: Center(
                    child: Icon(
                      Icons.rotate_90_degrees_ccw_outlined,
                      color: config.iconColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      _controller.crop();
                    },
                    child: Text(
                      config.finish,
                      style: TextStyle(color: config.textColor),
                    ),
                  ),
                ),
              ),
            ]),
          )
        ],
      ),
    );
  }
}
