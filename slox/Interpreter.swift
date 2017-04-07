//
//  Interpreter.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-04-07.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

struct RuntimeError: Error {
    let token: Token
    let message: String
    
    init(_ token: Token, _ message: String) {
        self.token = token
        self.message = message
    }
}

extension Expr {
    func interpret() throws -> LiteralValue {
        switch self {
        case .literal(let value):
            return value

        case .unary(let op, let rightExpr):
            let right = try rightExpr.interpret()
            
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
            let left = try leftExpr.interpret()
            let right = try rightExpr.interpret()
            
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
            return try expr.interpret()
        }
    }
}
