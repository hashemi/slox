//
//  Scanner.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-03-18.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

import Foundation

class Scanner {
    private let source: String
    private var tokens: [Token] = []
    
    private var start: String.Index
    private var current: String.Index
    private var line = 1
    
    init(_ source: String) {
        self.source = source
        self.start = source.startIndex
        self.current = source.startIndex
    }
    
    func scanTokens() -> [Token] {
        while (!isAtEnd()) {
            start = current
            scanToken()
        }
        
        tokens.append(Token(.EOF, "", NSNull(), line))
        return tokens
    }
    
    private func isAtEnd() -> Bool {
        return current >= source.endIndex
    }
    
    private func scanToken() {
        let c = advance()
        switch (c) {
        case "(": addToken(.LEFT_PAREN)
        case ")": addToken(.RIGHT_PAREN)
        case "{": addToken(.LEFT_BRACE)
        case "}": addToken(.RIGHT_BRACE)
        case ",": addToken(.COMMA)
        case ".": addToken(.DOT)
        case "-": addToken(.MINUS)
        case "+": addToken(.PLUS)
        case ";": addToken(.SEMICOLON)
        case "*": addToken(.STAR)
        case "!": addToken(match("=") ? .BANG_EQUAL : .BANG)
        case "=": addToken(match("=") ? .EQUAL_EQUAL : .EQUAL)
        case "<": addToken(match("=") ? .LESS_EQUAL : .LESS)
        case ">": addToken(match("=") ? .GREATER_EQUAL : .GREATER)
        case "\"": string()
            
        case "/":
            if match("/") {
                while (peek() != "\n" && !isAtEnd()) { let _ = advance() }
            } else {
                addToken(.SLASH)
            }
            
        // Ignore whitespace.
        case " ": break
        case "\r": break
        case "\t": break
            
        case "\n": line += 1
            
        default:
            if isDigit(c) {
                number()
            } else if isAlpha(c) {
                identifier()
            } else {
                Lox.error(line, "Unexpected character.")
            }
        }
    }
    
    private static let keywords: [String: TokenType] = [
        "and": .AND,
        "class": .CLASS,
        "else": .ELSE,
        "false": .FALSE,
        "for": .FOR,
        "fun": .FUN,
        "if": .IF,
        "nil": .NIL,
        "or": .OR,
        "print": .PRINT,
        "return": .RETURN,
        "super": .SUPER,
        "this": .THIS,
        "true": .TRUE,
        "var": .VAR,
        "while": .WHILE
    ]
    
    private func identifier() {
        while (isAlphaNumeric(peek())) { let _ = advance() }
        
        let text = source[start..<current]
        
        let type = Scanner.keywords[text] ?? .IDENTIFIER
        addToken(type)
    }
    
    private func number() {
        while isDigit(peek()) { let _ = advance() }
        
        if peek() == "." && isDigit(peekNext()) {
            // Consume the "."
            let _ = advance()
            
            while isDigit(peek()) { let _ = advance() }
        }
        
        let strvalue = source[start..<current]
        
        addToken(.NUMBER, Double(strvalue)!)
    }
    
    private func string() {
        while (peek() != "\"" && !isAtEnd()) {
            if (peek() == "\n") { line += 1 }
            let _ = advance()
        }
        
        // Unterminated string.
        if (isAtEnd()) {
            Lox.error(line, "Unterminated string.")
            return
        }
        
        // The closing ".
        let _ = advance()
        
        let range = source.index(after: start)..<source.index(before: current)
        let value = source[range]
        addToken(.STRING, value)
    }
    
    private func match(_ expected: Character) -> Bool {
        if isAtEnd() { return false; }
        if source[current] != expected { return false }
        
        current = source.index(after: current)
        return true
    }
    
    private func peek() -> Character {
        if current >= source.endIndex { return "\0" }
        return source[current]
    }
    
    private func peekNext() -> Character {
        let next = source.index(after: current)
        if next >= source.endIndex { return "\0" }
        return source[next]
    }
    
    private func isAlpha(_ c: Character) -> Bool {
        return (c >= "a" && c <= "z") ||
            (c >= "A" && c <= "Z") ||
            c == "_"
    }
    
    private func isDigit(_ c: Character) -> Bool {
        return c >= "0" && c <= "9"
    }
    
    private func isAlphaNumeric(_ c: Character) -> Bool {
        return isAlpha(c) || isDigit(c)
    }
    
    private func advance() -> Character {
        let result = source[current]
        current = source.index(after: current)
        return result
    }
    
    private func addToken(_ type: TokenType) {
        addToken(type, NSNull())
    }
    
    private func addToken(_ type: TokenType, _ literal: Any) {
        let text = source[start..<current]
        tokens.append(Token(type, text, literal, line))
    }
}
