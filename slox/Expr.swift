//
//  Expr.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-03-18.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

indirect enum Expr {
    case binary(left: Expr, op: Token, right: Expr)
    case grouping(expr: Expr)
    case literal(value: LiteralValue)
    case unary(op: Token, right: Expr)
}
