import 'package:flutter_athropic_interface/flutter_athropic_interface.dart';
import 'package:http/http.dart';

class Configuration {
  static const String _apiProtocol = 'https';
  static const String _apiUrl = 'api.anthropic.com';
  static const String _apiVersion = 'v1';

  static Request getUrlAnthropic(String endpoint, {String httpRequestType = 'POST', Map<String, dynamic> callParams = const {}, Map<String, String> headers = const {}}) {

    if (AthropicInterface.instance.apiKey.isEmpty) {
      throw Exception('API Key is not set. Please initialize AthropicInterface with a valid API key.');
    }

    String url = '$_apiProtocol://$_apiUrl/$_apiVersion/$endpoint';

    if (callParams.isNotEmpty) {
      final queryParams = callParams.entries.map((entry) => '${entry.key}=${entry.value}').join('&');
      url += '&$queryParams';
    }

    final Request request = Request(httpRequestType, Uri.parse(url));
    request.headers.clear();
    request.headers.addAll({
      'Content-Type': 'application/json',
      'x-api-key': AthropicInterface.instance.apiKey,
      'anthropic-version': '2023-06-01',
      if (headers.isNotEmpty) ...headers,
    });
    return request;
  }

  static MultipartRequest getMultipartUrlAnthropic(String endpoint, {String httpRequestType = 'POST', Map<String, dynamic> callParams = const {}, Map<String, String> headers = const {}}) {

    if (AthropicInterface.instance.apiKey.isEmpty) {
      throw Exception('API Key is not set. Please initialize AthropicInterface with a valid API key.');
    }

    String url = '$_apiProtocol://$_apiUrl/$_apiVersion/$endpoint';

    if (callParams.isNotEmpty) {
      final queryParams = callParams.entries.map((entry) => '${entry.key}=${entry.value}').join('&');
      url += '&$queryParams';
    }

    final MultipartRequest request = MultipartRequest(httpRequestType, Uri.parse(url));
    request.headers.clear();
    request.headers.addAll({
      'Content-Type': 'application/json',
      'x-api-key': AthropicInterface.instance.apiKey,
      'anthropic-version': '2023-06-01',
      if (headers.isNotEmpty) ...headers,
    });
    return request;
  }
}
