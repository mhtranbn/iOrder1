//
//  ExtensionDictionary.swift
//  iOrder
//
//  Created by mhtran on 6/25/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import Foundation
extension Dictionary {
    /// Constructs [key:value] from [(key, value)]
    
    init<S: SequenceType
        where S.Generator.Element == Element>
        (_ seq: S) {
        self.init()
        self.merge(seq)
    }
    
    mutating func merge<S: SequenceType
        where S.Generator.Element == Element>
        (seq: S) {
        var gen = seq.generate()
        while let (k, v) = gen.next() {
            self[k] = v
        }
    }
}