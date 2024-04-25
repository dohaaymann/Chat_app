import 'package:chatview/chatview.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class Controller extends GetxController {
  RxList<Message> messageLength = <Message>[].obs;

  // Add a method to update the message length list
  void updateMessageLength(List<Message> messages) {
    // Assign the new list of messages to the observable list
    messageLength.value = messages;
  }
}