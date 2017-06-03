//
//  Lox.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-03-18.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

import Foundation

struct Lox {
    static var hadError = false
    static var hadRuntimeError = false
    
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
        
        if hadError { exit(65) }
        if hadRuntimeError { exit(70) }
    }
    
    static func runPrompt() throws {
        while true {
            print("> ", terminator: "")
            guard let line = readLine() else { return }
            run(line)
            hadError = false
        }
    }
    
    static func run(_ source: String) {
        let scanner = Scanner(source)
        let tokens = scanner.scanTokens()
        
        let parser = Parser(tokens)
        let global = Environment()
        
        do {
            for statement in try parser.parse() {
                try statement.execute(environment: global)
            }
        } catch let error as RuntimeError {
            runtimeError(error)
        } catch {
            fatalError("Unexpected error.")
        }
    }
    
    static func error(_ line: Int, _ message: String) {
        report(line, "", message)
    }
    
    static func report(_ line: Int, _ `where`: String, _ message: String) {
        print("[line \(line)] Error\(`where`): \(message)")
        hadError = true
    }
    
    static func error(_ token: Token, _ message: String) {
        if token.type == .EOF {
            report(token.line, " at end", message)
        } else {
            report(token.line, " at '" + token.lexeme + "'", message)
        }
    }
    
    static func runtimeError(_ error: RuntimeError) {
        fputs(error.message + "\n[line " + String(error.token.line) + "]", __stderrp)
        hadRuntimeError = true
    }
}
