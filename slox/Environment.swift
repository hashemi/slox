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
    
    private init() {
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
    
    func assign(name: String, value: LiteralValue, at depth: Int) -> Bool {
        if depth == 0 {
            guard values[name] != nil else { return false }
            
            values[name] = value
            return true
        } else {
            return enclosing!.assign(name: name, value: value, at: depth - 1)
        }
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
