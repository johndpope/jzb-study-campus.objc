//
//  XCGLogger.swift
//  JZBUtils
//
//  Created by Jose Zarzuela on 03/01/2015.
//  Copyright (c) 2015 Jose Zarzuela. All rights reserved.
//

import Foundation


public class XCGLogger {
    
    public class func defaultInstance() -> XCGLogger {
        return XCGLogger()
    }
    
    public func debug(msg:String) {
        println(msg)
    }

    public func warning(msg:String) {
        println(msg)
    }
    
    public func error(msg:String) {
        println(msg)
    }
    
    
}