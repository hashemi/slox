//
//  Expr.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-03-18.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

indirect enum Expr {
    case Binary(left: Expr, op: Token, right: Expr)
    case Grouping(expr: Expr)
    case Literal(value: Any)
    case Unary(op: Token, right: Expr)
}
