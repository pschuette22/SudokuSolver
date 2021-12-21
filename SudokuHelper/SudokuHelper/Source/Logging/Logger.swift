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
    
    static func log(_ level: Level, message: String, params: [String: Any]? = nil) {
        
        #if DEBUG
        var message = level.prefix + " - " + message
        if let params = params, !params.isEmpty {
            message += "\n"
            message += "\(params)"
        }
        NSLog(message)
        
        if case .error = level {
            assertionFailure()
        }
        #endif
    }
}
