import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  var client = new http.Client();
  var backEndURL = "https://diss-app.onrender.com/";

  // GET
  Future<dynamic> get(String api) async {
    var url = Uri.parse(backEndURL + api);

    var response = await client.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Failed to get " + response.statusCode.toString() + " getting");
    }
  }

  // POST
  Future<dynamic> post(String api, dynamic object) async {
    var url = Uri.parse(backEndURL + api);

    var _headers = {
      'Content-Type': 'application/json',
    };

    var response =
        await client.post(url, body: jsonEncode(object), headers: _headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response;
    } else {
      print("Failed to post " + response.statusCode.toString() + " posting");
    }
  }
}
