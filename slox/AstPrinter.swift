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
        case .unary(let op, let right):
            return parenthesize(op.lexeme, [right])
        case .variable(let name):
            return name.lexeme
        case .assign(let name, let value):
            return parenthesize("= \(name)", [value])
        }
    }
}
