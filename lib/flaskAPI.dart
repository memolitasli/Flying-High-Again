import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

fetchData(String url) async{
  http.Response response =await http.get(Uri.parse(url));
  return response.body;
}
postData(String url,Map<String,dynamic> data)async{
  http.Response response = await http.post(Uri.parse(url),body: jsonEncode(data));
  debugPrint(response.body.toString());
  return response.body;
}