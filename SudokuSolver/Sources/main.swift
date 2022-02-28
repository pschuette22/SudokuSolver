////
////  main.swift
////  SudokuSolver
////
////  Created by Schuette, Peter on 12/24/16.
////  Copyright © 2016 Schuette, Peter. All rights reserved.
////
//
//import Foundation
//
//
//// Initialize the board
//var values:[[Int]] = []
//var board: Board
//var start:Date
//var end:Date
//var solveTime:TimeInterval
//
////debugPrint("Easy puzzle")
////values.append([7,0,0,0,0,8,3,5,0])
////values.append([5,0,3,0,0,2,0,1,0])
////values.append([1,0,0,0,3,5,7,0,0])
////values.append([0,0,2,0,8,0,0,9,1])
////values.append([8,0,0,0,2,7,0,6,0])
////values.append([3,9,0,0,0,0,8,0,7])
////values.append([0,0,0,7,0,3,0,8,9])
////values.append([0,0,8,0,5,0,1,0,4])
////values.append([2,0,7,0,0,9,6,0,0])
////
////
////
////board = Board(values: values)
////
////debugPrint("Presolved board")
////board.print()
////
////start = Date()
////// Solve the puzzle
////board.solve()
////end = Date()
////
////solveTime = end.timeIntervalSince(start)
////debugPrint("Solved in \(solveTime) seconds")
////
////// print the result
////board.print()
////
////
////
////values.removeAll()
////debugPrint("Medium puzzle")
////values.append([0,0,6,0,4,0,0,1,7])
////values.append([2,0,0,6,1,0,0,9,0])
////values.append([0,0,0,9,8,0,0,6,0])
////values.append([0,3,0,2,0,0,9,7,0])
////values.append([0,7,0,0,0,0,0,8,0])
////values.append([0,2,4,0,0,9,0,5,0])
////values.append([0,6,0,0,2,5,0,0,0])
////values.append([0,1,0,0,6,4,0,0,8])
////values.append([7,5,0,0,9,0,6,0,0])
////
////
////board = Board(values: values)
////
////debugPrint("Presolved board")
////board.print()
////
////start = Date()
////// Solve the puzzle
////board.solve()
////end = Date()
////
////solveTime = end.timeIntervalSince(start)
////debugPrint("Solved in \(solveTime) seconds")
////
////// print the result
////board.print()
////
////
////
////values.removeAll()
////debugPrint("Expert puzzle")
////values.append([0,0,0,4,0,2,0,3,0])
////values.append([1,8,0,9,0,0,0,0,0])
////values.append([0,0,7,0,3,0,0,0,0])
////values.append([0,1,0,0,0,0,0,2,0])
////values.append([0,0,0,0,6,0,8,0,1])
////values.append([3,0,5,0,0,0,9,0,0])
////values.append([0,0,0,0,0,0,0,0,0])
////values.append([0,7,2,0,0,0,6,9,0])
////values.append([0,9,6,5,4,0,0,0,0])
////
////
////board = Board(values: values)
////
////debugPrint("Presolved board")
////board.print()
////
////start = Date()
////// Solve the puzzle
////board.solve()
////end = Date()
////
////solveTime = end.timeIntervalSince(start)
////debugPrint("Solved in \(solveTime) seconds")
////
////// print the result
////board.print()
////
////
////
////
////values.removeAll()
////debugPrint("Another Expert puzzle")
////values.append([0,1,0,0,0,0,4,7,0])
////values.append([0,0,5,0,0,0,0,0,3])
////values.append([3,8,0,6,0,0,0,0,0])
////values.append([0,0,4,0,9,5,0,0,0])
////values.append([0,0,0,4,0,0,0,2,0])
////values.append([0,0,0,0,1,0,3,0,8])
////values.append([0,0,0,0,0,0,0,0,0])
////values.append([0,0,0,9,7,0,0,6,1])
////values.append([0,6,1,0,0,0,0,5,2])
////
////
////board = Board(values: values)
////
////debugPrint("Presolved board")
////board.print()
////
////start = Date()
////// Solve the puzzle
////board.solve()
////end = Date()
////
////solveTime = end.timeIntervalSince(start)
////debugPrint("Solved in \(solveTime) seconds")
////
////// print the result
////board.print()
//
////values.removeAll()
////debugPrint("Expert puzzle")
////values.append([7,0,2,0,0,1,4,0,0])
////values.append([0,0,8,0,0,6,0,3,0])
////values.append([0,1,0,0,0,0,0,0,9])
////values.append([0,0,0,0,1,2,0,5,0])
////values.append([0,2,0,0,0,0,0,7,0])
////values.append([0,4,0,5,7,0,0,0,0])
////values.append([3,0,0,0,0,0,0,2,0])
////values.append([0,7,0,6,0,0,5,0,0])
////values.append([0,0,5,3,0,0,6,0,8])
////
////
////board = Board(values: values)
////
////debugPrint("Presolved board")
////board.print()
////
////start = Date()
////// Solve the puzzle
////board.solve()
////end = Date()
////
////solveTime = end.timeIntervalSince(start)
////debugPrint("Solved in \(solveTime) seconds")
////
////// print the result
////board.print()
////
////
////values.removeAll()
////debugPrint("unsolvable Expert puzzle")
////values.append([0,0,8,0,0,0,5,0,0])
////values.append([0,7,0,4,0,6,0,8,0])
////values.append([3,0,0,0,0,0,0,0,6])
////values.append([0,0,4,8,0,2,7,0,0])
////values.append([5,0,0,0,0,0,0,0,3])
////values.append([0,0,1,5,0,4,2,0,0])
////values.append([1,0,0,0,0,0,0,0,5])
////values.append([0,5,0,3,0,9,0,2,0])
////values.append([0,0,6,0,0,0,9,0,0])
////
////
////board = Board(values: values)
////
////debugPrint("Presolved board")
////board.print()
////
////start = Date()
////// Solve the puzzle
////board.solve()
////end = Date()
////
////solveTime = end.timeIntervalSince(start)
////debugPrint("Solved in \(solveTime) seconds")
////
//// print the resul
////board.print()
//
//values.removeAll()
//debugPrint("Expert puzzle")
//values.append([0,0,3,0,8,1,0,0,9])
//values.append([2,0,0,0,0,0,0,0,8])
//values.append([1,9,0,0,5,0,0,0,0])
//values.append([0,2,6,0,0,0,0,0,0])
//values.append([0,0,1,8,0,5,3,0,0])
//values.append([0,0,0,0,0,0,5,6,0])
//values.append([0,0,0,0,1,0,0,9,5])
//values.append([4,0,0,0,0,0,0,0,3])
//values.append([7,0,0,2,3,0,4,0,0])
//
//
//board = Board(values: values)
//
//debugPrint("Presolved board")
//board.print()
//
//start = Date()
//// Solve the puzzle
//board.solve()
//end = Date()
//
//solveTime = end.timeIntervalSince(start)
//debugPrint("Solved in \(solveTime) seconds")
//
//// print the result
//board.print()
////
////
////values.removeAll()
////debugPrint("Expert puzzle")
////values.append([0,0,4,9,7,0,2,3,5])
////values.append([5,3,0,0,0,0,0,0,0])
////values.append([0,0,0,0,0,0,0,9,8])
////values.append([0,6,0,0,2,5,0,0,0])
////values.append([4,0,0,0,0,0,0,0,1])
////values.append([0,0,0,6,4,0,0,5,0])
////values.append([6,7,0,0,0,0,0,0,0])
////values.append([0,0,0,0,0,0,0,1,9])
////values.append([1,9,2,0,5,4,8,0,0])
////
////
////board = Board(values: values)
////
////debugPrint("Presolved board")
////board.print()
////
////start = Date()
////// Solve the puzzle
////board.solve()
////end = Date()
////
////solveTime = end.timeIntervalSince(start)
////debugPrint("Solved in \(solveTime) seconds")
////
////// print the result
////board.print()
//
//
