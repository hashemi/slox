//
//  Class.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-12-24.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

struct Class {
    class Superclass {
        let superclass: Class?
        init(_ superclass: Class?) {
            self.superclass = superclass
        }
    }
    
    let name: String
    let superclass: Superclass
    let methods: [String: Function]
    
    init(name: String, superclass: Class?, methods: [String: Function]) {
        self.name = name
        self.superclass = Superclass(superclass)
        self.methods = methods
    }
    
    func find(instance: Instance, method: String) -> Function? {
        if let boundMethod = methods[method]?.bind(instance) {
            return boundMethod
        }
        
        if let superclass = superclass.superclass {
            return superclass.find(instance: instance, method: method)
        }
        
        return nil
    }
}

extension Class: CustomStringConvertible {
    var description: String {
        return name
    }
}

extension Class: Callable {
    var arity: Int { return methods["init"]?.arity ?? 0 }
    func call(_ args: [LiteralValue]) throws -> LiteralValue {
        let instance = Instance(class: self)
        
        if let initializer = methods["init"] {
            _ = try initializer.bind(instance).call(args)
        }
        
        return .instance(instance)
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
