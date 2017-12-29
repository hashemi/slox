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
    
    init(enclosing: Environment) {
        self.enclosing = enclosing
    }
    
    fileprivate init() {
        self.enclosing = nil
    }
    
    func define(name: String, value: LiteralValue) {
        values[name] = value
    }
    
    func get(name: String, at depth: Int) -> LiteralValue? {
        if depth == 0 {
            return values[name]
        } else {
            return enclosing!.get(name: name, at: depth - 1)
        }
    }
    
    func assign(name: Token, value: LiteralValue, at depth: Int) throws {
        var environment: Environment? = self
        for _ in 0..<depth {
            environment = environment?.enclosing
        }
        
        guard environment?.values[name.lexeme] != nil else {
            throw RuntimeError(name, "Undefined variable '" + name.lexeme + "'.")
        }
        
        environment?.values[name.lexeme] = value
    }
}

extension Environment {
    static let globals: Environment = {
        var environment = Environment()
        
        environment.define(
            name: "clock",
            value: .function(
                NativeFunction(arity: 0) { _ in
                    return .number(Double(CFAbsoluteTimeGetCurrent()) + 978307200.0)
                }
            )
        )
        
        return environment
    }()
}
