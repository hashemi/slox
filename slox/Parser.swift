//
//  Parser.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-03-21.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

class Parser {
    private struct ParseError: Error {}

    let tokens: [Token]
    var current = 0
    
    private var isAtEnd: Bool {
        return peek.type == .EOF
    }
    
    private var peek: Token {
        return tokens[current]
    }
    
    private var previous: Token {
        return tokens[current - 1]
    }
    
    init(_ tokens: [Token]) {
        self.tokens = tokens
    }
    
    func parse() throws -> [Stmt] {
        var statements: [Stmt] = []
        
        while !isAtEnd {
            if let statement = try declaration() {
                statements.append(statement)
            }
        }
        
        return statements
    }
    
    private func expression() throws -> Expr {
        return try assignment()
    }
    
    private func declaration() throws -> Stmt? {
        do {
            if match(.VAR) {
                return try varDeclaration()
            }
            
            return try statement()
        } catch is ParseError {
            synchronize()
            return nil
        }
    }
    
    private func statement() throws -> Stmt {
        if match(.PRINT) {
            return try printStatement()
        }
        
        if match(.LEFT_BRACE) {
            return .block(statements: try block())
        }
        
        return try expressionStatement()
    }
    
    private func printStatement() throws -> Stmt {
        let expr = try expression()
        _ = try consume(.SEMICOLON, "Expect ';' after value.")
        return .print(expr: expr)
    }

    private func varDeclaration() throws -> Stmt {
        let name = try consume(.IDENTIFIER, "Expect variable name.")
        let initializer = match(.EQUAL) ? try expression() : .literal(value: .null)
        _ = try consume(.SEMICOLON, "Expect ';' after variable declaration.")
        return .variable(name: name, initializer: initializer)
    }
    
    private func expressionStatement() throws -> Stmt {
        let expr = try expression()
        _ = try consume(.SEMICOLON, "Expect ';' after expression.")
        return .expr(expr: expr)
    }
    
    private func block() throws -> [Stmt] {
        var statements: [Stmt] = []
        
        while !check(.RIGHT_BRACE) && !isAtEnd {
            if let statement = try declaration() {
                statements.append(statement)
            }
        }
        
        _ = try consume(.RIGHT_BRACE, "Expect '}' after block.")
        return statements
    }
    
    private func assignment() throws -> Expr {
        let expr = try equality()
        
        if match(.EQUAL) {
            let equals = previous
            let value = try assignment()
            
            if case let .variable(name) = expr {
                return .assign(name: name, value: value)
            }
            
            throw error(equals, "Invalid assignment target.")
        }
        
        return expr
    }
    
    private func equality() throws -> Expr {
        var expr = try comparison()
        
        while match([.BANG_EQUAL, .EQUAL_EQUAL]) {
            let op = previous
            let right = try comparison()
            expr = .binary(left: expr, op: op, right: right)
        }
        
        return expr
    }
    
    private func comparison() throws -> Expr {
        var expr = try term()
        
        while match([.GREATER, .GREATER_EQUAL, .LESS, .LESS_EQUAL]) {
            let op = previous
            let right = try term()
            expr = .binary(left: expr, op: op, right: right)
        }
        
        return expr
    }
    
    private func term() throws -> Expr {
        var expr = try factor()
        
        while match([.MINUS, .PLUS]) {
            let op = previous
            let right = try factor()
            expr = .binary(left: expr, op: op, right: right)
        }
        
        return expr
    }
    
    private func factor() throws -> Expr {
        var expr = try unary()
        
        while match([.SLASH, .STAR]) {
            let op = previous
            let right = try unary()
            expr = .binary(left: expr, op: op, right: right)
        }
        
        return expr
    }
    
    private func unary() throws -> Expr {
        if match([.BANG, .MINUS]) {
            let op = previous
            let right = try unary()
            return .unary(op: op, right: right)
        }
        
        return try primary()
    }
    
    private func primary() throws -> Expr {
        if match(.FALSE) { return .literal(value: .bool(false)) }
        if match(.TRUE) { return .literal(value: .bool(true)) }
        if match(.NIL) { return .literal(value: .null) }
        
        if match([.NUMBER, .STRING]) { return .literal(value: previous.literal) }
        
        if match(.IDENTIFIER) { return .variable(name: previous) }
        
        if match(.LEFT_PAREN) {
            let expr = try expression()
            _ = try consume(.RIGHT_PAREN, "Expect ')' after expression.")
            return .grouping(expr: expr)
        }
        
        throw error(peek, "Expected expression.")
    }
    
    private func match(_ types: [TokenType]) -> Bool {
        for type in types {
            if check(type) {
                _ = advance()
                return true
            }
        }
        
        return false
    }
    
    private func match(_ type: TokenType) -> Bool {
        return match([type])
    }
    
    private func consume(_ type: TokenType, _ message: String) throws -> Token {
        if check(type) { return advance() }
        
        throw error(peek, message)
    }

    private func check(_ tokenType: TokenType) -> Bool {
        if isAtEnd { return false }
        return peek.type == tokenType
    }
    
    private func advance() -> Token {
        if !isAtEnd { current += 1 }
        return previous
    }
    
    private func error(_ token: Token, _ message: String) -> Error {
        Lox.error(token, message)
        return ParseError()
    }
    
    private func synchronize() {
        _ = advance()
        while !isAtEnd {
            if (previous.type == .SEMICOLON) { return }
            
            switch (peek.type) {
            case .CLASS: fallthrough
            case .FUN: fallthrough
            case .VAR: fallthrough
            case .FOR: fallthrough
            case .IF: fallthrough
            case .WHILE: fallthrough
            case .PRINT: fallthrough
            case .RETURN: return
            default: _ = advance()
            }
        }
    }
}
