//
//  Callable.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-07-31.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

struct Callable {
    let arity: Int
    let call: (Environment, [LiteralValue]) -> LiteralValue
}

extension Callable: CustomStringConvertible {
    var description: String {
        return "function(\(arity))"
    }
}
