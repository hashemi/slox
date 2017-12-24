//
//  Class.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-12-24.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

struct Class {
    let name: String
    let methods: [String: Function]
    
    func find(instance: Instance, method: String) -> Function? {
        return methods[method]?.bind(instance)
    }
}

extension Class: CustomStringConvertible {
    var description: String {
        return name
    }
}

extension Class: Callable {
    var arity: Int { return 0 }
    func call(_ args: [LiteralValue]) throws -> LiteralValue {
        return .instance(Instance(class: self))
    }
}

class Instance {
    let klass: Class
    var fields: [String: LiteralValue] = [:]
    
    init(class klass: Class) {
        self.klass = klass
    }
    
    func get(_ name: Token) throws -> LiteralValue {
        if let value = fields[name.lexeme] {
            return value
        }
        
        if let method = klass.find(instance: self, method: name.lexeme) {
            return .callable(method)
        }
        
        throw RuntimeError(name, "Undefined property '\(name.lexeme)'.")
    }
    
    func set(_ name: Token, _ value: LiteralValue) {
        fields[name.lexeme] = value
    }
}

extension Instance: CustomStringConvertible {
    var description: String {
        return "\(klass.name) instance"
    }
}
