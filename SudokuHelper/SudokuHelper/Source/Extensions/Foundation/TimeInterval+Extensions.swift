//
//  TimeInterval+Extensions.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 3/26/22.
//

import Foundation

extension TimeInterval {
    static func milliseconds(_ milliseconds: Double) -> TimeInterval {
        return milliseconds / 1000
    }
    
    static func seconds(_ seconds: Double) -> TimeInterval {
        return seconds
    }
    
    static func minutes(_ minutes: Double) -> TimeInterval {
        return minutes * 60
    }
    
    static func hours(_ hours: Double) -> TimeInterval {
        return hours * .minutes(60)
    }
    
    static func days(_ days: Double) -> TimeInterval {
        return days * .hours(24)
    }
}
