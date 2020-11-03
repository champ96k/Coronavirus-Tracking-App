import 'dart:convert';
import 'package:coronavirus_tracking_app/Services/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class APIServices {
  
  APIServices(this.api);
  final API api;

  Future<String> getAccessToken() async {

    final response = await http.post(
      api.tokenUri().toString(),
      headers:  { 
        "Authorization" : "Basic ${api.apiKeys}"
      }
    );

    if(response.statusCode ==200) {
      final data = jsonDecode(response.body);
      final accessToken = data['access_token'];
      if(accessToken!=null) {
        return accessToken;
      }
    } 
    debugPrint("Request ${api.tokenUri()} Failed\n ${response.statusCode} ${response.reasonPhrase}");
    throw response;
  }

  Future<int> getEndpointData(
    {
      @required String accessToken,
      @required Endpoints endpoints,
    }
  ) async{
    final uri = api.endPointUri(endpoints);
    final response = await http.get(
      uri.toString(),
      headers: {
        "Authorization" : 'Bearer $accessToken'
      }, 
    );

    if(response.statusCode==200) {
      
      final List<dynamic> data = json.decode(response.body);
      if(data.isNotEmpty) {
        final Map<String,dynamic> endpointData = data[0];
        final String responseJsonKey = _responsejsonkeys[endpointData]; 
        int result = endpointData[responseJsonKey];
        if(result!=null) {
          return result;
        }
      }
    }
    debugPrint("Request ${api.tokenUri()} Failed\n ${response.statusCode} ${response.reasonPhrase}");
    throw response;
  }

  static Map<Endpoints, String> _responsejsonkeys = {
    Endpoints.cases : "cases",
    Endpoints.casesSuspected: "data",
    Endpoints.casesConfirmed: "data",
    Endpoints.deaths:"data",
    Endpoints.recovered : "data", 
  };
  
}