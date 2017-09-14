//
//  Resolve.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-09-11.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

class Resolver {
    private var scopes: [[String: Bool]] = []
    
    func begin() {
        scopes.append([:])
    }
    
    func end() {
        _ = scopes.popLast()
    }
    
    func declare(_ name: Token) {
        if scopes.isEmpty { return }
        scopes[scopes.count - 1][name.lexeme] = false
    }
    
    func define(_ name: Token) {
        if scopes.isEmpty { return }
        scopes[scopes.count - 1][name.lexeme] = true
    }
    
    func declaredNotDefined(_ name: Token) -> Bool {
        if scopes.last?[name.lexeme] == false {
            return true
        }
        
        return false
    }
    
    func resolveLocal(_ name: Token) -> Int {
        for (idx, scope) in scopes.reversed().enumerated() {
            if scope.keys.contains(name.lexeme) {
                return idx
            }
        }
        return scopes.count // global
    }
}

extension Stmt {
    func resolve(resolver: Resolver) -> ResolvedStmt {
        switch self {
        case .block(let statements):
            resolver.begin()
            let resolvedStatements = statements.map { $0.resolve(resolver: resolver) }
            resolver.end()
            return .block(statements: resolvedStatements)
        
        case .variable(let name, let initializer):
            resolver.declare(name)
            let resolvedInitializer = initializer.resolve(resolver: resolver)
            resolver.define(name)
            return .variable(name: name, initializer: resolvedInitializer)
        
        case .function(let name, let parameters, let body):
            resolver.declare(name)
            resolver.define(name)
            
            resolver.begin()
            for param in parameters {
                resolver.declare(param)
                resolver.define(param)
            }
            
            let resolvedBody = body.map { $0.resolve(resolver: resolver) }
            
            resolver.end()
            
            return .function(name: name, parameters: parameters, body: resolvedBody)
        
        case .expr(let expr):
            return .expr(expr: expr.resolve(resolver: resolver))
        
        case .if(let condition, let then, let `else`):
            let resolvedCondition = condition.resolve(resolver: resolver)
            let resolvedThen = then.resolve(resolver: resolver)
            let resolvedElse = `else`?.resolve(resolver: resolver)
            return .if(expr: resolvedCondition, then: resolvedThen, else: resolvedElse)
        
        case .print(let expr):
            return .print(expr: expr.resolve(resolver: resolver))
            
        case .return(let keyword, let value):
            return .return(keyword: keyword, value: value.resolve(resolver: resolver))
            
        case .while(let condition, let body):
            let resolvedCondition = condition.resolve(resolver: resolver)
            let resolvedBody = body.resolve(resolver: resolver)
            return .while(condition: resolvedCondition, body: resolvedBody)
        }
    }
}

extension Expr{
    func resolve(resolver: Resolver) -> ResolvedExpr {
        switch self {
        case .variable(let name):
            if resolver.declaredNotDefined(name) {
                Lox.error(name, "Cannot read local variable in its own initializer.")
            }
            
            let depth = resolver.resolveLocal(name)
            
            return .variable(name: name, depth: depth)
        
        case .assign(let name, let value):
            let resolvedValue = value.resolve(resolver: resolver)
            let depth = resolver.resolveLocal(name)
            
            return .assign(name: name, value: resolvedValue, depth: depth)
            
        case .binary(let left, let op, let right):
            let resolvedLeft = left.resolve(resolver: resolver)
            let resolvedRight = right.resolve(resolver: resolver)
            return .binary(left: resolvedLeft, op: op, right: resolvedRight)
            
        case .call(let callee, let paren, let arguments):
            let resolvedCallee = callee.resolve(resolver: resolver)
            let resolvedArguments = arguments.map { $0.resolve(resolver: resolver) }
            
            return .call(callee: resolvedCallee, paren: paren, arguments: resolvedArguments)
            
        case .grouping(let expr):
            return .grouping(expr: expr.resolve(resolver: resolver))
            
        case .literal(let value):
            return .literal(value: value)
            
        case .logical(let left, let op, let right):
            let resolvedLeft = left.resolve(resolver: resolver)
            let resolvedRight = right.resolve(resolver: resolver)
            return .logical(left: resolvedLeft, op: op, right: resolvedRight)
            
        case .unary(let op, let right):
            return .unary(op: op, right: right.resolve(resolver: resolver))
        }
    }
}
