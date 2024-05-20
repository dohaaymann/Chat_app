import 'dart:io';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../links.dart';

// String _basicAuth = 'Basic ' +
//     base64Encode(utf8.encode(
//         'dohaayman:doha1234'));

// Map<String, String>  myheaders=  {
//   'X-RapidAPI-Key': '5cba00b8femshcef2e31c8c84b55p1a7e64jsn0e43052b6af8',
//   'X-RapidAPI-Host': 'chat-gtp-free.p.rapidapi.com'
// };
Map<String, String>  myheaders={
'X-RapidAPI-Key': '5cba00b8femshcef2e31c8c84b55p1a7e64jsn0e43052b6af8',
'X-RapidAPI-Host': 'chatgpt-gpt4-ai-chatbot.p.rapidapi.com'
};
class database {
  // Future<dynamic> postRequest(String url,String content) async {
  //   try {
  //     final msg = jsonEncode({
  //       "query": "2+2=?"
  //     });
      // var response = await http.post(Uri.parse(url), body:msg,headers: myheaders);
      // print("respgoneeeeeeeeee");
  String? _conversationId; // Store the conversationId

  Future<dynamic> postRequest(String url, String query) async {
    try {
          // Construct the JSON object based on whether conversationId is provided
          final Map<String, dynamic> requestBody = {
            "query": query,
          };
          if (_conversationId != null) {
            requestBody["conversationId"] = _conversationId;
          }

          // Encode the JSON object
          final String requestBodyJson = jsonEncode(requestBody);

          // Make the POST request
          final http.Response response = await http.post(
            Uri.parse(url),body: requestBodyJson,
            headers: myheaders
          );

          // Handle the response

          if (response != null) {
        print('Response body: ${response.body}---${response.statusCode}');

        if (response.statusCode == 200) {
          try {
            var responseBody =await json.decode((response.body));
            // jsonDecode(response.body);
            if (responseBody.containsKey('id')) {
              _conversationId = responseBody['id'];
            }
            return responseBody;
          } catch (e) {
            print("JSON decoding error: $e");
            return null; // Or handle the error according to your requirements
          }
        } else {
          print('Error - Status Code: ${response.statusCode}');
          return null; // Or handle the error according to your requirements
        }
      } else {
        print('Error - Response is null');
        return null; // Or handle the error according to your requirements
      }
    } catch (e) {
      print("Errorrr: $e"); // Print more descriptive error messages
      return null; // Or handle the error according to your requirements
    }
  }
  postRequestWithFile(String url,Map data,File file)async{
      var request= http.MultipartRequest("Post",Uri.parse(url));
      var lenght=await file.length();
      var stream=http.ByteStream(file.openRead());
      var multipartfile=http.MultipartFile("file",stream,lenght,filename:basename(file.path));
      request.files.add(multipartfile);
      request.headers.addAll(myheaders);
      data.forEach((key, value) {
        request.fields[key]=value;
      });
      var myrequest=await request.send();
      var respone=await http.Response.fromStream(myrequest);
      if(myrequest.statusCode==200){
        return jsonDecode(respone.body);
      }
      else{
        print("Error ${myrequest.statusCode}");
      }
  }
}
