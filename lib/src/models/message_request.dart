import 'package:flutter_athropic_interface/src/models/block.dart';
import 'package:flutter_athropic_interface/src/models/tool.dart';

enum MessageRoleType {
  user,
  assistant,
}

class MessageRequest {
  final String model;
  final int maxTokens;
  final double temperature;
  final String? systemContext;
  final List<Message> messages;
  final List<Tool> tools;
  final bool enableThinking;

  MessageRequest({this.model = 'claude-sonnet-4-5-20250929', this.maxTokens = 21059, this.temperature = 1, this.systemContext, required this.messages, this.tools = const [], this.enableThinking = true});

  factory MessageRequest.fromJson(Map<String, dynamic> map) {
    List<Message> messages = map[Message.jsonProperty] != null ? (map[Message.jsonProperty] as List<dynamic>).map((map) => Message.fromJson(map)).toList() : [];
    List<Tool> tools = map[Tool.jsonProperty] != null ? (map[Tool.jsonProperty] as List<dynamic>).map((map) => Tool.fromJson(map)).toList() : [];

    return MessageRequest(model: map['model'] ?? '', maxTokens: map['max_tokens'] ?? 0, temperature: map['temperature'] ?? 1, systemContext: map['system'] ?? '', messages: messages, tools: tools, enableThinking: map['thinking'] != null);
  }

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'max_tokens': maxTokens,
      'temperature': temperature,
      if (systemContext != null) ...{
        'system': systemContext,
      },
      Message.jsonProperty: messages.map((e) => e.toJson()).toList(),
      Tool.jsonProperty: tools.map((e) => e.toJson()).toList(),
      if (enableThinking) ...{
        'thinking': {"type": "enabled", "budget_tokens": 16847},
      },
    };
  }
}

class Message {
  static const String jsonProperty = 'messages';

  final MessageRoleType role;
  final MessageContent content;

  Message({required this.role, required this.content});

  factory Message.fromJson(Map<String, dynamic> map) {
    return Message(role: MessageRoleType.values.byName(map['role']), content: MessageContent.fromJson(map[MessageContent.jsonProperty]));
  }

  Map<String, dynamic> toJson() {
    return {'role': role.name, ...content.toJson()};
  }
}

class MessageContent {
  static const String jsonProperty = 'content';

  final List<Block> blocks;

  MessageContent({required this.blocks});

  factory MessageContent.fromJson(Map<String, dynamic> map) {
    final dynamic rawBlocks = map[jsonProperty];
    List<Block> blocks = [];
    if (rawBlocks is List) {
      blocks = rawBlocks.map((b) => Block.fromJson(Map<String, dynamic>.from(b))).toList();
    }

    return MessageContent(blocks: blocks);
  }

  Map<String, dynamic> toJson() {
    return {jsonProperty: blocks.map((b) => b.toJson()).toList()};
  }
}
