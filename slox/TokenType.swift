//
//  TokenType.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-03-18.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

enum TokenType {
    case
    // Single-character tokens.
    leftParen, rightParen, leftBrace, rightBrace,
    comma, dot, minus, plus, semicolon, slash, star,
    bang, bangEqual,
    equal, equalEqual,
    greater, greaterEqual,
    less, lessEqual,
    
    // One or two character tokens.
    identifier, string, number,
    
    // Literals.
    and, `class`, `else`, `false`, fun, `for`, `if`, `nil`, or,
    print, `return`, `super`, this, `true`, `var`, `while`,
    
    // Keywords.
    eof
}
