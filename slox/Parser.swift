//
//  Parser.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-03-21.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

import Foundation

class Parser {
    private struct ParseError: Error {}

    let tokens: [Token]
    var current = 0
    
    init(_ tokens: [Token]) {
        self.tokens = tokens
    }
    
    func parse() -> Expr? {
        return try? expression()
    }
    
    private func expression() throws -> Expr {
        return try equality()
    }
    
    private func equality() throws -> Expr {
        var expr = try comparison()
        
        while match([.BANG_EQUAL, .EQUAL_EQUAL]) {
            let op = previous()
            let right = try comparison()
            expr = Binary(expr, op, right)
        }
        
        return expr
    }
    
    private func comparison() throws -> Expr {
        var expr = try term()
        
        while match([.GREATER, .GREATER_EQUAL, .LESS, .LESS_EQUAL]) {
            let op = previous()
            let right = try term()
            expr = Binary(expr, op, right)
        }
        
        return expr
    }
    
    private func term() throws -> Expr {
        var expr = try factor()
        
        while match([.MINUS, .PLUS]) {
            let op = previous()
            let right = try factor()
            expr = Binary(expr, op, right)
        }
        
        return expr
    }
    
    private func factor() throws -> Expr {
        var expr = try unary()
        
        while match([.SLASH, .STAR]) {
            let op = previous()
            let right = try unary()
            expr = Binary(expr, op, right)
        }
        
        return expr
    }
    
    private func unary() throws -> Expr {
        if match([.BANG, .MINUS]) {
            let op = previous()
            let right = try unary()
            return Unary(op, right)
        }
        
        return try primary()
    }
    
    private func primary() throws -> Expr {
        if match(.FALSE) { return Literal(false) }
        if match(.TRUE) { return Literal(true) }
        if match(.NIL) { return Literal(NSNull()) }
        
        if match([.NUMBER, .STRING]) { return Literal(previous().literal) }
        
        if match(.LEFT_PAREN) {
            let expr = try expression()
            _ = try consume(.RIGHT_PAREN, "Expect ')' after expression.")
            return Grouping(expr)
        }
        
        throw error(peek(), "Expected expression.")
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
    
    private func consume(_ type: TokenType, _ message: String) throws -> Token {
        if check(type) { return advance() }
        
        throw error(peek(), message)
    }

    private func match(_ type: TokenType) -> Bool {
        return match([type])
    }
    
    private func check(_ tokenType: TokenType) -> Bool {
        if isAtEnd() { return false }
        return peek().type == tokenType
    }
    
    private func advance() -> Token {
        if !isAtEnd() { current += 1 }
        return previous()
    }
    
    private func isAtEnd() -> Bool {
        return peek().type == .EOF
    }
    
    private func peek() -> Token {
        return tokens[current]
    }
    
    private func previous() -> Token {
        return tokens[current - 1]
    }
    
    private func error(_ token: Token, _ message: String) -> Error {
        Lox.error(token, message)
        return ParseError()
    }
    
    private func synchronize() {
        _ = advance()
        while !isAtEnd() {
            if (previous().type == .SEMICOLON) { return }
            
            switch (peek().type) {
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
