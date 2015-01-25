//
//  GStyle.swift
//  GMapService
//
//  Created by Jose Zarzuela on 24/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation

internal let STYLE_DEFAULT_ICON_ID = 22 // Blue-Dot
internal let STYLE_DEFAULT_COLOR   = "DB4436" // Rojo
internal let STYLE_DEFAULT_SCALE   = 1.0 // Sin escalado
internal let STYLE_DEFAULT_WIDTH   = 3000 // ?? puntos
internal let STYLE_DEFAULT_ALPHA   = 0.6 // Semitransparente


//========================================================================================================================
public protocol GStyleInfo : Printable, DebugPrintable {
}

//------------------------------------------------------------------------------------------------------------------------
public struct GStyleInfoPoint : GStyleInfo {
    
    public let iconID   : Int    = STYLE_DEFAULT_ICON_ID
    public let colorHex : String = STYLE_DEFAULT_COLOR
    public let scale    : Double = STYLE_DEFAULT_SCALE
    
    public init() {
    }
    
    public init(iconID:Int, colorHex:String, scale:Double) {
        self.iconID = iconID
        self.colorHex = colorHex
        self.scale = scale
    }
    
    public var debugDescription : String  {
        return "PointStyle {iconID: \(iconID), colorHex: \(colorHex), scale: \(scale)}"
    }
    
    public var description : String  {
        return debugDescription
    }
    
    
}

//------------------------------------------------------------------------------------------------------------------------
public struct GStyleInfoLine : GStyleInfo {
    
    public let colorHex : String = STYLE_DEFAULT_COLOR
    public let width    : Int    = STYLE_DEFAULT_WIDTH
    public let alpha    : Double = STYLE_DEFAULT_ALPHA
    
    public init() {
    }
    
    public init(colorHex:String, width:Int, alpha:Double) {
        self.colorHex = colorHex
        self.width = width
        self.alpha = alpha
    }
    
    public var debugDescription : String  {
        return "LineStyle {colorHex: \(colorHex), width: \(width), alpha: \(alpha)}"
    }
    
    public var description : String  {
        return debugDescription
    }
    
    
}

//------------------------------------------------------------------------------------------------------------------------
public struct GStyleInfoPolygon : GStyleInfo {
    
    public let colorHex : String = STYLE_DEFAULT_COLOR
    public let width    : Int    = STYLE_DEFAULT_WIDTH
    public let alpha    : Double = STYLE_DEFAULT_ALPHA
    
    public init() {
    }
    
    public init(colorHex:String, width:Int, alpha:Double) {
        self.colorHex = colorHex
        self.width = width
        self.alpha = alpha
    }
    
    public var debugDescription : String  {
        return "PolygonStyle {colorHex: \(colorHex), width: \(width), alpha: \(alpha)}"
    }
    
    public var description : String  {
        return debugDescription
    }
    
    
}

//------------------------------------------------------------------------------------------------------------------------
internal class GStyleInfoCoder {
    
    
    internal class func styleToDict(style:GStyleInfo) -> Dictionary<String,AnyObject> {
        
        var dict = Dictionary<String,AnyObject>()
        
        switch style {
        case let point as GStyleInfoPoint:
            dict["type"]     = 1
            dict["iconID"]   = point.iconID
            dict["colorHex"] = point.colorHex
            dict["scale"]    = point.scale
            
        case let line as GStyleInfoLine:
            dict["type"]     = 2
            dict["colorHex"] = line.colorHex
            dict["width"]    = line.width
            dict["alpha"]    = line.alpha
            
        case let polygon as GStyleInfoPolygon:
            dict["type"]     = 3
            dict["colorHex"] = polygon.colorHex
            dict["width"]    = polygon.width
            dict["alpha"]    = polygon.alpha
            
        default:
            assertionFailure("Unknown style info: \(style)")
        }
        
        return dict
    }
    
    internal class func dictToStyle(dict:Dictionary<String,AnyObject>) -> GStyleInfo  {
        
        
        let type = dict["type"] as Int
        
        switch type {
        case 1:
            let iconID   = dict["iconID"] as Int
            let colorHex = dict["colorHex"] as String
            let scale    = dict["scale"] as Double
            return GStyleInfoPoint(iconID: iconID, colorHex: colorHex, scale: scale)
            
        case 2:
            let colorHex = dict["colorHex"] as String
            let width    = dict["width"] as Int
            let alpha    = dict["alpha"] as Double
            return GStyleInfoLine(colorHex: colorHex, width: width, alpha: alpha)
            
        case 3:
            let colorHex = dict["colorHex"] as String
            let width    = dict["width"] as Int
            let alpha    = dict["alpha"] as Double
            return GStyleInfoPolygon(colorHex: colorHex, width: width, alpha: alpha)
            
        default:
            assertionFailure("Unknown style info type: \(type)")
        }
        
    }
}



//========================================================================================================================
public class GStyle : GAsset {
    
    unowned public let layer : GLayer
    
    public var titlePropName : String = ""
    
    
    //------------------------------------------------------------------------------------------------------------------------
    internal init(gid:String, layer:GLayer) {
        
        self.layer = layer
        super.init(gid:gid)
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    required public init(coder decoder: NSCoder) {
        
        layer = decoder.decodeObjectForKey("ownerLayer") as GLayer
        
        super.init(coder: decoder)
        
        titlePropName = decoder.decodeObjectForKey("titlePropName") as NSString
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    override public func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(layer, forKey: "ownerLayer")
        
        super.encodeWithCoder(aCoder)
        
        aCoder.encodeObject(titlePropName, forKey: "titlePropName")
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    override internal var _assetClassName : String {
        return "GStyle";
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    override internal func _debugDescriptionInner(inout strVal:String, padding:String, tabIndex:UInt) {
        
        super._debugDescriptionInner(&strVal, padding: padding, tabIndex:tabIndex)
        
        strVal += "\(padding)titlePropName: '\(titlePropName)'\n"
    }
    
}