class ToolField {
  final String description;
  final bool isRequired;
  final String? enumValues;
  final String? example;
  final String? jsonKey;

  const ToolField({
    required this.description,
    this.isRequired = false,
    this.enumValues,
    this.example,
    this.jsonKey,
  });
}

class ToolDefinition {
  final String name;
  final String description;

  const ToolDefinition({
    required this.name,
    required this.description,
  });
}