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
        return peek.type == .eof
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
            if match(.class) {
                return try classDeclaration()
            }
            
            if match(.fun) {
                return try function("function");
            }
            
            if match(.var) {
                return try varDeclaration()
            }
            
            return try statement()
        } catch is ParseError {
            synchronize()
            return nil
        }
    }
    
    private func classDeclaration() throws -> Stmt {
        let name = try consume(.identifier, "Expect class name.")
        
        let superclass: Expr?
        if match(.less) {
            try consume(.identifier, "Expect superclass name.")
            superclass = Expr.variable(name: previous)
        } else {
            superclass = nil
        }
        
        try consume(.leftBrace, "Expect '{' before class body.")
        
        var methods: [Stmt] = []
        while !check(.rightBrace) && !isAtEnd {
            try methods.append(function("method"))
        }
        
        try consume(.rightBrace, "Expect '}' after class body.")
        
        return .class(name: name, superclass: superclass, methods: methods)
    }
    
    private func statement() throws -> Stmt {
        if match(.for) {
            return try forStatement()
        }
        
        if match(.if) {
            return try ifStatement()
        }
        
        if match(.print) {
            return try printStatement()
        }
        
        if match(.return) {
            return try returnStatement()
        }
        
        if match(.while) {
            return try whileStatement()
        }
        
        if match(.leftBrace) {
            return .block(statements: try block())
        }
        
        return try expressionStatement()
    }
    
    private func forStatement() throws -> Stmt {
        try consume(.leftParen, "Expect '(' after 'for'.")
        
        var initializer: Stmt?
        if match(.semicolon) {
            initializer = nil
        } else if match(.var) {
            initializer = try varDeclaration()
        } else {
            initializer = try expressionStatement()
        }
        
        let condition = check(.semicolon) ? Expr.literal(value: .bool(true)) : try expression()
        try consume(.semicolon, "Expect ';' after loop condition.")
        
        let increment = check(.rightParen) ? nil : try expression()
        try consume(.rightParen, "Expect ')' after for clauses.")
        
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
        try consume(.leftParen, "Expect '(' after 'if'.")
        let condition = try expression()
        try consume(.rightParen, "Expect ')' after if condition.")
        
        let thenBranch = try statement()
        let elseBranch = match(.else) ? try statement() : nil
        
        return .if(expr: condition, then: thenBranch, else: elseBranch)
    }
    
    private func printStatement() throws -> Stmt {
        let expr = try expression()
        try consume(.semicolon, "Expect ';' after value.")
        return .print(expr: expr)
    }
    
    private func returnStatement() throws -> Stmt {
        let keyword = previous
        let value: Expr = check(.semicolon) ? .literal(value: .null) : try expression()
        
        try consume(.semicolon, "Expect ';' after return value.")
        return .return(keyword: keyword, value: value)
    }

    private func varDeclaration() throws -> Stmt {
        let name = try consume(.identifier, "Expect variable name.")
        let initializer = match(.equal) ? try expression() : .literal(value: .null)
        try consume(.semicolon, "Expect ';' after variable declaration.")
        return .variable(name: name, initializer: initializer)
    }
    
    private func whileStatement() throws -> Stmt {
        try consume(.leftParen, "Expect '(' after 'while'.")
        let condition = try expression()
        try consume(.rightParen, "Expect ')' after condition.")
        let body = try statement()
        
        return .while(condition: condition, body: body)
    }
    
    private func expressionStatement() throws -> Stmt {
        let expr = try expression()
        try consume(.semicolon, "Expect ';' after expression.")
        return .expr(expr: expr)
    }
    
    private func function(_ kind: String) throws -> Stmt {
        let name = try consume(.identifier, "Expect \(kind) name.")
        
        try consume(.leftParen, "Expect '(' after \(kind) name.")
        var parameters: [Token] = []
        if !check(.rightParen) {
            repeat {
                if parameters.count >= 8 {
                    _ = error(peek, "Cannot have more than 8 parameters.")
                }
                
                parameters.append(try consume(.identifier, "Expect parameter name."))
            } while match(.comma)
        }
        try consume(.rightParen, "Expect ')' after parameters.")
        
        try consume(.leftBrace, "Expect '{' before \(kind) body.");
        let body = try block()
        return .function(name: name, parameters: parameters, body: body)
    }
    
    private func block() throws -> [Stmt] {
        var statements: [Stmt] = []
        
        while !check(.rightBrace) && !isAtEnd {
            if let statement = try declaration() {
                statements.append(statement)
            }
        }
        
        try consume(.rightBrace, "Expect '}' after block.")
        return statements
    }
    
    private func assignment() throws -> Expr {
        let expr = try or()
        
        
        if match(.equal) {
            let equals = previous
            let value = try assignment()
            
            if case let .variable(name) = expr {
                return .assign(name: name, value: value)
            }
            
            if case let .get(object, name) = expr {
                return .set(object: object, name: name, value: value)
            }
            
            throw error(equals, "Invalid assignment target.")
        }
        
        return expr
    }
    
    private func or() throws -> Expr {
        var expr = try and()
        
        while match(.or) {
            let op = previous
            let right = try and()
            expr = .logical(left: expr, op: op, right: right)
        }
        
        return expr
    }
    
    private func and() throws -> Expr {
        var expr = try equality()
        
        while match(.and) {
            let op = previous
            let right = try equality()
            expr = .logical(left: expr, op: op, right: right)
        }
        
        return expr
    }
    
    private func equality() throws -> Expr {
        var expr = try comparison()
        
        while match([.bangEqual, .equalEqual]) {
            let op = previous
            let right = try comparison()
            expr = .binary(left: expr, op: op, right: right)
        }
        
        return expr
    }
    
    private func comparison() throws -> Expr {
        var expr = try term()
        
        while match([.greater, .greaterEqual, .less, .lessEqual]) {
            let op = previous
            let right = try term()
            expr = .binary(left: expr, op: op, right: right)
        }
        
        return expr
    }
    
    private func term() throws -> Expr {
        var expr = try factor()
        
        while match([.minus, .plus]) {
            let op = previous
            let right = try factor()
            expr = .binary(left: expr, op: op, right: right)
        }
        
        return expr
    }
    
    private func factor() throws -> Expr {
        var expr = try unary()
        
        while match([.slash, .star]) {
            let op = previous
            let right = try unary()
            expr = .binary(left: expr, op: op, right: right)
        }
        
        return expr
    }
    
    private func unary() throws -> Expr {
        if match([.bang, .minus]) {
            let op = previous
            let right = try unary()
            return .unary(op: op, right: right)
        }
        
        return try call()
    }
    
    private func call() throws -> Expr {
        var expr = try primary()
        
        while true {
            if match([.leftParen]) {
                expr = try finishCall(expr)
            } else if match([.dot]) {
                let name = try consume(.identifier, "Expect property name after '.'.")
                expr = .get(object: expr, name: name)
            } else {
                break
            }
        }
        
        return expr
    }
    
    private func finishCall(_ callee: Expr) throws -> Expr {
        var arguments: [Expr] = []
        
        if !check(.rightParen) {
            repeat {
                if arguments.count == 8 {
                    _ = error(peek, "Cannot have more than 8 arguments.")
                }
                arguments.append(try expression())
            } while match(.comma)
        }
        
        let paren = try consume(.rightParen, "Expect ')' after arguments.")
        
        return .call(callee: callee, paren: paren, arguments: arguments)
    }
    
    private func primary() throws -> Expr {
        if match(.false) { return .literal(value: .bool(false)) }
        if match(.true) { return .literal(value: .bool(true)) }
        if match(.nil) { return .literal(value: .null) }
        
        if match([.number, .string]) { return .literal(value: previous.literal) }
        
        if match(.super) {
            let keyword = previous
            try consume(.dot, "Expect '.' after 'super'.")
            let method = try consume(.identifier, "Expect superclass method name.")
            return .super(keyword: keyword, method: method)
        }
        
        if match(.this) { return .this(keyword: previous) }
        
        if match(.identifier) { return .variable(name: previous) }
        
        if match(.leftParen) {
            let expr = try expression()
            try consume(.rightParen, "Expect ')' after expression.")
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
            if (previous.type == .semicolon) { return }
            
            switch (peek.type) {
            case .class: fallthrough
            case .fun: fallthrough
            case .var: fallthrough
            case .for: fallthrough
            case .if: fallthrough
            case .while: fallthrough
            case .print: fallthrough
            case .return: return
            default: advance()
            }
        }
    }
}
