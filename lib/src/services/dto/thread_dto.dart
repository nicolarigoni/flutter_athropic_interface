class ThreadDto {
  final String id;
  final String object;
  final int createdAt;
  final String assistantId;
  final String threadId;
  final String status;

  final RequiredAction? requiredAction;

  final String model;
  final String instructions;

  ThreadDto(
    this.id,
    this.object,
    this.createdAt,
    this.assistantId,
    this.threadId,
    this.status,
    this.requiredAction,
    this.model,
    this.instructions,
  );

  factory ThreadDto.fromService(Map<String, dynamic> map) {
    return ThreadDto(
      map['id'],
      map['object'],
      map['created_at'],
      map['assistant_id'],
      map['thread_id'],
      map['status'],
      map[RequiredAction.jsonProperty] != null ? RequiredAction.fromService(map[RequiredAction.jsonProperty]) : null,
      map['model'],
      map['instructions'],
    );
  }
}

class RequiredAction {
  static const String jsonProperty = 'required_action';
  final String type;
  final SubmitToolOutputs submitToolOutputs;

  RequiredAction(
    this.type,
    this.submitToolOutputs,
  );

  factory RequiredAction.fromService(Map<String, dynamic> map) {
    return RequiredAction(
      map['type'],
      SubmitToolOutputs.fromService(map[SubmitToolOutputs.jsonProperty]),
    );
  }
}

class SubmitToolOutputs {
  static const String jsonProperty = 'submit_tool_outputs';
  final List<ToolCall> toolCalls;

  SubmitToolOutputs(
    this.toolCalls,
  );

  factory SubmitToolOutputs.fromService(Map<String, dynamic> map) {
    return SubmitToolOutputs(
      List<ToolCall>.from(map[ToolCall.jsonProperty].map((e) => ToolCall.fromService(e))),
    );
  }
}

class ToolCall {
  static const String jsonProperty = 'tool_calls';
  final String id;
  final String type;
  final Map<String, dynamic> function;

  ToolCall(
    this.id,
    this.type,
    this.function,
  );

  factory ToolCall.fromService(Map<String, dynamic> map) {
    return ToolCall(
      map['id'],
      map['type'],
      map['function'],
    );
  }
}
