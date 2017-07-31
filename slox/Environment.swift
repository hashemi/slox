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
    
    func get(name: Token) throws -> LiteralValue {
        guard let value = values[name.lexeme] else {
            guard let enclosing = self.enclosing else {
                throw RuntimeError(name, "Undefined variable '" + name.lexeme + "'.")
            }
            return try enclosing.get(name: name)
        }
        
        return value
    }
    
    func assign(name: Token, value: LiteralValue) throws {
        guard values.keys.contains(name.lexeme) else {
            guard let enclosing = self.enclosing else {
                throw RuntimeError(name, "Undefined variable '" + name.lexeme + "'.")
            }
            return try enclosing.assign(name: name, value: value)
        }
        
        values[name.lexeme] = value
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
