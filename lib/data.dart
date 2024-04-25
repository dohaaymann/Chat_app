import 'package:chatview/chatview.dart';

class Data {
  static const profileImage =
      "https://raw.githubusercontent.com/SimformSolutionsPvtLtd/flutter_showcaseview/master/example/assets/simform.png";
  static final messageList = [
    Message(
      id: '1',
      message: "Hello!",
      createdAt: DateTime.now(),
      sendBy: '1',
    ),
    Message(
      id: '2',
      message: "Hi!",
      createdAt: DateTime.now(),
      sendBy: '2',
    ),
  ];
}
