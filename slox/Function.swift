//
//  Function.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-12-24.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

protocol Function: Callable { }

struct UserFunction: Function {
    let name: Token
    let parameters: [Token]
    let body: [ResolvedStmt]
    
    let closure: Environment
    let isInitializer: Bool
    
    var arity: Int { return parameters.count }
    
    func call(_ args: [LiteralValue]) throws -> LiteralValue {
        let environment = Environment(enclosing: closure)
        
        for (par, arg) in zip(parameters, args) {
            environment.define(name: par.lexeme, value: arg)
        }
        
        do {
            for statement in body {
                try statement.execute(environment: environment)
            }
        } catch let ret as Return {
            return ret.value
        }
        
        if isInitializer {
            return try closure.getThis()
        }
        
        return .null
    }
    
    func bind(_ instance: Instance) -> UserFunction {
        let environment = Environment(enclosing: closure)
        environment.define(name: "this", value: .instance(instance))
        return UserFunction(
            name: name,
            parameters: parameters,
            body: body,
            closure: environment,
            isInitializer: isInitializer
        )
    }

    var description: String {
        return "<fn \(name.lexeme)>"
    }
}

struct NativeFunction: Function {
    let arity: Int
    let body: ([LiteralValue]) throws -> LiteralValue
    
    func call(_ args: [LiteralValue]) throws -> LiteralValue {
        return try body(args)
    }
    
    var description: String { return "<fn native>" }
}
