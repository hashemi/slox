//
//  Expr.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-03-18.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

protocol ExprVisitor {
    func visit<T>(_ expr: Binary) -> T
    func visit<T>(_ expr: Grouping) -> T
    func visit<T>(_ expr: Literal) -> T
    func visit<T>(_ expr: Unary) -> T
}

protocol Expr {
    func accept<T>(_ visitor: ExprVisitor) -> T
}

class Binary: Expr {
    let left: Expr
    let op: Token
    let right: Expr
    
    init(_ left: Expr, _ op: Token, _ right: Expr) {
        self.left = left
        self.op = op
        self.right = right
    }
    
    func accept<T>(_ visitor: ExprVisitor) -> T {
        return visitor.visit(self)
    }
}

class Grouping: Expr {
    let expression: Expr
    
    init(_ expression: Expr) {
        self.expression = expression
    }
    
    func accept<T>(_ visitor: ExprVisitor) -> T {
        return visitor.visit(self)
    }
}

class Literal: Expr {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    func accept<T>(_ visitor: ExprVisitor) -> T {
        return visitor.visit(self)
    }
}

class Unary: Expr {
    let op: Token
    let right: Expr
    
    init(_ op: Token, _ right: Expr) {
        self.op = op
        self.right = right
    }
    
    func accept<T>(_ visitor: ExprVisitor) -> T {
        return visitor.visit(self)
    }
}
