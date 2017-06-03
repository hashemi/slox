//
//  Environment.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-06-03.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

struct Environment {
    var values: [String: LiteralValue] = [:]
    
    mutating func define(name: String, value: LiteralValue) {
        values[name] = value
    }
    
    func get(name: Token) throws -> LiteralValue {
        guard let value = values[name.lexeme] else {
            throw RuntimeError(name, "Undefined variable '" + name.lexeme + "'.")
        }
        
        return value
    }
    
    mutating func assign(name: Token, value: LiteralValue) throws {
        guard values.keys.contains(name.lexeme) else {
            throw RuntimeError(name, "Undefined variable '" + name.lexeme + "'.")
        }
        
        values[name.lexeme] = value
    }
}
