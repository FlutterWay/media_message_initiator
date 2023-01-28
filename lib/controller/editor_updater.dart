import 'package:get/get.dart';

class EditorUpdater extends GetxController {
  String updatedEditor = "";

  void updateEditor(String id) {
    updatedEditor = id;
    update();
  }

  void disposeController() {
    updatedEditor = "";
    GetInstance().delete<EditorUpdater>();
  }
}
