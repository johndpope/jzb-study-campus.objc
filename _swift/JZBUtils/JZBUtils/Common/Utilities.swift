//
//  Utilities.swift
//  JZBUtils
//
//  Created by Jose Zarzuela on 02/01/2015.
//  Copyright (c) 2015 Jose Zarzuela. All rights reserved.
//

import Foundation


public func sameType<T> (a: T, b: T) -> Bool {
    return true
}

public func sameType<T,U> (a: T, b: U) -> Bool {
    return false;
}
