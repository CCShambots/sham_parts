import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:sham_parts/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class APISession {
  static Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'token': ""
  };

  static String osKey = "";

  static String currentUrl = APIConstants().baseUrl;

  static Future<bool> ping(String address) async {
    return http.get(Uri.parse("$address/")).then((value) => value.statusCode == 200);
  }

  static Future<http.Response> get(String url) async {
    http.Response response = await http.get(Uri.parse(currentUrl+url), headers: headers);
    return response;
  }

  static Future<http.Response> getFromLeader(String url) async {
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

    http.Response response = await http.get(Uri.parse(currentUrl+url+concatQueryParams), headers: headers);
    return response;
  }

  static Future<http.Response> getFromLeaderWithParams(String url, Map<String, String> queryParams) async {
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
    http.Response response = await http.post(Uri.parse(currentUrl+url), body: data, headers: headers);
    return response;
  }

  static Future<http.Response> postWithParams(String url, Map<String, String> queryParams) async {
    String concatQueryParams = "?";
    var paramsList = queryParams.entries.toList();

    for(int i = 0; i<queryParams.length; i++) {
      concatQueryParams+= "${paramsList[i].key}=${paramsList[i].value}";

      if(i != queryParams.length-1) concatQueryParams+="&";
    }

    http.Response response = await http.post(Uri.parse(currentUrl+url+concatQueryParams), headers: headers);
    return response;
  }


  static Future<http.Response> patch(String url, dynamic data) async {
    http.Response response = await http.patch(Uri.parse(currentUrl+url), body: data, headers: headers);
    return response;
  }

  static Future<http.Response> patchWithParams(String url, Map<String, String> queryParams) async {
    String concatQueryParams = "?";
    var paramsList = queryParams.entries.toList();

    for(int i = 0; i<queryParams.length; i++) {
      concatQueryParams+= "${paramsList[i].key}=${paramsList[i].value}";

      if(i != queryParams.length-1) concatQueryParams+="&";
    }

    http.Response response = await http.patch(Uri.parse(currentUrl+url+concatQueryParams), headers: headers);
    return response;
  }

  static Future<http.Response> delete(String url) async {
    http.Response response = await http.delete(Uri.parse(currentUrl+url), headers: headers);
    return response;
  }

  static Future<http.Response> deleteWithParams(String url, Map<String, String> queryParams) async {
    String concatQueryParams = "?";
    var paramsList = queryParams.entries.toList();

    for(int i = 0; i<queryParams.length; i++) {
      concatQueryParams+= "${paramsList[i].key}=${paramsList[i].value}";

      if(i != queryParams.length-1) concatQueryParams+="&";
    }

    http.Response response = await http.delete(Uri.parse(currentUrl+url+concatQueryParams), headers: headers);
    return response;
  }

  static Future<void> updateKeys() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = prefs.getString(APIConstants().onshapeKey) ?? "";

    String apiUrl = prefs.getString(APIConstants().serverIP) ?? APIConstants().baseUrl;

    currentUrl = apiUrl;

    if(key.isNotEmpty) {
      osKey = key;
    } else {

      var response =await get("/onshape/key");

      if(response.statusCode == 200) {
        key = response.body;
        osKey = key;
        prefs.setString(APIConstants().onshapeKey, key);
      } 
    }


    String token = prefs.getString(APIConstants().userToken) ?? "";
    if(token.isNotEmpty) {
      headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'token': token
      };

    }
  }

  static CachedNetworkImageProvider getOnshapeImage(String thumbnailUrl) {
    return CachedNetworkImageProvider(
      thumbnailUrl,
      headers: {'Authorization': "Basic $osKey"}
    );
  }
}