//
//  GTable.swift
//  GMapService
//
//  Created by Jose Zarzuela on 24/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation
import JZBUtils


//========================================================================================================================
public enum GESchemaType : Int, Printable, DebugPrintable {
    
    case ST_DIRECTIONS = 99 // Coincide con el 1 de BOOL!!!!
    case ST_BOOL = 1
    case ST_NUMERIC = 2
    case ST_STRING = 3
    case ST_DATE = 4
    // Que pasa con el 5????
    case ST_GEOMETRY = 6
    case ST_GX_METADATA = 7
    
    public var debugDescription : String {
        
        let stringValues : Dictionary<GESchemaType, String> = [
            ST_DIRECTIONS  : "ST_DIRECTIONS",
            ST_BOOL        : "ST_BOOL",
            ST_NUMERIC     : "ST_NUMERIC",
            ST_STRING      : "ST_STRING",
            ST_DATE        : "ST_DATE",
            ST_GEOMETRY    : "ST_GEOMETRY",
            ST_GX_METADATA : "ST_GX_METADATA"]
        
        let strVal = stringValues[self] ?? "ST_UNKNOWN"
        return strVal
    }
    
    public var description : String {
        return debugDescription
    }
}

//========================================================================================================================
// Nombres de columnas especiales reservadas
internal let PROPNAME_GX_IMAGE_LINKS   = "gx_image_links"
internal let PROPNAME_PLACE_REF        = "place_ref"
internal let PROPNAME_GME_GEOMETRY     = "gme_geometry_"
internal let PROPNAME_FEATURE_ORDER    = "feature_order"
internal let PROPNAME_GX_METAFEATUREID = "gx_metafeatureid"
internal let PROPNAME_GX_ROUTE_INFO    = "gx_routeinfo"
internal let PROPNAME_GX_METADATA      = "gx_metadata"
internal let PROPNAME_IS_DIRECTIONS    = "is_directions"




//========================================================================================================================
public class GTable : GAsset {
    
    unowned public let layer:GLayer
    
    private(set) public var schema = OrderedDictionary<String, (type:GESchemaType, sysProp:Bool)>()
    private(set) public var features = Array<GFeature>()
    
    //------------------------------------------------------------------------------------------------------------------------
    internal init(gid:String, layer:GLayer) {
        
        self.layer = layer
        super.init(gid:gid)
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    required public init(coder decoder: NSCoder) {
        
        layer = decoder.decodeObjectForKey("ownerLayer") as GLayer
        
        super.init(coder: decoder)
        
        // schema: Se puede asi porque esta ordenado
        let keys = decoder.decodeObjectForKey("schema_keys") as Array<String>
        let values = decoder.decodeObjectForKey("schema_values") as Array<Int>
        for (index,key) in enumerate(keys) {
            let sysProp = _isSystemProperty(key)
            schema[key] = (GESchemaType(rawValue:values[index])!, sysProp)
        }
        
        features = decoder.decodeObjectForKey("features") as [GFeature]
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    override public func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(layer, forKey: "ownerLayer")
        
        super.encodeWithCoder(aCoder)
        
        // schema: Se puede asi porque esta ordenado
        aCoder.encodeObject(Array(schema.keys), forKey: "schema_keys")
        let values :Array<Int> = map(schema.values){ $0.0.rawValue }
        aCoder.encodeObject(values, forKey: "schema_values")
        
        aCoder.encodeObject(features, forKey: "features")
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    internal func addSchemaItem(name:String, type:GESchemaType) {
        
        let sysProp = _isSystemProperty(name)
        schema[name] = (type, sysProp)
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private func removeSchemaItem(name:String) {
        
        // TODO: OJO!!!! Esto borraria informacion en la features
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private func featureByID(feature_gid:String) -> GFeature? {
        
        for feature in features {
            if feature.gid == feature_gid {
                return feature
            }
        }
        
        return nil
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    public func createFeature(geoType:GFeature.GeoType) -> GFeature {
        
        let feature = GFeature(gid: GAsset.generateGID(), table: self, geoType:geoType)
        features.append(feature)
        return feature
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    internal func addFeatureWithID(featureGID:String, geoType:GFeature.GeoType) -> GFeature {

        assert(featureByID(featureGID) == nil, "Can't add feature with already existing GID")
        
        let feature = GFeature(gid: featureGID, table: self, geoType: geoType)
        features.append(feature)
        return feature
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _isSystemProperty(name:String) -> Bool {
    
        if name.hasPrefix("gx_") || name.hasPrefix("gme_") || name == "feature_order" || name == "place_ref" || name == "is_directions" {
            return true
        } else {
            return false
        }

    }
    
    //------------------------------------------------------------------------------------------------------------------------
    override internal var _assetClassName : String {
        return "GTable";
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    override internal func _debugDescriptionInner(inout strVal:String, padding:String, tabIndex:UInt) {
        
        super._debugDescriptionInner(&strVal, padding: padding, tabIndex:tabIndex)
        
        strVal += "\(padding)schema: {\n"
        for propName in schema.keys {
            strVal += "\(padding)    \(propName) - \(schema[propName])\n"
        }
        strVal += "\(padding)}\n"
        
        strVal += "\(padding)features: {\n"
        for feature in features {
            strVal += feature._debugDescription(tabIndex+1)
            strVal += "\n"
        }
        strVal += "\(padding)}\n"
    }
    
}