//
//  FeatureParser.swift
//  GMapService
//
//  Created by Jose Zarzuela on 31/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation
import JZBUtils


internal class GFeatureParser : GBaseParser {
    
    //------------------------------------------------------------------------------------------------------------------------
    internal class func parseAllFeaturesFromArray(ownerMap:GMap, data:Array<TArrayValue>) {
        
        for tableArray in data {
            
            _parseTableFeaturesFromArray(ownerMap, data: tableArray)
        }
    }
    
    
    //------------------------------------------------------------------------------------------------------------------------
    private class func _parseTableFeaturesFromArray(ownerMap:GMap, data:TArrayValue) {
        
        // Define la informacion necesaria para acceder a los elementos del array
        let tableFeaturesData = Template("tableFeaturesData", data:data)
        tableFeaturesData.define(
            Field(name: "table_id",      type:.FT_String, indexes:[0]),
            Field(name: "featuresArray", type:.FT_Array,  indexes:[2]))
        
        
        // Construye una instancia de GTable con los datos obtenidos
        let table_id = tableFeaturesData["table_id"].string
        let ownerTable = _searchTable(ownerMap, tableGID: table_id)
        
        for featureArray in tableFeaturesData["featuresArray"].array {

            // Tabla sin ninguna feature
            if !(featureArray is NSNull) {
                _parseFeatureFromArray(ownerTable, data: featureArray)
            }
        }
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private class func _parseFeatureFromArray(ownerTable:GTable, data:TArrayValue) {
        
        // Define la informacion necesaria para acceder a los elementos del array
        let featureData = Template("featureData", data:data)
        featureData.define(
            Field(name: "gid",          type:.FT_String, indexes:[0]),
            Field(name: "propertyArray", type:.FT_Array, indexes:[11]))
        
        
        // Construye una instancia de GFeature con los datos obtenidos
        let featureID = featureData["gid"].string
        let propsArray = featureData["propertyArray"].array
        
        let properties = GPropertyValueParser.parseAllPropertiesFromArray(ownerTable, data: propsArray)
        
        let geoType = _getGeometryType(featureID, properties: properties)
        
        let feature = ownerTable.addFeatureWithID(featureID, geoType:geoType)
        
        // Le añade todas las propiedades
        feature.addProperties(properties)
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private class func _getGeometryType(featureID:String, properties:Dictionary<String,GPropertyType?>) -> GFeature.GeoType {
        
        let geometry = properties["gme_geometry_"]
        
        switch geometry {
        case let v as GGeometryPoint:
            return GFeature.GeoType.POINT
        case let v as GGeometryLine:
            return GFeature.GeoType.LINE
        case let v as GGeometryPolygon:
            return GFeature.GeoType.POLYGON
        default:
            return _throwExceptionNil("Feature '\(featureID)' must have 'gme_geometry_' property with adequate type: \(geometry)")
        }
    }
    
}