//
//  GAsset.swift
//  GMapService
//
//  Created by Jose Zarzuela on 24/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation

private var _idCounter:UInt64 = 0

public class GAsset : NSObject, NSCoding, Printable, DebugPrintable {
    
    public let gid:String
    

    //------------------------------------------------------------------------------------------------------------------------
    internal init(gid:String) {
        
        self.gid = gid

        super.init()
        
        assert(!(self.dynamicType===GAsset.self), "GAsset must be considered an abstract class and cannot be instantiated directly")
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    required public init(coder decoder: NSCoder) {
        gid = decoder.decodeObjectForKey("gid") as NSString
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(gid, forKey: "gid")
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    internal class func generateGID() -> String {
        
        _idCounter = _idCounter &+ 1;
        
        let p1:UInt64 = (UInt64(NSDate().timeIntervalSince1970)<<20) & 0xFFFFFFFFFFF00000
        let p2:UInt64 = (UInt64(arc4random_uniform(0x1000))<<8)      & 0x00000000000FFF00
        let p3:UInt64 = _idCounter                                   & 0x00000000000000FF
        let p = p1|p2|p3
        
        let gid = NSString(format:"%0.16lX", p) as String
        
        return gid.uppercaseString
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    internal var _assetClassName : String {
        return "GAsset";
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    internal func _debugDescriptionInner(inout strVal:String, padding:String, tabIndex:UInt) {
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    internal func _debugDescription(tabIndex:UInt) -> String {
        
        var padding = "".stringByPaddingToLength(4*Int(tabIndex), withString: " ", startingAtIndex: 0)
        var child_padding = "".stringByPaddingToLength(4*Int(tabIndex+1), withString: " ", startingAtIndex: 0)
        
        var strVal = ""
        strVal += "\(padding)\(_assetClassName) {\n"
        strVal += "\(child_padding)gid: \(gid)\n"
        _debugDescriptionInner(&strVal, padding:child_padding, tabIndex:tabIndex+1)
        strVal += "\(padding)}"
        return strVal
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    override public var debugDescription : String {
        return _debugDescription(0)
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    override public var description : String {
        return _debugDescription(0)
    }
}