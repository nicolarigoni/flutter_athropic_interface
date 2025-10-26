import 'dart:convert';

import 'package:flutter_athropic_interface/flutter_athropic_interface.dart';
import 'package:flutter_athropic_interface/src/models/completion_type.dart';
import 'package:flutter_athropic_interface/src/models/content_type.dart';

enum StopReasonType {
  endTurn('end_turn', 'the model reached a natural stopping point', false),
  maxToken('max_tokens', 'we exceeded the requested max_tokens or the model\'s maximum', true),
  stopSequence('stop_sequence', 'one of your provided custom stop_sequences was generated', false),
  toolUse('tool_use', 'the model invoked one or more tools', false),
  pauseturn('pause_turn', 'we paused a long-running turn. You may provide the response back as-is in a subsequent request to let the model continue', true),
  refusal('refusal', 'when streaming classifiers intervene to handle potential policy violations', true),
  error('', '', true);

  final String jsonProperty;
  final String description;
  final bool isError;

  const StopReasonType(this.jsonProperty, this.description, this.isError);

  static StopReasonType fromJsonProperty(String value) {
    return StopReasonType.values.firstWhere((e) => e.jsonProperty == value);
  }
}

class CompletionResponseDto {
  final String id;
  final CompletionType type;
  final ErrorData? error;
  final MessageRoleType role;
  final String model;
  List<ContentData> content;
  final StopReasonType stopReason;
  final String? stopSequence;
  final UsageData? usage;

  CompletionResponseDto(
    this.id,
    this.type,
    this.error,
    this.role,
    this.model,
    this.content,
    this.stopReason,
    this.stopSequence,
    this.usage,
  );

  factory CompletionResponseDto.fromService(Map<String, dynamic> map) {
    List<ContentData> content = map[ContentData.jsonProperty] != null ? (map[ContentData.jsonProperty] as List<dynamic>).map((map) => ContentData.fromService(map)).toList() : [];
    return CompletionResponseDto(
      map['id'] ?? '',
      CompletionType.values.byName(map['type']),
      map[ErrorData.jsonProperty] != null ? ErrorData.fromService(map[ErrorData.jsonProperty]) : null,
      MessageRoleType.values.byName(map['role'] ?? ''),
      map['model'] ?? '',
      content,
      StopReasonType.fromJsonProperty(map['stop_reason'] ?? ''),
      map['stop_sequence'],
      map[UsageData.jsonProperty] != null ? UsageData.fromService(map[UsageData.jsonProperty]) : null,
    );
  }
}

class ContentData {
  static const String jsonProperty = 'content';

  final ContentType type;
  final String thinking;
  final String signature;
  final String id;
  final String name;
  final String text;
  final InputData? input;

  ContentData(
    this.type,
    this.thinking,
    this.signature,
    this.id,
    this.name,
    this.text,
    this.input,
  );

  factory ContentData.fromService(Map<String, dynamic> map) {
    return ContentData(
      ContentType.fromJsonProperty(map['type']),
      map['thinking'] ?? '',
      map['signature'] ?? '',
      map['id'] ?? '',
      map['name'] ?? '',
      map['text'] ?? '',
      map[InputData.jsonProperty] != null ? InputData.fromService(map[InputData.jsonProperty]) : null,
    );
  }
}

class InputData {
  static const String jsonProperty = 'input';

  final Map<String, dynamic> arguments;

  InputData(
    this.arguments,
  );

  factory InputData.fromService(Map<String, dynamic> map) {
    return InputData(
      map['arguments'] != null ? jsonDecode(map['arguments']) : {},
    );
  }
}

class UsageData {
  static const String jsonProperty = 'usage';

  final int inputTokens;
  final int cacheCreationInputTokens;
  final int cacheReadInputTokens;
  final int outputTokens;

  UsageData(
    this.inputTokens,
    this.cacheCreationInputTokens,
    this.cacheReadInputTokens,
    this.outputTokens,
  );

  factory UsageData.fromService(Map<String, dynamic> map) {
    return UsageData(
      int.tryParse(map['input_tokens'].toString()) ?? 0,
      int.tryParse(map['cache_creation_input_tokens'].toString()) ?? 0,
      int.tryParse(map['cache_read_input_tokens'].toString()) ?? 0,
      int.tryParse(map['output_tokens'].toString()) ?? 0,
    );
  }
}

class ErrorData {
  static const String jsonProperty = 'error';

  final String type;
  final String message;

  ErrorData(
    this.type,
    this.message,
  );

  factory ErrorData.fromService(Map<String, dynamic> map) {
    return ErrorData(
      map['type'] ?? '',
      map['message'] ?? '',
    );
  }
}
