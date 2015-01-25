//
//  UnicodeIterator.swift
//  JZBUtils
//
//  Created by Jose Zarzuela on 10/01/2015.
//  Copyright (c) 2015 Jose Zarzuela. All rights reserved.
//

import Foundation

public class UnicodeIterator : GeneratorType, SequenceType {
    
    private let data    : NSData // Hace falta para tenerlo retenido
    private let bytePtr : UnsafePointer<Byte>
    private let length  : Int
    private var index   = 0
    private(set) public var error : NSError? = nil
    
    //------------------------------------------------------------------------------------------------------------------------
    public init(strValue:String) {
        
        
        if let data = strValue.dataUsingEncoding(NSUTF8StringEncoding) {
            self.data = data
            self.bytePtr = UnsafePointer<Byte>(data.bytes)
            self.length = data.length
        } else {
            self.data = NSData()
            self.bytePtr = nil
            self.length = -1
            self.error = _error("Can't get UTF8 bytes from String")
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    public func generate() -> UnicodeIterator {
        return self
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    public func next() -> UInt32? {
        
        if index >= self.length {
            
            return nil
            
        } else {
            
            let x1 : Byte = self.bytePtr[index++]
            
            switch x1 {
                
            case 0...127:
                return UInt32(x1)
                
            case 192...223:
                // 00000yyy yyxxxxxx
                // 110yyyyy 10xxxxxx
                let x2 : Byte = self.bytePtr[index++]
                let valor = UInt32(x1 & 0x1F)<<6 | UInt32(x2 & 0x3F)
                return valor
                
            case 224...239:
                // zzzzyyyy yyxxxxxx
                // 1110zzzz 10yyyyyy 10xxxxxx
                let x2 : Byte = self.bytePtr[index++]
                let x3 : Byte = self.bytePtr[index++]
                let valor = UInt32(x1 & 0x0F)<<12 | UInt32(x2 & 0x3F)<<6 | UInt32(x3 & 0x3F)
                return valor
                
            case 240...247:
                // 000UUUuu zzzzyyyy yyxxxxxx
                // 11110UUU 10uuzzzz 10yyyyyy 10xxxxxx
                let x2 : Byte = self.bytePtr[index++]
                let x3 : Byte = self.bytePtr[index++]
                let x4 : Byte = self.bytePtr[index++]
                let valor = UInt32(x1 & 0x07)<<18 | UInt32(x2 & 0x3F)<<12 | UInt32(x3 & 0x3F)<<6 | UInt32(x4 & 0x3F)
                return valor
                
            default:
                index--
                self.error = _error("Found an invalid byte: [\(x1)] at index: [\(index-1)]")
                return nil
            }
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _error(reason:String) -> NSError {
        var userInfo : Dictionary<String, AnyObject> = [NSLocalizedDescriptionKey:reason]
        return NSError(domain: "JZBUtils.UnicodeIterator", code: 5000, userInfo: userInfo)
    }

}
