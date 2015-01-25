//
//  Crypto.swift
//  JZBUtils
//
//  Created by Jose Zarzuela on 24/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation


public class Crypto {
    
    //------------------------------------------------------------------------------------------------------------------------
    internal init() {
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    public class func encriptString(str:String, passwd:String) -> String {
        
        let data = str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
        return encriptData(data, passwd: passwd)
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    public class func decriptString(base64Str:String, passwd:String) -> String {
        
        if let decData = decriptData(base64Str, passwd: passwd) {
            if let decStr = NSString(data: decData, encoding: NSUTF8StringEncoding) {
                return decStr
            } else {
                return ""
            }
        } else {
            return ""
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    public class func encriptData(data:NSData, passwd:String) -> String {
        
        var xorPasswd : [UInt8] = []
        for char in passwd.utf8 {
            xorPasswd += [char]
        }
        
        var xorIndex = 0
        
        var bytes = Array<UInt8>(count: data.length, repeatedValue: 0)
        data.getBytes(&bytes, length: data.length)
        for (index, value) in enumerate(bytes) {
            bytes[index] = value ^ xorPasswd[xorIndex]
            xorIndex = (xorIndex + 1) % xorPasswd.count
        }
        
        let encData = NSData(bytes: bytes, length: bytes.count)
        let encStr = encData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros)
        return encStr
    }
    
    
    //------------------------------------------------------------------------------------------------------------------------
    public class func decriptData(base64Str:String, passwd:String) -> NSData? {
        
        var xorPasswd : [UInt8] = []
        for char in passwd.utf8 {
            xorPasswd += [char]
        }
        
        var xorIndex = 0
        
        if let data = NSData(base64EncodedString: base64Str, options: NSDataBase64DecodingOptions.allZeros) {
            
            var bytes = Array<UInt8>(count: data.length, repeatedValue: 0)
            data.getBytes(&bytes, length: data.length)
            for (index, value) in enumerate(bytes) {
                bytes[index] = value ^ xorPasswd[xorIndex]
                xorIndex = (xorIndex + 1) % xorPasswd.count
            }
            let decData = NSData(bytes: bytes, length: bytes.count)
            return decData
            
        } else {
            
            return nil
            
        }
    }
    
}
