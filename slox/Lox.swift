//
//  Lox.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-03-18.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

import Foundation

class Lox {
    static var hadError = false
    
    static func main(_ args: [String]) throws {
        if args.count > 1 {
            print("Usage: slox [script]")
        } else if args.count == 1 {
            try Lox.runFile(args[0])
        } else {
            try Lox.runPrompt()
        }
    }
    
    static func runFile(_ path: String) throws {
        let bytes = try Data(contentsOf: URL(fileURLWithPath: path))
        run(String(bytes: bytes, encoding: .utf8)!)
        if (hadError) {
            exit(65)
        }
    }
    
    static func runPrompt() throws {
        while true {
            print("> ", terminator: "")
            run(readLine() ?? "")
            hadError = false
        }
    }
    
    static func run(_ source: String) {
        let scanner = Scanner(source)
        let tokens = scanner.scanTokens()
        
        for token in tokens {
            print(token)
        }
    }
    
    static func error(_ line: Int, _ message: String) {
        report(line, "", message)
    }
    
    static func report(_ line: Int, _ `where`: String, _ message: String) {
        print("[line \(line)] Error\(`where`): \(message)")
        hadError = true
    }
}
