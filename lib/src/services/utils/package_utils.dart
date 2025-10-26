import 'dart:io';

import 'package:flutter_athropic_interface/flutter_athropic_interface.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

enum LogType {
  info('\x1B[37m', 'ANTROPIC INSTANCE INFO |'),
  error('\x1B[31m', 'ANTROPIC INSTANCE ERROR |');

  final String logColor;
  final String logHeader;

  const LogType(this.logColor, this.logHeader);
}

class PackageUtils {
  static final _dateFormat = DateFormat('yyyy-MM-dd hh:mm');

  static const Duration serviceTimeout = Duration(minutes: 2);

  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String logFileName(String prefix) {
    return '${prefix}_athropic_logs.json';
  }

  static Future writeLogToFile({required String logFileName, required String log}) async {
    if (AthropicInterface.instance.saveLogsDirectory case var directory?) {
      if (!await directory.exists()) {
        await directory.create();
      }
      final logFile = File(join(directory.path, logFileName));
      if (!await logFile.exists()) {
        await logFile.create();
      }
      logFile.writeAsString(log);
    }
  }

  static void writeConsoleLog(LogType logType, String tag, String message) {
    const reset = '\x1B[0m';
    String log = '${logType.logHeader} $tag (${formatDate(DateTime.now())}) $message';

    print('${logType.logColor}$log$reset');
  }
}
