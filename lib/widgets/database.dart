import 'dart:io';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

String _basicAuth = 'Basic ' +
    base64Encode(utf8.encode(
        'dohaayman:doha1234'));

Map<String, String> myheaders = {
  'authorization': _basicAuth
};

class database {
    Future<dynamic> postRequest(String url, Map data) async {
    try {
      var response = await http.post(Uri.parse(url),body: data,headers: myheaders,);
      print("respgoneeeeeeeeee");
      if (response != null) {
        print('Response body: ${response.body}---${response.statusCode}');

        if (response.statusCode == 200) {
          try {
            var responseBody =await json.decode((response.body));
            // jsonDecode(response.body);
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
