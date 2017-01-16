//
//  BoardBuilder.swift
//  SudokuSolver
//
//  Created by Schuette, Peter on 1/3/17.
//  Copyright © 2017 Schuette, Peter. All rights reserved.
//

import Foundation


class BoardBuilder {
    
//    static func build() -> Board? {
//        // Determine if board should be retrieved or entered manually
//        
//        debugPrint("(i)nput or (f)etch puzzle? $> ")
//        if let type = readLine() {
//        
//            switch type {
//            case "i":
//                var values:[[Int]] = []
//                debugPrint("Enter puzzle line-by-line using '0' to denote blank space")
//                
//                for i in 0..<9{
//                    debugPrint("Line \(i): ")
//                    if let line = readLine() {
//                    
//                        var lineValues:[Int] = []
//                        var j = 0
//                        for char in line.characters {
//                            if let value = Int(char) {
//                                lineValues.append(value)
//                            } else {
//                                debugPrint("Warning! Unable to read value, adding zero at \(i),\(j)")
//                            }
//                            
//                            
//                            if j < 8 {
//                                j+=1
//                            } else {
//                                break
//                            }
//                        }
//                    }
//                    
//                }
//                
//                break
//            default:
//                debugPrint("Unrecognized command")
//                break
//            }
//        }
//        
//        return nil
//    }
//    
    
}
