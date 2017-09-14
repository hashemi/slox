//
//  Environment.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-06-03.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

import CoreFoundation

class Environment {
    var values: [String: LiteralValue] = [:]
    let enclosing: Environment?
    
    init(enclosing: Environment? = nil) {
        self.enclosing = enclosing
    }
    
    func define(name: String, value: LiteralValue) {
        values[name] = value
    }
    
    func get(name: Token, at depth: Int) throws -> LiteralValue {
        var environment: Environment? = self
        for _ in 0..<depth {
            environment = environment?.enclosing
        }
        
        guard let value = environment?.values[name.lexeme] else {
            throw RuntimeError(name, "Undefined variable '" + name.lexeme + "'.")
        }
        
        return value
    }
    
    func assign(name: Token, value: LiteralValue, at depth: Int) {
        var environment: Environment? = self
        for _ in 0..<depth {
            environment = environment?.enclosing
        }
        environment?.values[name.lexeme] = value
    }
}

extension Environment {
    static let globals: Environment = {
        var environment = Environment()
        
        environment.define(name: "clock", value: .callable(Callable(
            name: "clock",
            arity: 0,
            call: { (env: Environment, args: [LiteralValue]) -> LiteralValue in
                return .number(Double(CFAbsoluteTimeGetCurrent()) + 978307200.0)
            }
        )))
        
        return environment
    }()
}
