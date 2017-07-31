//
//  Return.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-07-31.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

struct Return: Error {
    let value: LiteralValue

    init(_ value: LiteralValue) {
        self.value = value
    }
}
