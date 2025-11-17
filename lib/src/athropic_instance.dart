import 'dart:io';

import 'package:flutter_athropic_interface/src/models/generic_response.dart';
import 'package:flutter_athropic_interface/src/models/message_request.dart';
import 'package:flutter_athropic_interface/src/services/athropic_service.dart';
import 'package:flutter_athropic_interface/src/services/dto/completion_dto.dart';
import 'package:flutter_athropic_interface/src/services/dto/upload_dto.dart';
import 'package:http/http.dart';

class AnthropicInstance {
  final String apiKey;
  final Directory? saveLogsDirectory;

  AnthropicInstance({required this.apiKey, this.saveLogsDirectory});

  Future<GenericResponse<CompletionResponseDto>> sendRequest(MessageRequest messageRequest, {Map<String, String> headers = const {}}) async {
    final result = await AthropicService.sendRequest(messageRequest, headers: headers);
    return result;
  }

  Future<GenericResponse<UploadDto>> uploadFile(String filePath, {MediaType? mediaType}) async {
    final result = await AthropicService.uploadFiles(filePath, mediaType: mediaType);
    return result;
  }

  Future<GenericResponse> deleteFile(String fileId, ) async {
    final result = await AthropicService.deleteFile(fileId);
    return result;
  }
}
