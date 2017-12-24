//
//  Class.swift
//  slox
//
//  Created by Ahmad Alhashemi on 2017-12-24.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

struct Class {
    let name: String
}

extension Class: CustomStringConvertible {
    var description: String {
        return name
    }
}

struct Instance {
    let klass: Class
    
    init(class klass: Class) {
        self.klass = klass
    }
}

extension Instance: CustomStringConvertible {
    var description: String {
        return "\(klass.name) instance"
    }
}
