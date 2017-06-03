//
//  Stmt.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-06-01.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

import Foundation

enum Stmt {
    case print(expr: Expr)
    case expr(expr: Expr)
    case variable(name: Token, initializer: Expr)
}
