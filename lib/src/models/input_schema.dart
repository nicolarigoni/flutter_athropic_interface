enum FieldType {
  boolean,
  number,
  integer,
  string,
  object,
  array,
}

mixin EnumSchemaMixin {
  String get valueName;
}

// enum Esempio with EnumSchemaMixin {
//   uno,
//   due;

//   @override
//   String get valueName => name;
// }

abstract class InputSchema {
  final String name;
  final String description;
  final bool isRequired;

  InputSchema({
    required this.name,
    required this.description,
    this.isRequired = false,
  });

  Map<String, dynamic> toJson();

  InputSchema copyWith({bool? isRequired});

  static InputSchema fromJson(String name, Map<String, dynamic> map) {
    final type = FieldType.values.byName(map['type']);
    switch (type) {
      case FieldType.string:
      case FieldType.integer:
      case FieldType.number:
      case FieldType.boolean:
        return SimpleField(
          name: name,
          description: map['description'] ?? '',
          type: type,
          isRequired: false,
        );
      case FieldType.object:
        final properties = <InputSchema>[];
        final Map<String, dynamic> propsJson = map['properties'] ?? {};

        for (final entry in propsJson.entries) {
          InputSchema field = InputSchema.fromJson(entry.key, Map<String, dynamic>.from(entry.value));

          final requiredList = (map['required'] as List?)?.map((e) => e as String).toList() ?? [];
          if (requiredList.contains(field.name)) {
            field = field.copyWith(isRequired: true);
          }

          properties.add(field);
        }

        return ObjectField(
          name: name,
          description: map['description'] ?? '',
          properties: properties,
        );
      case FieldType.array:
        final itemField = InputSchema.fromJson('items', Map<String, dynamic>.from(map['items']));
        return ArrayField(
          name: name,
          description: map['description'] ?? '',
          items: itemField,
        );
    }
  }
}

class SimpleField extends InputSchema {
  final FieldType type;

  SimpleField({
    required super.name,
    required super.description,
    super.isRequired,
    required this.type,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'description': description,
    };
  }

  @override
  SimpleField copyWith({bool? isRequired}) {
    return SimpleField(
      name: name,
      description: description,
      type: type,
      isRequired: isRequired ?? this.isRequired,
    );
  }
}

class EnumField<T extends EnumSchemaMixin> extends InputSchema {
  final List<T> allowedValues;

  EnumField({
    required super.name,
    required super.description,
    super.isRequired,
    required this.allowedValues,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': FieldType.string.name,
      'enum': allowedValues.map((v) => v.valueName).toList(),
      'description': description,
    };
  }

  @override
  EnumField<T> copyWith({
    bool? isRequired,
    List<T>? allowedValues,
    String? name,
    String? description,
  }) {
    return EnumField<T>(
      name: name ?? this.name,
      description: description ?? this.description,
      isRequired: isRequired ?? this.isRequired,
      allowedValues: allowedValues ?? this.allowedValues,
    );
  }
}

class ObjectField extends InputSchema {
  final List<InputSchema> properties;

  ObjectField({
    required super.name,
    required super.description,
    super.isRequired,
    required this.properties,
  });

  factory ObjectField.root({
    required List<InputSchema> properties,
  }) {
    return ObjectField(
      name: '',
      description: '',
      properties: properties,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final requiredList = properties.where((field) => field.isRequired).map((field) => field.name).toList();

    return {
      'type': FieldType.object.name,
      if (description.isNotEmpty) ...{
        'description': description,
      },
      if (properties.isNotEmpty) ...{
        'properties': {
          for (final prop in properties) prop.name: prop.toJson(),
        },
      },
      if (requiredList.isNotEmpty) 'required': requiredList,
    };
  }

  @override
  ObjectField copyWith({
    bool? isRequired,
    List<InputSchema>? properties,
  }) {
    return ObjectField(
      name: name,
      description: description,
      isRequired: isRequired ?? this.isRequired,
      properties: properties ?? this.properties,
    );
  }
}

class ArrayField extends InputSchema {
  final InputSchema items;

  ArrayField({
    required super.name,
    required super.description,
    super.isRequired,
    required this.items,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': FieldType.array.name,
      'description': description,
      'items': items.toJson(),
    };
  }

  @override
  ArrayField copyWith({
    bool? isRequired,
    InputSchema? items,
  }) {
    return ArrayField(
      name: name,
      description: description,
      isRequired: isRequired ?? this.isRequired,
      items: items ?? this.items,
    );
  }
}
