//
//  String+Java.swift
//  JZBUtils
//
//  Created by Jose Zarzuela on 29/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation

public extension String
{
    // ----------------------------------------------------------------------------------------------------
    public var length: Int {
        
        get {
            return countElements(self)
        }
    }
    
    // ----------------------------------------------------------------------------------------------------
    public func contains(s: String) -> Bool {
        return self.rangeOfString(s) != nil ? true : false
    }
    
    // ----------------------------------------------------------------------------------------------------
    public func replace(target: String, withString: String) -> String {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    // ----------------------------------------------------------------------------------------------------
    public subscript (i: Int) -> Character {
        
        get {
            let index = advance(startIndex, i)
            return self[index]
        }
    }
    
    // ----------------------------------------------------------------------------------------------------
    public subscript (r: Range<Int>) -> String {
        
        get {
            let startIndex = advance(self.startIndex, r.startIndex)
            let endIndex = advance(self.startIndex, r.endIndex - 1)
            
            return self[Range(start: startIndex, end: endIndex)]
        }
    }
    
    // ----------------------------------------------------------------------------------------------------
    public func subString(startIndex: Int) -> String {
        
        var start = advance(self.startIndex, startIndex)
        return self.substringWithRange(Range<String.Index>(start: start, end: self.endIndex))
    }
    
    // ----------------------------------------------------------------------------------------------------
    public func subString(startIndex: Int, length: Int) -> String {
        
        var start = advance(self.startIndex, startIndex)
        var end = advance(self.startIndex, startIndex + length)
        return self.substringWithRange(Range<String.Index>(start: start, end: end))
    }
    
    // ----------------------------------------------------------------------------------------------------
    public func subString(startIndex: Int, endIndex: Int) -> String {
        
        return subString(startIndex,  length:(endIndex-startIndex))
    }
    
    // ----------------------------------------------------------------------------------------------------
    public func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }

    // ----------------------------------------------------------------------------------------------------
    public func indexOf(target: String) -> Int {
        
        var range = self.rangeOfString(target)
        if let range = range {
            return distance(self.startIndex, range.startIndex)
        } else {
            return -1
        }
    }
    
    // ----------------------------------------------------------------------------------------------------
    public func indexOf(target: String, startIndex: Int) -> Int {
        
        var startRange = advance(self.startIndex, startIndex)
        
        var range = self.rangeOfString(target, options: NSStringCompareOptions.LiteralSearch, range: Range<String.Index>(start: startRange, end: self.endIndex))
        
        if let range = range {
            return distance(self.startIndex, range.startIndex)
        } else {
            return -1
        }
    }
    
    // ----------------------------------------------------------------------------------------------------
    public func indexOf(target: String, startIndex: Int, offset: Int) -> Int {
        
        if(startIndex<0) {
            return -1
        } else {
            return indexOf(target, startIndex: (startIndex+offset))
        }
    }
    
    // ----------------------------------------------------------------------------------------------------
    public func lastIndexOf(target: String) -> Int {
        
        var index = -1
        var stepIndex = self.indexOf(target)
        while stepIndex > -1
        {
            index = stepIndex
            if stepIndex + target.length < self.length {
                stepIndex = indexOf(target, startIndex: stepIndex + target.length)
            } else {
                stepIndex = -1
            }
        }
        return index
    }
    
    // ----------------------------------------------------------------------------------------------------
    public func isMatch(regex: String, options: NSRegularExpressionOptions) -> Bool? {
        
        var error: NSError?
        if let exp = NSRegularExpression(pattern: regex, options: options, error: &error) {
            var matchCount = exp.numberOfMatchesInString(self, options: nil, range: NSMakeRange(0, self.length))
            return matchCount > 0
        } else {
            return nil
        }
    }
    
    // ----------------------------------------------------------------------------------------------------
    public func getMatches(regex: String, options: NSRegularExpressionOptions) -> [NSTextCheckingResult]? {
        
        var error: NSError?
        if let exp = NSRegularExpression(pattern: regex, options: options, error: &error) {
            var matches = exp.matchesInString(self, options: nil, range: NSMakeRange(0, self.length))
            return matches as? [NSTextCheckingResult]
        } else {
            return nil
        }
        
    }
}