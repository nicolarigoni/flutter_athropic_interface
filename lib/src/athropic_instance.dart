import 'dart:io';

import 'package:flutter_athropic_interface/src/models/generic_response.dart';
import 'package:flutter_athropic_interface/src/models/message_request.dart';
import 'package:flutter_athropic_interface/src/services/athropic_service.dart';
import 'package:flutter_athropic_interface/src/services/dto/completion_dto.dart';

class AnthropicInstance {
  final String apiKey;
  final Directory? saveLogsDirectory;

  AnthropicInstance({required this.apiKey, this.saveLogsDirectory});

  Future<GenericResponse<CompletionResponseDto>> sendRequest(MessageRequest messageRequest) async {
    final result = await AthropicService.sendRequest(messageRequest);
    return result;
  }
}
