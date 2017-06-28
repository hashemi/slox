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
        while (!isAtEnd) {
            start = current
            scanToken()
        }
        
        tokens.append(Token(.EOF, "", .null, line))
        return tokens
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
                while (peek != "\n" && !isAtEnd) { advance() }
            } else {
                addToken(.SLASH)
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
        
        let type = TokenType(keyword: currentText) ?? .IDENTIFIER
        addToken(type)
    }
    
    private func number() {
        while peek.isDigit { advance() }
        
        if peek == "." && peekNext.isDigit {
            // Consume the "."
            advance()
            
            while peek.isDigit { advance() }
        }
        
        addToken(.NUMBER, .number(Double(currentText)!))
    }
    
    private func string() {
        while (peek != "\"" && !isAtEnd) {
            if (peek == "\n") { line += 1 }
            advance()
        }
        
        // Unterminated string.
        if (isAtEnd) {
            Lox.error(line, "Unterminated string.")
            return
        }
        
        // The closing ".
        advance()
        
        let range = source.index(after: start)..<source.index(before: current)
        let value = source[range]
        addToken(.STRING, .string(String(value)))
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
