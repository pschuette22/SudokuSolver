//
//  Logger.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 12/20/21.
//

import Foundation

enum Logger {
    enum Level {
        case debug
        case warning
        case error
        
        var prefix: String {
            switch self {
            case .debug:
                return "Debug"
            case .warning:
                return "Warning"
            case .error:
                return "Error"
            }
        }
    }
    
    static func log(
        _ level: Level,
        file: String = #file,
        line: Int = #line,
        message: String,
        params: [String: Any]? = nil
    ) {
        let simpleFile = file.components(separatedBy: "/").last ?? file
        #if DEBUG
        var message = "[\(simpleFile) line \(line)] " + level.prefix + " - " + message
        if let params = params, !params.isEmpty {
            message += "\n"
            message += "\(params)"
        }
        NSLog(message)
        
        if case .error = level {
            assertionFailure("\(file) [\(line)]: " + message)
        }
        #endif
    }
    
    static func log(
        error: Error,
        file: String = #file,
        line: Int = #line,
        params: [String: Any]? = nil
    ) {
        self.log(.error, file: file, line: line, message: error.localizedDescription, params: params)
    }
}
