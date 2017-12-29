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

extension ResolvedExpr {
    func evaluate(environment: Environment) throws -> LiteralValue {
        switch self {
        case .literal(let value):
            return value

        case .logical(let leftExpr, let op, let rightExpr):
            let left = try leftExpr.evaluate(environment: environment)
            
            if op.type == .or {
                if left.isTrue { return left }
            } else {
                if !left.isTrue { return left }
            }
            
            return try rightExpr.evaluate(environment: environment)
            
        case .unary(let op, let rightExpr):
            let right = try rightExpr.evaluate(environment: environment)
            
            switch op.type {
            case .bang:
                return .bool(!right.isTrue)
            case .minus:
                guard case let .number(rightNumber) = right
                    else { throw RuntimeError(op, "Operand must be a number.") }
                
                return .number(-rightNumber)
            default: break
            }
            
            // Unreachable.
            return .null

        case .binary(let leftExpr, let op, let rightExpr):
            let left = try leftExpr.evaluate(environment: environment)
            let right = try rightExpr.evaluate(environment: environment)
            
            if case let .number(leftNumber) = left,
                case let .number(rightNumber) = right {
                switch op.type {
                case .plus:
                    return .number(leftNumber + rightNumber)
                case .minus:
                    return .number(leftNumber - rightNumber)
                case .slash:
                    return .number(leftNumber / rightNumber)
                case .star:
                    return .number(leftNumber * rightNumber)
                case .greater:
                    return .bool(leftNumber > rightNumber)
                case .greaterEqual:
                    return .bool(leftNumber >= rightNumber)
                case .less:
                    return .bool(leftNumber < rightNumber)
                case .lessEqual:
                    return .bool(leftNumber <= rightNumber)
                default: break
                }
            }
            
            if case let .string(leftString) = left,
                case let .string(rightString) = right,
                case .plus = op.type {
                return .string(leftString + rightString)
            }
            
            switch op.type {
            case .bangEqual: return .bool(left != right)
            case .equalEqual: return .bool(left == right)
            
            // By the time we got here, all correct binary operators with correct value
            // types are handled. Next handle correct operators with incorrect types.
            case .plus:
                throw RuntimeError(op, "Operands must be two numbers or two strings.")
            case .minus, .slash, .star, .greater, .greaterEqual, .less, .lessEqual:
                throw RuntimeError(op, "Operands must be numbers.")
            default: break
            }
            
            // Unreachable.
            return .null
        
        case .call(let calleeExpr, let paren, let argumentExprs):
            let callee = try calleeExpr.evaluate(environment: environment)
            let arguments = try argumentExprs.map { try $0.evaluate(environment: environment) }
            
            let callable: Callable
            
            switch callee {
            case .function(let function): callable = function
            case .class(let klass): callable = klass
            default:
                throw RuntimeError(paren, "Can only call functions and classes.")
            }
            
            guard arguments.count == callable.arity else {
                throw RuntimeError(paren,
                   "Expected \(callable.arity) arguments but got \(arguments.count).")
            }
            
            return try callable.call(arguments)
        
        case .get(let objectExpr, let name):
            let object = try objectExpr.evaluate(environment: environment)
            guard case let .instance(instance) = object else {
                throw RuntimeError(name, "Only instances have properties.")
            }
            
            return try instance.get(name)
        
        case .set(let objectExpr, let name, let valueExpr):
            let object = try objectExpr.evaluate(environment: environment)
            guard case let .instance(instance) = object else {
                throw RuntimeError(name, "Only instances have fields.")
            }
            
            let value = try valueExpr.evaluate(environment: environment)
            
            instance.set(name, value)
            
            return value
        
        case .super(_, let methodExpr, let depth):
            guard case let .class(superclass) = environment.get(name: "super", at: depth)!
                else { fatalError("Got a non-class for 'super'.") }
            
            guard case let .instance(object) = environment.get(name: "this", at: depth - 1)!
                else { fatalError("Got a non-object for 'this'.") }
            
            guard let method = superclass.find(instance: object, method: methodExpr.lexeme) else {
                throw RuntimeError(methodExpr, "Undefined property '\(methodExpr.lexeme)'.")
            }
            
            return .function(method)
        
        case .this(let keyword, let depth):
            guard let value = environment.get(name: keyword.lexeme, at: depth) else {
                throw RuntimeError(keyword, "Undefined variable '" + keyword.lexeme + "'.")
            }
            return value
            
        case .grouping(let expr):
            return try expr.evaluate(environment: environment)
        
        case .variable(let name, let depth):
            guard let value = environment.get(name: name.lexeme, at: depth) else {
                throw RuntimeError(name, "Undefined variable '" + name.lexeme + "'.")
            }
            return value
        
        case .assign(let name, let value, let depth):
            let value = try value.evaluate(environment: environment)
            
            guard environment.assign(name: name.lexeme, value: value, at: depth) else {
                throw RuntimeError(name, "Undefined variable '" + name.lexeme + "'.")
            }
            
            return value
        }
    }
}

extension ResolvedStmt {
    func execute(environment: Environment) throws {
        switch self {
        case .expr(let expr):
            _ = try expr.evaluate(environment: environment)
        
        case .print(let expr):
            let value = try expr.evaluate(environment: environment)
            Swift.print(value)
        
        case .variable(let name, let initializer):
            let value = try initializer.evaluate(environment: environment)
            environment.define(name: name.lexeme, value: value)
        
        case .while(let cond, body: let body):
            while try cond.evaluate(environment: environment).isTrue {
                try body.execute(environment: environment)
            }
        
        case .block(let statements):
            let blockEnvironment = Environment(enclosing: environment)
            for statement in statements {
                try statement.execute(environment: blockEnvironment)
            }

        case .class(let name, let superclassExpr, let methodExprs):
            let originalEnvironment = environment
            
            var environment = environment

            environment.define(name: name.lexeme, value: .null)
            
            let superclass: Class?
            if let superclassExpr = superclassExpr {
                let value = try superclassExpr.evaluate(environment: environment)
                
                guard case let .class(klass) = value
                    else { throw RuntimeError(name, "Superclass must be a class.") }
                
                superclass = klass
                
                environment = Environment(enclosing: environment)
                environment.define(name: "super", value: value)
            } else {
                superclass = nil
            }
            
            var methods: [String: UserFunction] = [:]
            for methodExpr in methodExprs {
                guard case let .function(name, parameters, body) = methodExpr
                    // This should never happen
                    else { fatalError("Class declaration should only contain methods.") }
                
                methods[name.lexeme] = UserFunction(
                    name: name,
                    parameters: parameters,
                    body: body,
                    closure: environment,
                    isInitializer: name.lexeme == "init")
            }
            
            let klass = Class(name: name.lexeme, superclass: superclass, methods: methods)
            
            if superclass != nil {
                environment = originalEnvironment
            }
            
            environment.define(name: name.lexeme, value: .class(klass))
        
        case .if(let condExpr, let thenBranch, let elseBranch):
            let condition = try condExpr.evaluate(environment: environment).isTrue
            if condition {
                try thenBranch.execute(environment: environment)
            } else {
                try elseBranch?.execute(environment: environment)
            }
        
        case .function(let name, let parameters, let body):
            let function = UserFunction(
                name: name,
                parameters: parameters,
                body: body,
                closure: environment,
                isInitializer: false
            )
            environment.define(name: name.lexeme, value: .function(function))
        
        case .return(_, let valueExpr):
            let value = try valueExpr.evaluate(environment: environment)
            throw Return(value)
        }
    }
}
