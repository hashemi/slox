//
//  Resolve.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-09-11.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

class Resolver {
    enum FunctionType {
        case none
        case function
        case initializer
        case method
    }
    
    enum ClassType {
        case none
        case `class`
        case subclass
    }
    
    private var scopes: [[String: Bool]] = []
    private(set) var currentFunction: FunctionType = .none
    var currentClass: ClassType = .none
    
    func begin() {
        scopes.append([:])
    }
    
    func end() {
        _ = scopes.popLast()
    }
    
    func declare(_ name: Token) {
        if scopes.isEmpty { return }
        
        if scopes[scopes.count - 1].keys.contains(name.lexeme) {
            Lox.error(name, "Variable with this name already declared in this scope.")
        }
        
        scopes[scopes.count - 1][name.lexeme] = false
    }
    
    func define(_ name: Token) {
        if scopes.isEmpty { return }
        scopes[scopes.count - 1][name.lexeme] = true
    }
    
    func defineThis() {
        if scopes.isEmpty { return }
        scopes[scopes.count - 1]["this"] = true
    }
    
    func defineSuper() {
        if scopes.isEmpty { return }
        scopes[scopes.count - 1]["super"] = true
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
    
    func resolveFunction(name: Token, parameters: [Token], body: [Stmt], type functionType: FunctionType) -> ResolvedStmt {
        let enclosingFunction = currentFunction
        currentFunction = functionType
        
        begin()
        for param in parameters {
            declare(param)
            define(param)
        }
        
        let resolvedBody = body.map { $0.resolve(resolver: self) }
        end()
        
        currentFunction = enclosingFunction
        
        return .function(name: name, parameters: parameters, body: resolvedBody)
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
        
        case .class(let name, let superclass, let methods):
            resolver.declare(name)
            resolver.define(name)
            let enclosingClass = resolver.currentClass
            resolver.currentClass = .class
            
            let resolvedSuperclass: ResolvedExpr?
            if let superclass = superclass {
                resolver.currentClass = .subclass
                resolvedSuperclass = superclass.resolve(resolver: resolver)
                resolver.begin()
                resolver.defineSuper()
            } else {
                resolvedSuperclass = nil
            }
            
            resolver.begin()
            resolver.defineThis()
            
            let resolvedMethods = methods.map { (method: Stmt) -> ResolvedStmt in
                guard case let .function(name, parameters, body) = method else {
                    // This should never happen
                    fatalError("Class declaration can only contain methods.")
                }
                
                let declaration: Resolver.FunctionType = name.lexeme == "init" ? .initializer : .method
                
                return resolver.resolveFunction(name: name, parameters: parameters, body: body, type: declaration)
            }
            
            resolver.end()
            
            if resolvedSuperclass != nil {
                resolver.end()
            }
            
            resolver.currentClass = enclosingClass
            
            return .class(name: name, superclass: resolvedSuperclass, methods: resolvedMethods)
            
        case .variable(let name, let initializer):
            resolver.declare(name)
            let resolvedInitializer = initializer.resolve(resolver: resolver)
            resolver.define(name)
            return .variable(name: name, initializer: resolvedInitializer)
        
        case .function(let name, let parameters, let body):
            resolver.declare(name)
            resolver.define(name)
            
            return resolver.resolveFunction(name: name, parameters: parameters, body: body, type: .function)
        
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
            if resolver.currentFunction == .none {
                Lox.error(keyword, "Cannot return from top-level code.")
            }
            
            if resolver.currentFunction == .initializer {
                switch value {
                case .literal(value: .null): break // Return not followed by a value is permitted in initializers
                default:
                    Lox.error(keyword, "Cannot return a value from an initializer.")
                }
            }
            
            return .return(keyword: keyword, value: value.resolve(resolver: resolver))
            
        case .while(let condition, let body):
            let resolvedCondition = condition.resolve(resolver: resolver)
            let resolvedBody = body.resolve(resolver: resolver)
            return .while(condition: resolvedCondition, body: resolvedBody)
        }
    }
}

extension Expr {
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
        
        case .get(let object, let name):
            let resolvedObject = object.resolve(resolver: resolver)
            return .get(object: resolvedObject, name: name)
            
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
        
        case .set(let object, let name, let value):
            return .set(
                object: object.resolve(resolver: resolver),
                name: name,
                value: value.resolve(resolver: resolver))
        
        case .super(let keyword, let method):
            switch resolver.currentClass {
            case .none: Lox.error(keyword, "Cannot use 'super' outside of a class.")
            case .class: Lox.error(keyword, "Cannot use 'super' in a class with no superclass.")
            case .subclass: break
            }
            
            let depth = resolver.resolveLocal(keyword)
            return .super(keyword: keyword, method: method, depth: depth)
        
        case .this(let keyword):
            if resolver.currentClass == .none {
                Lox.error(keyword, "Cannot use 'this' outside of a class.")
            }
            
            let depth = resolver.resolveLocal(keyword)
            return .this(keyword: keyword, depth: depth)
        }
    }
}
