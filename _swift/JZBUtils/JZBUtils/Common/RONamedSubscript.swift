//
//  NamedSubscript.swift
//  JZBUtils
//
//  Created by Jose Zarzuela on 11/01/2015.
//  Copyright (c) 2015 Jose Zarzuela. All rights reserved.
//

import Foundation


public class RONamedSubscript<K,V> : SequenceType {

    private let getter : (K)->V
    private let generator : (() -> GeneratorOf<(K,V)>)?
    
    //------------------------------------------------------------------------------------------------------------------------
    public init(getter : (K)->V, generator : (() -> GeneratorOf<(K,V)>)? = nil) {
        self.getter = getter
        self.generator = generator
    }

    //------------------------------------------------------------------------------------------------------------------------
    public subscript(key:K) -> V {
        get {
            return self.getter(key)
        }
    }

    //------------------------------------------------------------------------------------------------------------------------
    public func generate() -> GeneratorOf<(K,V)> {
        if self.generator != nil {
            return self.generator!()
        } else {
            return GeneratorOf() { return nil }
        }
    }

}