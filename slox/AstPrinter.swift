//
//  AstPrinter.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-03-21.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

func parenthesize(_ name: String, _ exprs: [Expr]) -> String {
    return
        "(\(name) "
            + exprs.map { $0.ast }.joined(separator: " ")
            + ")"
}

extension Expr {
    var ast: String {
        switch self {
        case .binary(let left, let op, let right):
            return parenthesize(op.lexeme, [left, right])
        case .grouping(let expr):
            return parenthesize("group", [expr])
        case .literal(let value):
            return "\(value)"
        case .logical(let left, let op, let right):
            return parenthesize(op.lexeme, [left, right])
        case .unary(let op, let right):
            return parenthesize(op.lexeme, [right])
        case .variable(let name):
            return name.lexeme
        case .assign(let name, let value):
            return parenthesize("= \(name)", [value])
        case .call(let callee, _, let arguments):
            return parenthesize("call \(callee)", arguments)
        case .get(let object, let name):
            return parenthesize(".\(name)", [object])
        case .set(let object, let name, let value):
            let getter = parenthesize(".\(name)", [object])
            return parenthesize("= \(getter)", [value])
        case .this(let keyword):
            return keyword.lexeme
        }
    }
}
