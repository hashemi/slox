//
//  LiteralValue.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-03-22.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

enum LiteralValue {
    case bool(Bool)
    case number(Double)
    case string(String)
    case null
    case function(Function)
    case `class`(Class)
    case instance(Instance)
}

extension LiteralValue {
    var isTrue: Bool {
        switch self {
        case .null: return false
        case let .bool(val): return val
        case .number, .string, .function, .class, .instance: return true
        }
    }
}

extension LiteralValue: Equatable {
    static func == (lhs: LiteralValue, rhs: LiteralValue) -> Bool {
        switch (lhs, rhs) {
        case (.null, .null):
            return true
        case let (.string(left), .string(right)):
            return left == right
        case let (.number(left), .number(right)):
            return left == right
        case let (.bool(left), .bool(right)):
            return left == right
        case (.null, _), (.bool, _), (.string, _), (.number, _), (.function, _), (.class, _), (.instance, _):
            return false
        }
    }
}

extension LiteralValue: CustomStringConvertible {
    var description: String {
        switch self {
        case .null:
            return "nil"
        case let .number(number):
            let str = String(number)
            return str.hasSuffix(".0") ? String(str[str.startIndex..<str.index(str.endIndex, offsetBy: -2)]) : str
        case let .string(string):
            return string
        case let .bool(bool) :
            return String(bool)
        case let .function(function):
            return function.description
        case let .class(klass):
            return klass.description
        case let .instance(instance):
            return instance.description
        }
    }
}
