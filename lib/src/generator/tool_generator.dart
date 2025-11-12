import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:flutter_athropic_interface/flutter_athropic_interface.dart';
import 'package:source_gen/source_gen.dart';

const toolDefinitionChecker = TypeChecker.fromRuntime(ToolDefinition);
const toolFieldChecker = TypeChecker.fromRuntime(ToolField);

class ToolGenerator extends GeneratorForAnnotation<ToolDefinition> {
  String _escapeString(String str) {
    return str.replaceAll("\\", "\\\\").replaceAll("'", "\\'");
  }

  Map<String, dynamic> _schemaForDartType(DartType dartType, {String description = ''}) {
    final nullableStripped = dartType.getDisplayString(withNullability: false);
    final Map<String, dynamic> schema = {};

    final element = dartType.element;
    if (element is EnumElement) {
      schema['type'] = 'string';
      if (description.isNotEmpty) {
        schema['description'] = description;
      }
      schema['enum'] = element.fields.where((f) => f.isEnumConstant).map((f) => f.name).toList();
      return schema;
    }

    if (nullableStripped.startsWith('List<') || nullableStripped.startsWith('Iterable<') || nullableStripped.startsWith('Set<')) {
      if (dartType is InterfaceType && dartType.typeArguments.isNotEmpty) {
        schema['type'] = 'array';
        if (description.isNotEmpty) {
          schema['description'] = description;
        }
        schema['items'] = _schemaForDartType(dartType.typeArguments.first);
        return schema;
      } else {
        schema['type'] = 'array';
        if (description.isNotEmpty) {
          schema['description'] = description;
        }
        schema['items'] = {'type': 'string'};
        return schema;
      }
    }

    if (nullableStripped.startsWith('Map<')) {
      schema['type'] = 'object';
      if (description.isNotEmpty) {
        schema['description'] = description;
      }
      return schema;
    }

    if (nullableStripped == 'String') {
      schema['type'] = 'string';
      if (description.isNotEmpty) {
        schema['description'] = description;
      }
      return schema;
    }
    if (nullableStripped == 'int') {
      schema['type'] = 'integer';
      if (description.isNotEmpty) {
        schema['description'] = description;
      }
      return schema;
    }
    if (nullableStripped == 'double' || nullableStripped == 'num') {
      schema['type'] = 'number';
      if (description.isNotEmpty) {
        schema['description'] = description;
      }
      return schema;
    }
    if (nullableStripped == 'bool') {
      schema['type'] = 'boolean';
      if (description.isNotEmpty) {
        schema['description'] = description;
      }
      return schema;
    }

    if (element is ClassElement || element is InterfaceElement) {
      final classElement = element as ClassElement;
      schema['type'] = 'object';
      if (description.isNotEmpty) {
        schema['description'] = description;
      }

      final props = <String, dynamic>{};
      final required = <String>[];

      for (final f in classElement.fields) {
        if (f.isPrivate || f.isStatic || f.isSynthetic) continue;
        final fieldSnake = _camelToSnakeCase(f.name);
        String? description;
        bool isRequired = false;

        final ann = toolFieldChecker.firstAnnotationOf(f);
        if (ann != null && ann.type.toString() == 'ToolField') {
          final reader = ConstantReader(ann);
          if (!reader.read('description').isNull) {
            description = reader.read('description').stringValue; //_escapeString(reader.read('description').stringValue);
          }
          if (!reader.read('isRequired').isNull) {
            isRequired = reader.read('isRequired').boolValue;
          }

          final fieldSchema = _schemaForDartType(f.type, description: description ?? '');
          props[fieldSnake] = fieldSchema;
          if (isRequired) required.add(fieldSnake);
        }
      }

      final classSchema = <String, dynamic>{
        'type': 'object',
        if (description.isNotEmpty) ...{
          'description': description,
        },
        'properties': props,
      };
      if (required.isNotEmpty) classSchema['required'] = required;
      return classSchema;
    }

    schema['type'] = 'string';
    if (description.isNotEmpty) {
      schema['description'] = description;
    }
    return schema;
  }

