//
//  AstPrinter.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-03-21.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

class AstPrinter: ExprVisitor {
    func print(_ expr: Expr) -> String {
        return expr.accept(self)
    }
    
    func visit<String>(_ expr: Binary) -> String {
        return parenthesize(expr.op.lexeme, [expr.left, expr.right]) as! String
    }
    
    func visit<String>(_ expr: Grouping) -> String {
        return parenthesize("group", [expr.expression]) as! String
    }
    
    func visit<String>(_ expr: Literal) -> String {
        return "\(expr.value)" as! String
    }
    
    func visit<String>(_ expr: Unary) -> String {
        return parenthesize(expr.op.lexeme, [expr.right]) as! String
    }
    
    func parenthesize(_ name: String, _ exprs: [Expr]) -> String {
        return
            "(\(name) "
            + exprs.map { $0.accept(self) as String }.joined(separator: " ")
            + ")"
    }
}
