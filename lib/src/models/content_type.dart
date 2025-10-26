enum ContentType {
  text('text'),
  image('image'),
  document('document'),
  thinking('thinking'),
  toolUse('tool_use'),
  toolResult('tool_result');

  final String jsonProperty;

  const ContentType(this.jsonProperty);

  static ContentType fromJsonProperty(String value) {
    return ContentType.values.firstWhere((e) => e.jsonProperty == value);
  }
}