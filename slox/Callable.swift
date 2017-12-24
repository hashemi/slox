//
//  Callable.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-07-31.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

protocol Callable: CustomStringConvertible {
    var arity: Int { get }
    func call(_: [LiteralValue]) throws -> LiteralValue
}
