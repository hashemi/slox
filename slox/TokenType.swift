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
    LEFT_PAREN, RIGHT_PAREN, LEFT_BRACE, RIGHT_BRACE,
    COMMA, DOT, MINUS, PLUS, SEMICOLON, SLASH, STAR,
    BANG, BANG_EQUAL,
    EQUAL, EQUAL_EQUAL,
    GREATER, GREATER_EQUAL,
    LESS, LESS_EQUAL,
    
    // One or two character tokens.
    IDENTIFIER, STRING, NUMBER,
    
    // Literals.
    AND, CLASS, ELSE, FALSE, FUN, FOR, IF, NIL, OR,
    PRINT, RETURN, SUPER, THIS, TRUE, VAR, WHILE,
    
    // Keywords.
    EOF
}
