//
//  Environment.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-06-03.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

import CoreFoundation

class Environment {
    // Wrapper class to get reference semantics
    private class Scope {
        private var values: [String: LiteralValue] = [:]
        subscript(index: String) -> LiteralValue? {
            get {
                return values[index]
            }
            set(newValue) {
                values[index] = newValue
            }
        }
    }
    
    private var stack: [Scope]
    
    init(enclosing: Environment) {
        var newStack = enclosing.stack
        newStack.append(Scope())
        self.stack = newStack
    }
    
    private init() {
        self.stack = [Scope()]
    }
    
    func define(name: String, value: LiteralValue) {
        stack[stack.count - 1][name] = value
    }
    
    func get(name: String, at depth: Int) -> LiteralValue? {
        return stack[stack.count - 1 - depth][name]
    }
    
    func assign(name: String, value: LiteralValue, at depth: Int) -> Bool {
        guard stack[stack.count - 1 - depth][name] != nil else { return false }
        
        stack[stack.count - 1 - depth][name] = value
        return true
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
