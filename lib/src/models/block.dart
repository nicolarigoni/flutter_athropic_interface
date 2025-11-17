import 'dart:convert';

import 'package:flutter_athropic_interface/src/models/content_type.dart';
import 'package:flutter_athropic_interface/src/services/utils/package_utils.dart';

abstract class Block {
  final ContentType type;

  const Block(this.type);

  Map<String, dynamic> toJson();

  factory Block.fromJson(Map<String, dynamic> map) {
    final type = ContentType.fromJsonProperty(map['type']);
    switch (type) {
      case ContentType.text:
        return TextBlock(text: map['text']);
      case ContentType.image:
        return ImageBlock(base64Source: '');
      case ContentType.document:
        final fileId = map['source']['file_id'] ?? '';
        return DocumentBlock(fileId: fileId);
      case ContentType.toolUse:
        return ToolUseBlock(
          id: map['id'],
          name: map['name'],
          input: map['input'],
        );
      case ContentType.thinking:
        return ThinkingBlock(
          thinking: map['thinking'],
          signature: map['signature'],
        );
      case ContentType.toolResult:
        return ToolResultBlock(
          toolUseId: map['tool_use_id'],
          content: map['content'],
        );
      case ContentType.containerUpload:
        return ContainerUploadBlock(fileId: '');
      default:
        PackageUtils.writeConsoleLog(LogType.error, 'Block', 'ContentType: ${type.name} non implementato');
        return TextBlock(text: '');
    }
  }
}

class TextBlock extends Block {
  final String text;

  TextBlock({required this.text}) : super(ContentType.text);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.jsonProperty,
      'text': text,
    };
  }
}

class ImageBlock extends Block {
  final Map<String, String> source;

  ImageBlock({
    required String base64Source,
  })  : source = {'type': 'base64', 'media_type': 'image/jpeg', 'data': base64Source},
        super(ContentType.image);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.jsonProperty,
      'source': source,
    };
  }
}

// class DocumentBlock extends Block {
//   final Map<String, String> source;

//   DocumentBlock({
//     required String base64Source,
//   })  : source = {'type': 'base64', 'media_type': 'application/json', 'data': base64Source},
//         super(ContentType.document);

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'type': type.jsonProperty,
//       'source': source,
//     };
//   }
// }

class DocumentBlock extends Block {
  final Map<String, dynamic> source;

  DocumentBlock({
    required String fileId,
  })  : source = {'type': 'file', 'file_id': fileId},
        super(ContentType.document);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.jsonProperty,
      'source': source,
    };
  }
}

class ToolUseBlock extends Block {
  final String id;
  final String name;
  final Map<String, dynamic> input;

  ToolUseBlock({
    required this.id,
    required this.name,
    required this.input,
  }) : super(ContentType.toolUse);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.jsonProperty,
      'id': id,
      'name': name,
      'input': input,
    };
  }
}

class ThinkingBlock extends Block {
  final String thinking;
  final String signature;

  ThinkingBlock({
    required this.thinking,
    required this.signature,
  }) : super(ContentType.thinking);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.jsonProperty,
      'thinking': thinking,
      'signature': signature,
    };
  }
}

class ToolResultBlock extends Block {
  final String toolUseId;
  final Map<String, dynamic> content;

  ToolResultBlock({
    required this.toolUseId,
    required this.content,
  }) : super(ContentType.toolResult);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.jsonProperty,
      'tool_use_id': toolUseId,
      'content': jsonEncode(content),
    };
  }
}

class ContainerUploadBlock extends Block {
  final String fileId;

  ContainerUploadBlock({
    required this.fileId,
  }) : super(ContentType.containerUpload);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.jsonProperty,
      'file_id': fileId,
    };
  }
}
