//
//  GMap.swift
//  GMapService
//
//  Created by Jose Zarzuela on 24/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation


public class GMap : GAsset {
    
    public var name = ""
    public var desc = ""
    
    public var creationTime:Int64 = Int64(NSDate().timeIntervalSince1970)
    public var lastModifiedTime : Int64 = Int64(NSDate().timeIntervalSince1970)
    
    private(set) public var layers : [GLayer] = []
    
    
    
    //------------------------------------------------------------------------------------------------------------------------
    override internal init(gid:String) {
        super.init(gid:gid)
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    required public init(coder decoder: NSCoder) {

        super.init(coder: decoder)
        
        name = decoder.decodeObjectForKey("name") as NSString
        desc = decoder.decodeObjectForKey("desc") as NSString
        creationTime = decoder.decodeInt64ForKey("creationTime")
        lastModifiedTime = decoder.decodeInt64ForKey("lastModifiedTime")

        layers = decoder.decodeObjectForKey("layers") as [GLayer]
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    override public func encodeWithCoder(coder: NSCoder) {
        
        super.encodeWithCoder(coder)
        
        coder.encodeObject(name, forKey: "name")
        coder.encodeObject(desc, forKey: "desc")
        coder.encodeInt64(creationTime, forKey: "creationTime")
        coder.encodeInt64(lastModifiedTime, forKey: "lastModifiedTime")

        coder.encodeObject(layers, forKey: "layers")
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    internal class func fromData(data:NSData) -> GMap {
        
        let decoder = NSKeyedUnarchiver(forReadingWithData: data)
        let map = decoder.decodeObject() as GMap
        return map
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    internal func toData() -> NSData {
        
        let data = NSMutableData()
        let coder = NSKeyedArchiver(forWritingWithMutableData: data)
        coder.outputFormat = NSPropertyListFormat.BinaryFormat_v1_0
        
        coder.encodeRootObject(self)

        coder.finishEncoding()
        
        return data
    }


    //------------------------------------------------------------------------------------------------------------------------
    internal func addLayerWithID(layerGID:String, tableGID:String, styleGID:String) -> GLayer {

        let layer = GLayer(gid: layerGID, map: self, tableGID:tableGID, styleGID:styleGID)
        layers.append(layer)
        return layer
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    public func featureByID(feature_gid:String) -> GFeature? {
        
        for layer in layers {
            for feature in layer.table.features {
                if feature.gid == feature_gid {
                    return feature
                }
            }
        }
        
        return nil
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    override internal var _assetClassName : String {
        return "GMap";
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    override internal func _debugDescriptionInner(inout strVal:String, padding:String, tabIndex:UInt) {
        
        super._debugDescriptionInner(&strVal, padding: padding, tabIndex:tabIndex)
        
        strVal += "\(padding)name: '\(name)'\n"
        strVal += "\(padding)desc: '\(desc)'\n"
        strVal += "\(padding)creationTime: \(NSDate(timeIntervalSince1970: Double(creationTime)/1000))\n"
        strVal += "\(padding)lastModifiedTime: \(NSDate(timeIntervalSince1970: Double(lastModifiedTime)/1000))\n"
        
        strVal += "\(padding)layers: {\n"
        for layer in layers {
            strVal += layer._debugDescription(tabIndex+1)
            strVal += "\n"
        }
        strVal += "\(padding)}\n"
    }
    
}