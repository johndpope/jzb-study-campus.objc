//
//  GLayer.swift
//  GMapService
//
//  Created by Jose Zarzuela on 24/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation


public class GLayer : GAsset {
    
    unowned public let map:GMap
    
    public var name = ""
    
    public var creationTime:Int64 = Int64(NSDate().timeIntervalSince1970)
    public var lastModifiedTime : Int64 = Int64(NSDate().timeIntervalSince1970)
    
    private(set) public var style : GStyle!
    private(set) public var table : GTable!
    
    
    //------------------------------------------------------------------------------------------------------------------------
    internal init(gid:String, map:GMap, tableGID:String, styleGID:String) {
        
        self.map = map

        super.init(gid:gid)
        
        self.table = GTable(gid: tableGID, layer: self)
        // TODO: Solo ese style
        self.style = GStyleIndividual(gid: styleGID, layer: self)
    }
    
    
    //------------------------------------------------------------------------------------------------------------------------
    required public init(coder decoder: NSCoder) {
        
        map = decoder.decodeObjectForKey("ownerMap") as GMap
        
        super.init(coder: decoder)
        
        name = decoder.decodeObjectForKey("name") as NSString
        creationTime = decoder.decodeInt64ForKey("creationTime")
        lastModifiedTime = decoder.decodeInt64ForKey("lastModifiedTime")
        
        style = decoder.decodeObjectForKey("style") as GStyleIndividual
        table = decoder.decodeObjectForKey("table") as GTable
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    override public func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(map, forKey: "ownerMap")
        
        super.encodeWithCoder(aCoder)
        
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeInt64(creationTime, forKey: "creationTime")
        aCoder.encodeInt64(lastModifiedTime, forKey: "lastModifiedTime")
        
        aCoder.encodeObject(style, forKey: "style")
        aCoder.encodeObject(table, forKey: "table")
    }

    //------------------------------------------------------------------------------------------------------------------------
    override internal var _assetClassName : String {
        return "GLayer";
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    override internal func _debugDescriptionInner(inout strVal:String, padding:String, tabIndex:UInt) {
        
        super._debugDescriptionInner(&strVal, padding: padding, tabIndex:tabIndex)
        
        strVal += "\(padding)name: '\(name)'\n"
        strVal += "\(padding)creationTime: \(NSDate(timeIntervalSince1970: Double(creationTime)/1000))\n"
        strVal += "\(padding)lastModifiedTime: \(NSDate(timeIntervalSince1970: Double(lastModifiedTime)/1000))\n"
        
        if style != nil {
            strVal += "\(padding)style: \n"
            strVal += style!._debugDescription(tabIndex+1)
            strVal += "\(padding)\n"
        } else {
            strVal += "\(padding)style: NONE\n"
        }
        
        if table != nil {
            strVal += "\(padding)table: \n"
            strVal += table!._debugDescription(tabIndex+1)
            strVal += "\(padding)\n"
        } else {
            strVal += "\(padding)table: NONE\n"
        }
    }
    
}