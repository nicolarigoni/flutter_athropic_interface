import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_athropic_interface/src/models/generic_response.dart';
import 'package:flutter_athropic_interface/src/models/message_request.dart';
import 'package:flutter_athropic_interface/src/services/configuration.dart';
import 'package:flutter_athropic_interface/src/services/dto/completion_dto.dart';
import 'package:flutter_athropic_interface/src/services/dto/upload_dto.dart';
import 'package:flutter_athropic_interface/src/services/utils/package_utils.dart';
import 'package:http/http.dart';

class AthropicService {
  static const String _tag = 'AthropicService';

  static const String _endPoint = 'messages';
  static const String _endPointFiles = 'files';

  static Future<GenericResponse<CompletionResponseDto>> sendRequest(MessageRequest messageRequest, {Map<String, String> headers = const {}}) async {
    try {
      final Request request = Configuration.getUrlAnthropic(_endPoint, headers: headers);

      final now = DateTime.now();
      final formattedDate = PackageUtils.formatDate(now).replaceAll('/', '-');
      final jsonEncoder = JsonEncoder.withIndent('  ');
      final prettyBody = jsonEncoder.convert(messageRequest.toJson());
      await PackageUtils.writeLogToFile(logFileName: PackageUtils.logFileName('body_${formattedDate}'), log: prettyBody);

      request.body = jsonEncode(messageRequest.toJson());
      final StreamedResponse streamedResponse = await request.send().timeout(PackageUtils.serviceTimeout);
      final response = await streamedResponse.stream.bytesToString();

      await PackageUtils.writeLogToFile(logFileName: PackageUtils.logFileName('response_${formattedDate}'), log: response);

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

  static Future<GenericResponse<UploadDto>> uploadFiles(String filePath, {MediaType? mediaType}) async {
    try {
      final MultipartRequest request = Configuration.getMultipartUrlAnthropic(_endPointFiles, headers: {'anthropic-beta': 'files-api-2025-04-14'});
      final filePart = await MultipartFile.fromPath('file', filePath, contentType: mediaType);
      request.files.add(filePart);
      final StreamedResponse streamedResponse = await request.send().timeout(const Duration(minutes: 2));
      final response = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        final data = jsonDecode(response) as Map<String, dynamic>;
        PackageUtils.writeConsoleLog(LogType.info, '$_tag/upload', 'Data: $data');
        final uploadResponse = UploadDto.fromService(data);
        return GenericResponse(true, object: uploadResponse);
      }
      PackageUtils.writeConsoleLog(LogType.error, '$_tag/upload', 'Error: ${streamedResponse.statusCode} - Data: $response');
      return GenericResponse(false, message: '(${streamedResponse.statusCode}) - $response');
    } on TimeoutException catch (e) {
      PackageUtils.writeConsoleLog(LogType.error, '$_tag/upload', 'TimeoutException. (Error: ${e.toString()})');
      return GenericResponse(false, message: 'error_service_timeout');
    } on SocketException catch (e) {
      PackageUtils.writeConsoleLog(LogType.error, '$_tag/upload', 'Exception. (Error: $e)');
      return GenericResponse(false, message: 'error_service_reach');
    } catch (e) {
      PackageUtils.writeConsoleLog(LogType.error, '$_tag/upload', 'Exception. (Error: $e)');
      return GenericResponse(false, message: 'error_service_unknown');
    }
  }

  static Future<GenericResponse> deleteFile(String fileId) async {
    try {
      final Request request = Configuration.getUrlAnthropic(_endPointFiles, httpRequestType: 'DELETE', headers: {'anthropic-beta': 'files-api-2025-04-14'});

      final StreamedResponse streamedResponse = await request.send().timeout(PackageUtils.serviceTimeout);
      final response = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        final data = jsonDecode(response) as Map<String, dynamic>;
        PackageUtils.writeConsoleLog(LogType.info, '$_tag/deleteFile', 'Data: $data');
        return GenericResponse(true);
      }

      PackageUtils.writeConsoleLog(LogType.error, '$_tag/deleteFile', 'Error: ${streamedResponse.statusCode} - Data: $response');
      return GenericResponse(false, message: '(${streamedResponse.statusCode}) - $response');
    } on TimeoutException catch (e) {
      PackageUtils.writeConsoleLog(LogType.error, '$_tag/deleteFile', 'TimeoutException. (Error: ${e.toString()})');
      return GenericResponse(false, message: 'error_service_timeout');
    } on SocketException catch (e) {
      PackageUtils.writeConsoleLog(LogType.error, '$_tag/deleteFile', 'Exception. (Error: $e)');
      return GenericResponse(false, message: 'error_service_reach');
    } catch (e) {
      PackageUtils.writeConsoleLog(LogType.error, '$_tag/deleteFile', 'Exception. (Error: $e)');
      return GenericResponse(false, message: 'error_service_unknown');
    }
  }
}
