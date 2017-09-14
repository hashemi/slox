//
//  Stmt.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-06-01.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

indirect enum Stmt {
    case block(statements: [Stmt])
    case print(expr: Expr)
    case `return`(keyword: Token, value: Expr)
    case expr(expr: Expr)
    case variable(name: Token, initializer: Expr)
    case `while`(condition: Expr, body: Stmt)
    case function(name: Token, parameters: [Token], body: [Stmt])
    case `if`(expr: Expr, then: Stmt, else: Stmt?)
}

indirect enum ResolvedStmt {
    case block(statements: [ResolvedStmt])
    case print(expr: ResolvedExpr)
    case `return`(keyword: Token, value: ResolvedExpr)
    case expr(expr: ResolvedExpr)
    case variable(name: Token, initializer: ResolvedExpr)
    case `while`(condition: ResolvedExpr, body: ResolvedStmt)
    case function(name: Token, parameters: [Token], body: [ResolvedStmt])
    case `if`(expr: ResolvedExpr, then: ResolvedStmt, else: ResolvedStmt?)
}
