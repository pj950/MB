// lib/controllers/speech_controller.dart
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechController extends GetxController {
  late stt.SpeechToText speech;
  var isListening = false.obs;
  var text = ''.obs;

  @override
  void onInit() {
    super.onInit();
    speech = stt.SpeechToText();
  }

  // 开始语音识别
  void startListening() async {
    final bool available = await speech.initialize();
    if (available) {
      isListening.value = true;
      speech.listen(onResult: (val) {
        text.value = val.recognizedWords;
      });
    } else {
      Get.snackbar('提示', '无法使用语音识别');
    }
  }

  // 停止识别
  void stopListening() {
    speech.stop();
    isListening.value = false;
  }
}
