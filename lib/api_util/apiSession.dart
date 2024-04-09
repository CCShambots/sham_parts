import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:sham_parts/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class APISession {
  static Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  static String osKey = "";

  static Future<http.Response> get(String url) async {
    http.Response response = await http.get(Uri.parse(APIConstants().baseUrl+url), headers: headers);
    return response;
  }

  static Future<http.Response> getWithParams(String url, Map<String, String> queryParams) async {
    String concatQueryParams = "?";
    var paramsList = queryParams.entries.toList();

    for(int i = 0; i<queryParams.length; i++) {
      concatQueryParams+= "${paramsList[i].key}=${paramsList[i].value}";

      if(i != queryParams.length-1) concatQueryParams+="&";
    }

    http.Response response = await http.get(Uri.parse(APIConstants().baseUrl+url+concatQueryParams), headers: headers);
    return response;
  }

  static Future<http.Response> post(String url, dynamic data) async {
    http.Response response = await http.post(Uri.parse(APIConstants().baseUrl+url), body: data, headers: headers);
    return response;
  }

  static Future<http.Response> patch(String url, dynamic data) async {
    http.Response response = await http.patch(Uri.parse(APIConstants().baseUrl+url), body: data, headers: headers);
    return response;
  }

  static void updateOnshapeKey() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = prefs.getString(APIConstants().onshapeKey) ?? "";
    if(key.isNotEmpty) {
      osKey = key;
    } else {
      key = (await get("/onshape/key")).body;

      osKey = key;

      prefs.setString(APIConstants().onshapeKey, key);
    }
  }

  static CachedNetworkImageProvider getOnshapeImage(String thumbnailUrl) {
    return CachedNetworkImageProvider(
      thumbnailUrl,
      headers: {'Authorization': "Basic $osKey"}
    );
  }
}