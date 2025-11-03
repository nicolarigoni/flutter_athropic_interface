import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_athropic_interface/src/models/generic_response.dart';
import 'package:flutter_athropic_interface/src/models/message_request.dart';
import 'package:flutter_athropic_interface/src/services/configuration.dart';
import 'package:flutter_athropic_interface/src/services/dto/completion_dto.dart';
import 'package:flutter_athropic_interface/src/services/utils/package_utils.dart';
import 'package:http/http.dart';

class AthropicService {
  static const String _tag = 'AthropicService';

  static const String _endPoint = 'messages';

  static Future<GenericResponse<CompletionResponseDto>> sendRequest(MessageRequest messageRequest) async {
    try {
      final Request request = Configuration.getUrlAnthropic(_endPoint);

      final now = DateTime.now();
      final jsonEncoder = JsonEncoder.withIndent('  ');
      final prettyBody = jsonEncoder.convert(messageRequest.toJson());
      await PackageUtils.writeLogToFile(logFileName: PackageUtils.logFileName('body_${PackageUtils.formatDate(now)}'), log: prettyBody);

      request.body = jsonEncode(messageRequest.toJson());
      final StreamedResponse streamedResponse = await request.send().timeout(PackageUtils.serviceTimeout);
      final response = await streamedResponse.stream.bytesToString();

      await PackageUtils.writeLogToFile(logFileName: PackageUtils.logFileName('response_${PackageUtils.formatDate(now)}'), log: response);

      if (streamedResponse.statusCode == 200) {
        final data = jsonDecode(response) as Map<String, dynamic>;
        PackageUtils.writeConsoleLog(LogType.info, '$_tag/sendRequest', 'Data: $data');
        final serviceResponse = CompletionResponseDto.fromService(data);
        if (serviceResponse.error != null) {
          return GenericResponse(false, message: '${serviceResponse.error!.type} - ${serviceResponse.error!.message}');
        }
        return GenericResponse(true, object: serviceResponse);
      }

      PackageUtils.writeConsoleLog(LogType.error, '$_tag/sendRequest', 'Error: ${streamedResponse.statusCode} - Data: $response');
      return GenericResponse(false, message: '(${streamedResponse.statusCode}) - $response');
    } on TimeoutException catch (e) {
      PackageUtils.writeConsoleLog(LogType.error, '$_tag/sendRequest', 'TimeoutException. (Error: ${e.toString()})');
      return GenericResponse(false, message: 'error_service_timeout');
    } on SocketException catch (e) {
      PackageUtils.writeConsoleLog(LogType.error, '$_tag/sendRequest', 'Exception. (Error: $e)');
      return GenericResponse(false, message: 'error_service_reach');
    } catch (e) {
      PackageUtils.writeConsoleLog(LogType.error, '$_tag/sendRequest', 'Exception. (Error: $e)');
      return GenericResponse(false, message: 'error_service_unknown');
    }
  }
}