  @override
  String generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError('ToolDefinition can only be used on classes', element: element);
    }

    final toolName = annotation.read('name').stringValue;
    final toolDescription = _escapeString(annotation.read('description').stringValue);
    annotation.read('description').stringValue;

    final Map<String, dynamic> properties = {};
    final List<String> requiredFields = [];

    for (final field in element.fields) {
      if (field.isPrivate) continue;

      final fieldAnnotation = toolFieldChecker.firstAnnotationOf(field);
      if (fieldAnnotation == null) continue;

      if (fieldAnnotation.type.toString() == 'ToolField' || fieldAnnotation.type.toString() == 'ToolDefinition') {
        final DartType fieldType = field.type;

        final fieldReader = ConstantReader(fieldAnnotation);
        final description = fieldReader.read('description').stringValue; //_escapeString(fieldReader.read('description').stringValue);
        final isRequired = fieldReader.read('isRequired').boolValue;

        final fieldSchema = _schemaForDartType(field.type, description: description);

        List<String>? enumOptions;

        /// Se il tipo è un enum, estrai tutti i valori
        if (fieldType.element is EnumElement) {
          final enumElement = fieldType.element as EnumElement;
          enumOptions = enumElement.fields.where((f) => f.isEnumConstant).map((f) => f.name).toList();
        }
        final example = fieldReader.read('example').isNull ? null : fieldReader.read('example').stringValue;

        final fieldSnakeCase = _camelToSnakeCase(field.name);

        // properties[fieldSnakeCase] = _buildPropertySchema(
        //   field.type.toString(),
        //   description,
        //   enumOptions,
        //   example,
        // );

        // if (description.isNotEmpty) {
        //   fieldSchema['description'] = description;
        // }
        if (example != null) {
          fieldSchema['example'] = example;
        }
        if (enumOptions != null && enumOptions.isNotEmpty) {
          fieldSchema['enum'] = enumOptions;
        }

        properties[fieldSnakeCase] = fieldSchema;

        if (isRequired) {
          requiredFields.add(fieldSnakeCase);
        }
      }
    }

    // Costruisci lo schema completo con type: object
    final schema = <String, dynamic>{
      'type': 'object',
      'properties': properties,
      if (requiredFields.isNotEmpty) 'isRequired': requiredFields,
    };

    // Genera il file .g.dart
    final className = element.name;
    final buffer = StringBuffer();

    bool _isDartCoreClass(ClassElement ce) {
      final lib = ce.library;

      return lib.isDartCore;
    }

    String _firstCharToLowerCase(String text) {
      if (text.isEmpty) return text;
      return text[0].toLowerCase() + text.substring(1);
    }

    final lowecasedClassName = _firstCharToLowerCase(className);

    /// FACTORY
    void _collectNestedClassElements(ClassElement root, Set<ClassElement> out) {
      // visita DFS
      void visitClass(ClassElement ce) {
        if (out.contains(ce)) return;
        // skip dart core classes (String/int/...)
        if (_isDartCoreClass(ce)) return;
        out.add(ce);

        for (final f in ce.fields) {
          if (f.isPrivate || f.isStatic || f.isSynthetic) continue;
          final DartType ft = f.type;
          // se è una List<T>
          if (ft is InterfaceType && ft.element.library.isDartCore && ft.element.name == 'List' && ft.typeArguments.isNotEmpty) {
            final inner = ft.typeArguments.first;
            final innerElement = inner.element;
            if (innerElement is ClassElement && !_isDartCoreClass(innerElement)) {
              visitClass(innerElement);
            }
          } else {
            final el = ft.element;
            if (el is ClassElement && !_isDartCoreClass(el)) {
              visitClass(el);
            }
          }
        }
      }

      visitClass(root);
    }

    final classesToGenerate = <ClassElement>{};
    _collectNestedClassElements(element, classesToGenerate);
    final sortedClasses = classesToGenerate.toList()..sort((a, b) => a.name.compareTo(b.name));

    String _expressionForDartType(DartType type, String snakeName, FieldElement field) {
      // rilevo nullability
      final isNullable = type.nullabilitySuffix == NullabilitySuffix.question;

      // helper per wrap null check (usato per oggetti e liste)
      String wrapNull(String inner) {
        if (isNullable) {
          return "json['$snakeName'] == null ? null : $inner";
        } else {
          return inner;
        }
      }

      // PRIMITIVI
      if (type.isDartCoreString) {
        return isNullable ? "json['$snakeName']" : "json['$snakeName'] ?? ''";
      }
      if (type.isDartCoreInt) {
        return isNullable ? "int.tryParse(json['$snakeName'].toString())" : "int.tryParse(json['$snakeName'].toString() ?? '') ?? -1";
      }
      if (type.isDartCoreBool) {
        return isNullable ? "json['$snakeName']" : "json['$snakeName'] ?? false";
      }
      if (type.isDartCoreDouble) {
        // possibile che arrivi int => trattiamo con num.toDouble()
        return isNullable ? "double.tryParse(json['$snakeName'].toString())" : "double.tryParse(json['$snakeName'].toString() ?? '') ?? -1.0";
      }

      // ENUM
      if (type.element is EnumElement) {
        final enumType = type.getDisplayString(withNullability: false);
        // EN-A style (multiline firstWhere with orElse => implementato con where() per poter restituire null se non trovato)
        // restituisce Role? e se il campo originario non è nullable aggiungo '!' per forzare comportamento
        final baseExpr = "(() { final _v = json['$snakeName'] as String?; if (_v == null) return null; final _m = $enumType.values.where((e) => e.name == _v); return _m.isEmpty ? null : _m.first; })()";
        if (isNullable) {
          return baseExpr;
        } else {
          // campo non-nullable: aggiungo '!' per forzare l'assegnazione (runtime error se non presente)
          return '$baseExpr!';
        }
      }

      // LIST<T>
      if (type is InterfaceType && type.element.library.isDartCore && type.element.name == 'List') {
        if (type.typeArguments.isEmpty) {
          // generico list
          final inner = "e";
          final listExpr = "(json['$snakeName'] as List).map((e) => $inner).toList()";
          return wrapNull(listExpr);
        } else {
          final innerType = type.typeArguments.first;
          // primitive inner
          if (innerType.isDartCoreString) {
            final listExpr = "(json['$snakeName'] as List).map((e) => e as String).toList()";
            return wrapNull(listExpr);
          }
          if (innerType.isDartCoreInt) {
            final listExpr = "(json['$snakeName'] as List).map((e) => e as int).toList()";
            return wrapNull(listExpr);
          }
          if (innerType.isDartCoreDouble) {
            final listExpr = "(json['$snakeName'] as List).map((e) => (e as num).toDouble()).toList()";
            return wrapNull(listExpr);
          }
          if (innerType.isDartCoreBool) {
            final listExpr = "(json['$snakeName'] as List).map((e) => e as bool).toList()";
            return wrapNull(listExpr);
          }
          if (innerType.element is EnumElement) {
            final enumType = innerType.getDisplayString(withNullability: false);
            final listExpr = "(json['$snakeName'] as List).map((e) { final _v = e as String?; final _m = $enumType.values.where((x) => x.name == _v); return _m.isEmpty ? null : _m.first; }).toList()";
            // se la lista di enum è per un campo non-nullable List<Enum> (cioè lista di enum non-nullable), l'elemento può essere null:
            // generiamo comunque la lista con elementi null possibili; è responsabilità del consumatore (o aggiungere controlli)
            return wrapNull(listExpr);
          }
          // altrimenti consideriamo innerType un oggetto custom
          final innerName = innerType.getDisplayString(withNullability: false);
          // final listExpr = "(json['$snakeName'] as List).map((e) => ${innerName}JsonFactory.fromJson(e as Map<String, dynamic>)).toList()";
          final listExpr = "json['$snakeName'] != null ? (json['$snakeName'] as List<dynamic>).map((map) => ${innerName}JsonFactory.fromJson(map)).toList() : []";
          return wrapNull(listExpr);
        }
      }

      // MAP o altri tipi generici -> li trattiamo come Map<String, dynamic>
      if (type.isDartCoreMap) {
        return isNullable ? "json['$snakeName'] as Map<String, dynamic>?" : "json['$snakeName'] == null ? {} : json['$snakeName'] as Map<String, dynamic>";
      }

      // OBJECT custom (ClassElement)
      if (type.element is ClassElement) {
        final objectType = type.getDisplayString(withNullability: false);
        final objExpr = "${objectType}JsonFactory.fromJson(json['$snakeName'] as Map<String, dynamic>)";
        return wrapNull(objExpr);
      }

      // fallback generico
      return "json['$snakeName']";
    }

    // --------------------------
    // Genera l'extension con factory fromJson per una singola classe
    // --------------------------
    String _generateFromJsonExtensionForClass(ClassElement cls) {
      final className = cls.name;
      final buffer = StringBuffer();

      buffer.writeln('extension ${className}JsonFactory on $className {');
      buffer.writeln('  static $className fromJson(Map<String, dynamic> json) {');
      buffer.writeln('    return $className(');

      for (final f in cls.fields) {
        if (f.isPrivate || f.isStatic || f.isSynthetic) continue;

        // prendo nome campo e snake_case
        final fieldName = f.name;
        final snake = _camelToSnakeCase(fieldName);

        // costruisco l'espressione di parsing per il tipo del campo
        final expr = _expressionForDartType(f.type, snake, f);
        buffer.writeln('      $fieldName: $expr,');
      }

      buffer.writeln('    );');
      buffer.writeln('  }');
      buffer.writeln('}');

      return buffer.toString();
    }

    /// END
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// This file is generated by tool_generator.dart');
    buffer.writeln('');
    buffer.writeln('part of \'${_camelToSnakeCase(className).toLowerCase()}.dart\';');
    buffer.writeln('');
    const encoder = JsonEncoder.withIndent('  ');
    final prettySchema = encoder.convert(schema);
    buffer.writeln('const String ${lowecasedClassName}ToolSchema = r\'\'\'');
    buffer.writeln(prettySchema);
    buffer.writeln('\'\'\';');
    buffer.writeln('');
    buffer.writeln('const String ${lowecasedClassName}ToolName = \'$toolName\';');
    buffer.writeln('');
    buffer.writeln('const String ${lowecasedClassName}ToolDescription = \'$toolDescription\';');
    buffer.writeln('');
    buffer.writeln('class ${className}Tool {');
    buffer.writeln('  static String get name => ${lowecasedClassName}ToolName;');
    buffer.writeln('  static String get description => ${lowecasedClassName}ToolDescription;');
    buffer.writeln('  static String get schema => ${lowecasedClassName}ToolSchema;');
    buffer.writeln('  static Map<String, dynamic> get tool => {"name": name, "description": description, "input_schema": schema};');
    buffer.writeln('  static Map<String, dynamic> get schemaMap => jsonDecode(schema);');
    buffer.writeln('');
    buffer.writeln('}');
    buffer.writeln('');
    for (final cls in sortedClasses) {
      buffer.writeln(_generateFromJsonExtensionForClass(cls));
      buffer.writeln('');
    }

    return buffer.toString();
  }

  static String _camelToSnakeCase(String camelCase) {
    final buffer = StringBuffer();
    for (int i = 0; i < camelCase.length; i++) {
      final char = camelCase[i];
      if (char == char.toUpperCase() && i > 0) {
        buffer.write('_');
        buffer.write(char.toLowerCase());
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }
}

Builder toolGeneratorBuilder(BuilderOptions options) {
  return LibraryBuilder(ToolGenerator(), generatedExtension: '.tool.g.dart', header: '// GENERATED CODE - DO NOT MODIFY BY HAND\n');
}
