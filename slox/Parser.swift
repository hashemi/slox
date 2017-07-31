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
        if match(.FOR) {
            return try forStatement()
        }
        
        if match(.IF) {
            return try ifStatement()
        }
        
        if match(.PRINT) {
            return try printStatement()
        }
        
        if match(.WHILE) {
            return try whileStatement()
        }
        
        if match(.LEFT_BRACE) {
            return .block(statements: try block())
        }
        
        return try expressionStatement()
    }
    
    private func forStatement() throws -> Stmt {
        try consume(.LEFT_PAREN, "Expect '(' after 'for'.")
        
        var initializer: Stmt?
        if match(.SEMICOLON) {
            initializer = nil
        } else if match(.VAR) {
            initializer = try varDeclaration()
        } else {
            initializer = try expressionStatement()
        }
        
        let condition = check(.SEMICOLON) ? Expr.literal(value: .bool(true)) : try expression()
        try consume(.SEMICOLON, "Expect ';' after loop condition.")
        
        let increment = check(.RIGHT_PAREN) ? nil : try expression()
        try consume(.RIGHT_PAREN, "Expect ')' after for clauses.")
        
        var body = try statement()
        
        if let increment = increment {
            body = .block(statements: [body, .expr(expr: increment)])
        }
        
        body = .while(condition: condition, body: body)
        
        if let initializer = initializer {
            body = .block(statements: [initializer, body])
        }
        
        return body
    }
    
    private func ifStatement() throws -> Stmt {
        try consume(.LEFT_PAREN, "Expect '(' after 'if'.")
        let condition = try expression()
        try consume(.RIGHT_PAREN, "Expect ')' after if condition.")
        
        let thenBranch = try statement()
        let elseBranch = match(.ELSE) ? try statement() : nil
        
        return .if(expr: condition, then: thenBranch, else: elseBranch)
    }
    
    private func printStatement() throws -> Stmt {
        let expr = try expression()
        try consume(.SEMICOLON, "Expect ';' after value.")
        return .print(expr: expr)
    }

    private func varDeclaration() throws -> Stmt {
        let name = try consume(.IDENTIFIER, "Expect variable name.")
        let initializer = match(.EQUAL) ? try expression() : .literal(value: .null)
        try consume(.SEMICOLON, "Expect ';' after variable declaration.")
        return .variable(name: name, initializer: initializer)
    }
    
    private func whileStatement() throws -> Stmt {
        try consume(.LEFT_PAREN, "Expect '(' after 'while'.")
        let condition = try expression()
        try consume(.RIGHT_PAREN, "Expect ')' after condition.")
        let body = try statement()
        
        return .while(condition: condition, body: body)
    }
    
    private func expressionStatement() throws -> Stmt {
        let expr = try expression()
        try consume(.SEMICOLON, "Expect ';' after expression.")
        return .expr(expr: expr)
    }
    
    private func block() throws -> [Stmt] {
        var statements: [Stmt] = []
        
        while !check(.RIGHT_BRACE) && !isAtEnd {
            if let statement = try declaration() {
                statements.append(statement)
            }
        }
        
        try consume(.RIGHT_BRACE, "Expect '}' after block.")
        return statements
    }
    
    private func assignment() throws -> Expr {
        let expr = try or()
        
        
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
    
    private func or() throws -> Expr {
        var expr = try and()
        
        while match(.OR) {
            let op = previous
            let right = try and()
            expr = .logical(left: expr, op: op, right: right)
        }
        
        return expr
    }
    
    private func and() throws -> Expr {
        var expr = try equality()
        
        while match(.AND) {
            let op = previous
            let right = try equality()
            expr = .logical(left: expr, op: op, right: right)
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
        
        return try call()
    }
    
    private func call() throws -> Expr {
        var expr = try primary()
        
        while true {
            if match([.LEFT_PAREN]) {
                expr = try finishCall(expr)
            } else {
                break
            }
        }
        
        return expr
    }
    
    private func finishCall(_ callee: Expr) throws -> Expr {
        var arguments: [Expr] = []
        
        if !check(.RIGHT_PAREN) {
            repeat {
                if arguments.count == 8 {
                    _ = error(peek, "Cannot have more than 8 arguments.")
                }
                arguments.append(try expression())
            } while match(.COMMA)
        }
        
        let paren = try consume(.RIGHT_PAREN, "Expect ')' after arguments.")
        
        return .call(callee: callee, paren: paren, arguments: arguments)
    }
    
    private func primary() throws -> Expr {
        if match(.FALSE) { return .literal(value: .bool(false)) }
        if match(.TRUE) { return .literal(value: .bool(true)) }
        if match(.NIL) { return .literal(value: .null) }
        
        if match([.NUMBER, .STRING]) { return .literal(value: previous.literal) }
        
        if match(.IDENTIFIER) { return .variable(name: previous) }
        
        if match(.LEFT_PAREN) {
            let expr = try expression()
            try consume(.RIGHT_PAREN, "Expect ')' after expression.")
            return .grouping(expr: expr)
        }
        
        throw error(peek, "Expect expression.")
    }
    
    private func match(_ types: [TokenType]) -> Bool {
        for type in types {
            if check(type) {
                advance()
                return true
            }
        }
        
        return false
    }
    
    private func match(_ type: TokenType) -> Bool {
        return match([type])
    }
    
    @discardableResult private func consume(_ type: TokenType, _ message: String) throws -> Token {
        if check(type) { return advance() }
        
        throw error(peek, message)
    }

    private func check(_ tokenType: TokenType) -> Bool {
        if isAtEnd { return false }
        return peek.type == tokenType
    }
    
    @discardableResult private func advance() -> Token {
        if !isAtEnd { current += 1 }
        return previous
    }
    
    private func error(_ token: Token, _ message: String) -> Error {
        Lox.error(token, message)
        return ParseError()
    }
    
    private func synchronize() {
        advance()
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
            default: advance()
            }
        }
    }
}
