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
        case .Binary(let left, let op, let right):
            return parenthesize(op.lexeme, [left, right])
        case .Grouping(let expr):
            return parenthesize("group", [expr])
        case .Literal(let value):
            return "\(value)"
        case .Unary(let op, let right):
            return parenthesize(op.lexeme, [right])
        }
    }
}
