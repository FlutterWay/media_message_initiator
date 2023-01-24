import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/controller/camera_page_controller.dart';

class SharedPeopleWidget extends StatelessWidget {
  final double fontSize;
  const SharedPeopleWidget({super.key, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CameraPageController>(builder: (controller) {
      return SizedBox(
        height: 60,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            for (var person in controller.sharedPeopleList)
              TextButton(
                onPressed: () {
                  if (controller.onClickedPerson != null) {
                    controller.onClickedPerson!(person);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: controller.config.textfieldBackgroundColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      person.name,
                      style: TextStyle(
                          color: controller.config.textfieldTextStyle.color,
                          fontSize: fontSize),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
