//
//  Expr.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-03-18.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

indirect enum Expr {
    case assign(name: Token, value: Expr)
    case binary(left: Expr, op: Token, right: Expr)
    case call(callee: Expr, paren: Token, arguments: [Expr])
    case get(object: Expr, name: Token)
    case grouping(expr: Expr)
    case literal(value: LiteralValue)
    case logical(left: Expr, op: Token, right: Expr)
    case set(object: Expr, name: Token, value: Expr)
    case `super`(keyword: Token, method: Token)
    case this(keyword: Token)
    case unary(op: Token, right: Expr)
    case variable(name: Token)
}

indirect enum ResolvedExpr {
    case assign(name: Token, value: ResolvedExpr, depth: Int)
    case binary(left: ResolvedExpr, op: Token, right: ResolvedExpr)
    case call(callee: ResolvedExpr, paren: Token, arguments: [ResolvedExpr])
    case get(object: ResolvedExpr, name: Token)
    case grouping(expr: ResolvedExpr)
    case literal(value: LiteralValue)
    case logical(left: ResolvedExpr, op: Token, right: ResolvedExpr)
    case set(object: ResolvedExpr, name: Token, value: ResolvedExpr)
    case `super`(keyword: Token, method: Token, depth: Int)
    case this(keyword: Token, depth: Int)
    case unary(op: Token, right: ResolvedExpr)
    case variable(name: Token, depth: Int)
}
