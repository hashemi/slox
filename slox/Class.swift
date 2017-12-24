//
//  Class.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-12-24.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

struct Class {
    let name: String
}

extension Class: CustomStringConvertible {
    var description: String {
        return name
    }
}

class Instance {
    let klass: Class
    var fields: [String: LiteralValue] = [:]
    
    init(class klass: Class) {
        self.klass = klass
    }
    
    func get(_ name: Token) throws -> LiteralValue {
        guard let value = fields[name.lexeme] else {
            throw RuntimeError(name, "Undefined property '\(name.lexeme)'.")
        }
        return value
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
