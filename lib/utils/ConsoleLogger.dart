// ignore_for_file: file_names

import 'package:logger/logger.dart';

class ConsoleLogger {
    ///
    /// define this object in a separate logger file then use it anywhere you want
    ///
    static var logger = Logger(
        ///
        /// Use the default LogFilter (-> only log in debug mode)
        ///
        filter: null,
        ///
        /// Use the default LogOutput (-> send everything to console)
        ///
        output: null,
        ///
        /// Use the PrettyPrinter to format and print log
        ///
        printer: PrettyPrinter(
            ///
            /// number of method calls to be displayed
            ///
            methodCount: 2,
            ///
            /// number of method calls if stacktrace is provided
            ///
            errorMethodCount: 8,
            ///
            /// width of the output
            ///
            lineLength: 110,
            ///
            /// Colorful log messages
            ///
            colors: true,
            ///
            /// Print an emoji for each log message
            ///
            printEmojis: false,
            ///
            /// Should each log print contain a timestamp
            ///
            printTime: true,
            ///
            /// to hide the box around the message
            ///
            noBoxingByDefault: true
        ),
    );
}