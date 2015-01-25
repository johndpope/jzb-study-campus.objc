//
//  PropertyValueParser.swift
//  GMapService
//
//  Created by Jose Zarzuela on 31/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation
import JZBUtils



internal class GPropertyValueParser : GBaseParser {
    
    //------------------------------------------------------------------------------------------------------------------------
    internal class func parseAllPropertiesFromArray(ownerTable:GTable, data:Array<TArrayValue>) -> Dictionary<String,GPropertyType?> {

        var properties = Dictionary<String,GPropertyType?>()
        
        for propArray in data {
            
            // Define la informacion necesaria para acceder a los elementos del array
            let propData = Template("propertyData", data:propArray)
            propData.define(Field(name: "propName", type: .FT_String, indexes: [0]))
            
            
            var prop_name = propData["propName"].string
            var schema_info = ownerTable.schema[prop_name]
            var prop_value = _parsePropValue(propData, name:prop_name, type:schema_info?.type)
            
            // Añade la propiedad parseada
            properties[prop_name] = prop_value
        }
        
        // Indica que todo fue bien
        return properties
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private class func _parsePropValue(propData: Template, name:String, type: GESchemaType?) -> GPropertyType? {
        
        switch type! {
            
        case .ST_DIRECTIONS:
            return _throwExceptionNil("Can't parse yet property '\(name)' of type '\(type?.debugDescription)'")
            
        case .ST_BOOL:
            return _parseValueTypeBool(propData)
            
        case .ST_NUMERIC:
            return _parseValueTypeNumeric(propData)
            
        case .ST_STRING:
            return _parseValueTypeString(propData)
            
        case .ST_DATE:
            return _parseValueTypeDateTime(propData)
            
        case .ST_GEOMETRY:
            return _parseValueTypeGeometry(propData)
            
        case .ST_GX_METADATA:
            return _parseValueTypeGxMetadata(propData)
            
        default:
            return _throwExceptionNil("Can't parse property '\(name)' of unknown type '\(type?.debugDescription)'")
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private class func _parseValueTypeDateTime(propData: Template) -> Int64? {
        
        // Define MAS informacion necesaria para acceder a los elementos del array
        propData.define(Field(name: "propValue.dateTime", type: .FT_Int64, indexes: [5], optional:true))
        
        let intValue = propData["propValue.dateTime"].optInt64
        println(NSDate(timeIntervalSince1970: Double(intValue!)/1000000))
        // Mon Jan 01 2001 00:00:00 GMT+0100 (CET)
        return intValue;
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private class func _parseValueTypeNumeric(propData: Template) -> Double? {
        
        // Define MAS informacion necesaria para acceder a los elementos del array
        propData.define(Field(name: "propValue.numeric", type: .FT_Double, indexes: [3], optional:true))
        
        let doubleValue = propData["propValue.numeric"].optDouble
        return doubleValue;
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private class func _parseValueTypeString(propData: Template) -> String? {
        
        // Define MAS informacion necesaria para acceder a los elementos del array
        propData.define(Field(name: "propValue.string", type: .FT_String, indexes: [4], optional:true))
        
        let strValue = propData["propValue.string"].optString
        return strValue;
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private class func _parseValueTypeBool(propData: Template) -> Bool? {
        
        // Define MAS informacion necesaria para acceder a los elementos del array
        propData.define(Field(name: "propValue.bool", type: .FT_Int64, indexes: [2], optional:true))
        
        let intValue = propData["propValue.bool"].optInt64
        return intValue != 0;
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private class func _parseValueTypeGxMetadata(propData: Template) -> String? {
        
        // TODO: Esto como se hace?
        //println("*** gx_metadata --> \(propData.data)")

        // Define MAS informacion necesaria para acceder a los elementos del array
        propData.define(Field(name: "propValue.gx_metadata", type: .FT_String, indexes: [4], optional:true))

        let gxmValue = propData["propValue.gx_metadata"].optString
        return gxmValue;
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private class func _parseValueTypeGeometry(propData: Template) -> GGeometry? {
        
        // Define MAS informacion necesaria para acceder a los elementos del array
        propData.define(
            Field(name: "propValue.geometry.point",    type: .FT_Array,  indexes: [6,0,0], optional:true),
            Field(name: "propValue.geometry.line",     type: .FT_Array,  indexes: [6,1,0,0], optional:true),
            Field(name: "propValue.geometry.polygone", type: .FT_Array,  indexes: [6,2,0,0,0,0], optional:true))
        
        
        // Si el PRIMER array no esta vacio es un PUNTO
        if let pointArray = propData["propValue.geometry.point"].optArray {
            return _parsePointCoordinates(pointArray)
        }
        
        // Si el SEGUNDO array no esta vacio es una LINEA
        if let lineArray = propData["propValue.geometry.line"].optArray {
            
            var geoPoints = [GGeometryPoint]()
            for item in lineArray {
                let geoPoint = _parsePointCoordinates(item)
                geoPoints.append(geoPoint)
            }
            return GGeometryLine(points: geoPoints)
        }
        
        // Si el TERCER array no esta vacio es un POLIGONO
        if let polygonArray = propData["propValue.geometry.polygon"].optArray {
            
            var geoPoints = [GGeometryPoint]()
            for item in polygonArray {
                let geoPoint = _parsePointCoordinates(item)
                geoPoints.append(geoPoint)
            }
            return GGeometryPolygon(points: geoPoints)
        }
        
        // TODO: No sabemos que es
        return _throwExceptionNil("Cannot parse feature geometry (not a point, line nor polygon")
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private class func _parsePointCoordinates(data:TArrayValue) -> GGeometryPoint! {
        
        // Define la informacion necesaria para acceder a los elementos del array
        let coordData = Template("coordData", data:data)
        coordData.define(
            Field(name: "coord.lat", type: .FT_Double, indexes: [0]),
            Field(name: "coord.lng", type: .FT_Double, indexes: [1]))
        
        let lat = coordData["coord.lat"].double
        let lng = coordData["coord.lng"].double
        
        return GGeometryPoint(lng: lng, lat: lat)
    }
    
}