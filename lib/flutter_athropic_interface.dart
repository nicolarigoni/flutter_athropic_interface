/// Provides the main entry point to interact with the Athropic API.
///
/// Use this class to initialize the connection to the API and optionally
/// configure a directory to save request/response logs.
///
/// Example usage:
/// ```dart
/// import 'package:flutter_athropic_interface/flutter_athropic_interface.dart';
/// import 'dart:io';
///
/// void main() {
///
///   /* Initialize the API with your key */
///   AthropicInterface.init(
///     apiKey: 'YOUR_API_KEY',
///     saveLogDirectory: Directory('/path/to/logs'), // optional
///   );
///
///   /* Access the instance */
///   final instance = AthropicInterface.instance;
/// }
/// ```
library;

import 'dart:io';

import 'package:flutter_athropic_interface/src/athropic_instance.dart';

export 'src/annotations/annotations.dart';
export 'flutter_athropic_interface.dart';
export 'src/models/message_request.dart';
export 'src/models/block.dart';
export 'src/models/tool.dart';
export 'src/models/input_schema.dart';
export 'src/models/content_type.dart';
export 'src/models/completion_type.dart';


/// Main interface class for Athropic API.
///
/// Provides static methods to initialize and access a singleton
/// [AnthropicInstance] that handles all API interactions.
/// dart run build_runner build --delete-conflicting-outputs
class AthropicInterface {
  static AnthropicInstance? _instance;

  /// Initializes the Athropic API instance.
  ///
  /// [apiKey] The API key used for authentication.
  /// [saveLogDirectory] Optional directory where request and response logs will be saved.
  /// If not provided, logging to disk will be disabled.
  static void init({
    required String apiKey,
    Directory? saveLogDirectory,
  }) async {
    _instance = AnthropicInstance(
      apiKey: apiKey,
      saveLogsDirectory: saveLogDirectory,
    );
  }

  /// Returns the initialized [AnthropicInstance].
  ///
  /// Throws an error if [init] has not been called before accessing this getter.
  static AnthropicInstance get instance {
    if (_instance == null) {
      throw StateError(
        'AthropicInterface not initialized. Call `AthropicInterface.init()` first.',
      );
    }
    return _instance!;
  }
}
