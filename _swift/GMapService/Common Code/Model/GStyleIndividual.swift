//
//  GStyleIndividual.swift
//  GMapService
//
//  Created by Jose Zarzuela on 24/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation
import JZBUtils




//========================================================================================================================
public class GStyleIndividual: GStyle {
    
    public var defaultPointStyle   = GStyleInfoPoint()
    public var defaultLineStyle    = GStyleInfoLine()
    public var defaultPolygonStyle = GStyleInfoPolygon()
    
    private var featureStyles = Dictionary<String, GStyleInfo>()
    
    
    
    //------------------------------------------------------------------------------------------------------------------------
    override public init(gid:String, layer:GLayer) {
        
        super.init(gid:gid, layer:layer)
    }
    
    
    //------------------------------------------------------------------------------------------------------------------------
    required public init(coder decoder: NSCoder) {
        
        super.init(coder: decoder)
        
        var dict : Dictionary<String,AnyObject>

        dict = decoder.decodeObjectForKey("defaultPointStyle") as Dictionary<String,AnyObject>
        defaultPointStyle = GStyleInfoCoder.dictToStyle(dict) as GStyleInfoPoint
        dict = decoder.decodeObjectForKey("defaultLineStyle") as Dictionary<String,AnyObject>
        defaultLineStyle = GStyleInfoCoder.dictToStyle(dict) as GStyleInfoLine
        dict = decoder.decodeObjectForKey("defaultPolygonStyle") as Dictionary<String,AnyObject>
        defaultPolygonStyle = GStyleInfoCoder.dictToStyle(dict) as GStyleInfoPolygon

        // featureStyles
        let count = decoder.decodeIntegerForKey("featureStylesCount")
        for var index=0; index<count; index++ {
            let name = decoder.decodeObjectForKey("featureStylesName_\(index)") as String
            dict = decoder.decodeObjectForKey("featureStylesValue_\(index)") as Dictionary<String,AnyObject>
            let value = GStyleInfoCoder.dictToStyle(dict)
            featureStyles[name] = value
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    override public func encodeWithCoder(aCoder: NSCoder) {
        
        super.encodeWithCoder(aCoder)
        
        aCoder.encodeObject(GStyleInfoCoder.styleToDict(defaultPointStyle), forKey: "defaultPointStyle")
        aCoder.encodeObject(GStyleInfoCoder.styleToDict(defaultLineStyle), forKey: "defaultLineStyle")
        aCoder.encodeObject(GStyleInfoCoder.styleToDict(defaultPolygonStyle), forKey: "defaultPolygonStyle")
        
        // featureStyles
        aCoder.encodeInteger(featureStyles.count, forKey: "featureStylesCount")
        var index = 0
        for (name, value) in featureStyles {
            aCoder.encodeObject(name, forKey: "featureStylesName_\(index)")
            aCoder.encodeObject(GStyleInfoCoder.styleToDict(value), forKey: "featureStylesValue_\(index)")
            index++
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    internal subscript(feature:GFeature) -> GStyleInfo {
        
        get {
            if let style = featureStyles[feature.gid] {
                return style
            } else {
                let defStyle = _defaultStyleForGeometry(feature.geometry)
                return defStyle
            }
        }
        
        set {
            
            featureStyles[feature.gid] = newValue
        }
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    public class func imageForIcon(icon_id:Int) -> NSImage? {
        
        if let path = NSBundle(identifier: "com.zetLabs.GMapService")?.pathForResource("\(icon_id)", ofType: "png") {
            let image = NSImage(contentsOfFile: path)
            return image
        } else {
            return nil
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _defaultStyleForGeometry(geometry:GGeometry) -> GStyleInfo {
        
        switch geometry {
            
        case let x as GGeometryPoint:
            return defaultPointStyle
            
        case let x as GGeometryLine:
            return defaultLineStyle
            
        case let x as GGeometryPolygon:
            return defaultPolygonStyle
            
        default:
            // TODO: AQUI NO DEBERIA LLEGAR
            return defaultPointStyle
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    override internal var _assetClassName : String {
        return "GStyleIndividual";
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    override internal func _debugDescriptionInner(inout strVal:String, padding:String, tabIndex:UInt) {
        
        super._debugDescriptionInner(&strVal, padding: padding, tabIndex:tabIndex)
        
        strVal += "\(padding)defaultIconStyle: \(defaultPointStyle)\n"
        strVal += "\(padding)defaultLineStyle: \(defaultLineStyle)\n"
        strVal += "\(padding)defaultPolygonStyle: \(defaultPolygonStyle)\n"
    }
    
}