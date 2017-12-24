//
//  Callable.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-07-31.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

protocol Callable: CustomStringConvertible {
    var arity: Int { get }
    func call(_: [LiteralValue]) throws -> LiteralValue
}

struct Function: Callable {
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
    
    func bind(_ instance: Instance) -> Function {
        let environment = Environment(enclosing: closure)
        environment.define(name: "this", value: .instance(instance))
        return Function(
            name: name,
            parameters: parameters,
            body: body,
            closure: environment,
            isInitializer: isInitializer
        )
    }
}

extension Function: CustomStringConvertible {
    var description: String {
        return "<fn \(name.lexeme)>"
    }
}

struct NativeFunction: Callable {
    let arity: Int
    let body: ([LiteralValue]) throws -> LiteralValue

    func call(_ args: [LiteralValue]) throws -> LiteralValue {
        return try body(args)
    }
    
    var description: String { return "<fn native>" }
}
