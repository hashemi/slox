//
//  Interpreter.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-04-07.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

var environment = Environment()

struct RuntimeError: Error {
    let token: Token
    let message: String
    
    init(_ token: Token, _ message: String) {
        self.token = token
        self.message = message
    }
}

extension Expr {
    func evaluate() throws -> LiteralValue {
        switch self {
        case .literal(let value):
            return value

        case .unary(let op, let rightExpr):
            let right = try rightExpr.evaluate()
            
            switch op.type {
            case .BANG:
                return .bool(!right.isTrue)
            case .MINUS:
                guard case let .number(rightNumber) = right
                    else { throw RuntimeError(op, "Operand must be a number.") }
                
                return .number(-rightNumber)
            default: break
            }
            
            // Unreachable.
            return .null

        case .binary(let leftExpr, let op, let rightExpr):
            let left = try leftExpr.evaluate()
            let right = try rightExpr.evaluate()
            
            if case let .number(leftNumber) = left,
                case let .number(rightNumber) = right {
                switch op.type {
                case .PLUS:
                    return .number(leftNumber + rightNumber)
                case .MINUS:
                    return .number(leftNumber - rightNumber)
                case .SLASH:
                    return .number(leftNumber / rightNumber)
                case .STAR:
                    return .number(leftNumber * rightNumber)
                case .GREATER:
                    return .bool(leftNumber > rightNumber)
                case .GREATER_EQUAL:
                    return .bool(leftNumber >= rightNumber)
                case .LESS:
                    return .bool(leftNumber < rightNumber)
                case .LESS_EQUAL:
                    return .bool(leftNumber <= rightNumber)
                default: break
                }
            }
            
            if case let .string(leftString) = left,
                case let .string(rightString) = right,
                case .PLUS = op.type {
                return .string(leftString + rightString)
            }
            
            // By the time we got here, all correct binary operators with correct value
            // types are handled. Next handle correct operators with incorrect types.
            switch op.type {
            case .PLUS:
                throw RuntimeError(op, "Operands must be two numbers or two strings.")
            case .MINUS, .SLASH, .STAR, .GREATER, .GREATER_EQUAL, .LESS, .LESS_EQUAL:
                throw RuntimeError(op, "Operands must be numbers.")
            default: break
            }
            
            // Unreachable.
            return .null
        
        case .grouping(let expr):
            return try expr.evaluate()
        case .variable(let name):
            return try environment.get(name: name)
        case .assign(let name, let value):
            let value = try value.evaluate()
            try environment.assign(name: name, value: value)
            return value
        }
    }
}

extension Stmt {
    func execute() throws {
        switch self {
        case .expr(let expr):
            _ = try expr.evaluate()
        case .print(let expr):
            let value = try expr.evaluate()
            Swift.print(value)
        case .variable(let name, let initializer):
            let value = try initializer.evaluate()
            environment.define(name: name.lexeme, value: value)
        }
    }
}
