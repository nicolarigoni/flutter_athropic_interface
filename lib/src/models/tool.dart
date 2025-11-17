

enum ToolType {
  custom('custom'),
  codeExecution('code_execution_20250825');

  final String jsonProperty;

  const ToolType(this.jsonProperty);

  static ToolType fromJsonProperty(String value) {
    return ToolType.values.firstWhere((e) => e.jsonProperty == value);
  }
}

abstract class Tool {
  static const String jsonProperty = 'tools';

  ToolType get type;
  String get name;
  String? get description;

  Map<String, dynamic> get inputSchema;

  Map<String, dynamic> toJson();

  static Tool fromJson(Map<String, dynamic> map) {
    final type = ToolType.fromJsonProperty(map['type']);
    switch (type) {
      case ToolType.custom:
        return CustomTool.fromJson(map);
      case ToolType.codeExecution:
        return CodeExecutionTool.fromJson(map);
    }
  }
}

class CustomTool extends Tool {
  @override
  final ToolType type;
  @override
  final String name;
  @override
  final String? description;
  @override
  final Map<String, dynamic> inputSchema;

  CustomTool({required this.name, this.description, required this.inputSchema}) : type = ToolType.custom;

  factory CustomTool.fromJson(Map<String, dynamic> json) {
    return CustomTool(
      name: json['name'],
      description: json['description'],
      inputSchema: json['input_schema'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.jsonProperty,
      'name': name,
      if (description != null) 'description': description,
      'input_schema': inputSchema,
    };
  }
}

class CodeExecutionTool extends Tool {
  @override
  final ToolType type;
  @override
  final String name;
  @override
  final String? description = '';
  @override
  final Map<String, dynamic> inputSchema = {};

  CodeExecutionTool({String? name}) : type = ToolType.codeExecution, name = name ?? 'code_execution';

  factory CodeExecutionTool.fromJson(Map<String, dynamic> json) {
    return CodeExecutionTool(
      name: json['name'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.jsonProperty,
      'name': name,
    };
  }
}
