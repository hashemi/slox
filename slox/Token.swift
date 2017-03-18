//
//  Token.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-03-18.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

class Token {
    let type: TokenType
    let lexeme: String
    let literal: Any
    let line: Int
    
    init(_ type: TokenType, _ lexeme: String, _ literal: Any, _ line: Int) {
        self.type = type
        self.lexeme = lexeme
        self.literal = literal
        self.line = line
    }
}

extension Token: CustomStringConvertible {
    var description: String {
        return "\(type) \(lexeme) \(literal)"
    }
}
