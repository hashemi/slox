//
//  Scanner.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-03-18.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

extension TokenType {
    init?(keyword: String) {
        let keywords: [String: TokenType] = [
            "and": .and,
            "class": .class,
            "else": .else,
            "false": .false,
            "for": .for,
            "fun": .fun,
            "if": .if,
            "nil": .nil,
            "or": .or,
            "print": .print,
            "return": .return,
            "super": .super,
            "this": .this,
            "true": .true,
            "var": .var,
            "while": .while
        ]
        
        guard let type = keywords[keyword]
            else { return nil }
        
        self = type
    }
}

private extension Character {
    var isAlpha: Bool {
        return
            (self >= "a" && self <= "z") ||
            (self >= "A" && self <= "Z") ||
            self == "_"
    }

    var isDigit: Bool {
        return self >= "0" && self <= "9"
    }

    var isAlphaNumeric: Bool {
        return isAlpha || isDigit
    }
}

class Scanner {
    private let source: String
    private var tokens: [Token] = []
    
    private var start: String.Index
    private var current: String.Index
    private var line = 1
    
    private var currentText: String {
        return String(source[start..<current])
    }

    private var isAtEnd: Bool {
        return current >= source.endIndex
    }
    
    private var peek: Character {
        if current >= source.endIndex { return "\0" }
        return source[current]
    }
    
    private var peekNext: Character {
        let next = source.index(after: current)
        if next >= source.endIndex { return "\0" }
        return source[next]
    }
    
    init(_ source: String) {
        self.source = source
        self.start = source.startIndex
        self.current = source.startIndex
    }
    
    func scanTokens() -> [Token] {
        while !isAtEnd {
            start = current
            scanToken()
        }
        
        tokens.append(Token(.eof, "", .null, line))
        return tokens
    }
    
    private func scanToken() {
        let c = advance()
        switch c {
        case "(": addToken(.leftParen)
        case ")": addToken(.rightParen)
        case "{": addToken(.leftBrace)
        case "}": addToken(.rightBrace)
        case ",": addToken(.comma)
        case ".": addToken(.dot)
        case "-": addToken(.minus)
        case "+": addToken(.plus)
        case ";": addToken(.semicolon)
        case "*": addToken(.star)
        case "!": addToken(match("=") ? .bangEqual : .bang)
        case "=": addToken(match("=") ? .equalEqual : .equal)
        case "<": addToken(match("=") ? .lessEqual : .less)
        case ">": addToken(match("=") ? .greaterEqual : .greater)
        case "\"": string()
            
        case "/":
            if match("/") {
                while peek != "\n" && !isAtEnd { advance() }
            } else {
                addToken(.slash)
            }
            
        // Ignore whitespace.
        case " ": break
        case "\r": break
        case "\t": break
            
        case "\n": line += 1
        
        case _ where c.isDigit: number()
            
        case _ where c.isAlpha: identifier()
        
        default:
            Lox.error(line, "Unexpected character.")
        }
    }
    
    private func identifier() {
        while peek.isAlphaNumeric { advance() }
        
        let type = TokenType(keyword: currentText) ?? .identifier
        addToken(type)
    }
    
    private func number() {
        while peek.isDigit { advance() }
        
        if peek == "." && peekNext.isDigit {
            // Consume the "."
            advance()
            
            while peek.isDigit { advance() }
        }
        
        addToken(.number, .number(Double(currentText)!))
    }
    
    private func string() {
        while peek != "\"" && !isAtEnd {
            if peek == "\n" { line += 1 }
            advance()
        }
        
        // Unterminated string.
        if isAtEnd {
            Lox.error(line, "Unterminated string.")
            return
        }
        
        // The closing ".
        advance()
        
        let range = source.index(after: start)..<source.index(before: current)
        let value = source[range]
        addToken(.string, .string(String(value)))
    }
    
    private func match(_ expected: Character) -> Bool {
        if isAtEnd { return false }
        if source[current] != expected { return false }
        
        current = source.index(after: current)
        return true
    }
    
    @discardableResult private func advance() -> Character {
        let result = source[current]
        current = source.index(after: current)
        return result
    }
    
    private func addToken(_ type: TokenType, _ literal: LiteralValue = .null) {
        tokens.append(Token(type, currentText, literal, line))
    }
}
