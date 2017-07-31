//
//  Callable.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-07-31.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

struct Callable {
    let name: String
    let arity: Int
    let call: (Environment, [LiteralValue]) throws -> LiteralValue
}

extension Callable: CustomStringConvertible {
    var description: String {
        return "<fn \(name)>"
    }
}
