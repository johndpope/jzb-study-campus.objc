//
//  GStyleParser.swift
//  GMapService
//
//  Created by Jose Zarzuela on 31/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation
import JZBUtils


internal class GStyleParser : GBaseParser {
    
    //------------------------------------------------------------------------------------------------------------------------
    internal class func parseAllStylesFromArray(ownerMap:GMap, data:Array<TArrayValue>) {
        
        for styleArray in data {
            
            _parseStyleFromArray(ownerMap, data: styleArray)
        }
    }
    
    
    //------------------------------------------------------------------------------------------------------------------------
    private class func _parseStyleFromArray(ownerMap:GMap, data:TArrayValue) {
        
        // Define la informacion necesaria para acceder a los elementos del array
        let styleData = Template("styleData", data:data)
        styleData.define(
            Field(name: "gid",           type:.FT_String,  indexes:[0]),
            Field(name: "stylesArray",   type:.FT_Array,   indexes:[2]))
        
        // Construye una instancia de GStyle con los datos obtenidos
        let style_id = styleData["gid"].string
        // TODO: SOLO ENTENDENMOS ESTE TIPO DE ESTILO
        let style : GStyleIndividual = _searchStyle(ownerMap, styleGID: style_id) as GStyleIndividual
        
        let stylesArray = styleData["stylesArray"].array
        _parseAllStylesArray(ownerMap, style:style, data: stylesArray)
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private class func _parseAllStylesArray(ownerMap:GMap, style:GStyleIndividual, data:Array<TArrayValue>) {
        
        for styleArray in data {
            
            // Define la informacion necesaria para acceder a los elementos del array
            let styleData = Template("styleArray", data:styleArray)
            styleData.define(
                Field(name: "featureInfo",    type:.FT_Array,  indexes:[0], optional:true),
                Field(name: "styleInfoArray", type:.FT_Array,  indexes:[1], optional:false))
            
            
            let styleInfoArray = styleData["styleInfoArray"].array
            
            // Si el primer array ESTA vacio se trata del estilo GLOBAL de la capa. Sino, es el de una feature
            if styleData["featureInfo"].optArray != nil {
                
                styleData.define(Field(name: "featureInfo.id", type:.FT_String, indexes:[0, 1, 2, 1, 0, 4], optional:false))
                let feature_id = styleData["featureInfo.id"].string
                
                // Solo parsea si REALMENTE (faltan las borradas) hay una feature a la que aplicar el estilo
                if let feature = _searchFeature(ownerMap, featureGID: feature_id) {
                    
                    var featureStyle : GStyleInfo?
                    
                    switch feature.geometry {
                    case let x as GGeometryPoint:
                        featureStyle = _parsePointStyleArray(style, data: styleInfoArray, defIconId:nil)
                    case let x as GGeometryLine:
                        featureStyle = _parseLineStyleArray(style, data: styleInfoArray, defColor:nil)
                    case let x as GGeometryPolygon:
                        featureStyle = _parsePolygonStyleArray(style, data: styleInfoArray, defColor:nil)
                    default:
                        _throwException("Unknown feature geometry. Can't apply individual style")
                    }
                    
                    if featureStyle != nil {
                        style[feature]=featureStyle!
                    }
                }
                
            } else {
                
                styleData.define(
                    Field(name: "titlePropName",  type:.FT_String, indexes:[1, 0, 5, 0, 0], optional:false))
                
                let titlePropName = styleData["titlePropName"].string
                style.titlePropName = titlePropName
                
                style.defaultPointStyle = _parsePointStyleArray(style, data: styleInfoArray, defIconId:Int64(STYLE_DEFAULT_ICON_ID))!
                style.defaultLineStyle = _parseLineStyleArray(style, data: styleInfoArray, defColor:STYLE_DEFAULT_COLOR)!
                style.defaultPolygonStyle = _parsePolygonStyleArray(style, data: styleInfoArray, defColor:STYLE_DEFAULT_COLOR)!
                
            }
        }
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private class func _parsePointStyleArray(style:GStyle, data:Array<TArrayValue>, defIconId:Int64?) -> GStyleInfoPoint? {
        
        // Define la informacion necesaria para acceder a los elementos del array
        let iconStyleData = Template("pointStyleData", data:data)
        iconStyleData.define(
            Field(name: "icon_id",    type:.FT_Int64,  indexes:[0,0],   optional:true),
            Field(name: "icon_color", type:.FT_String, indexes:[0,3,0], optional:true),
            Field(name: "icon_scale", type:.FT_Double, indexes:[0,3,1], optional:true))
        
        
        // Debe tener un id de icono, en otro caso utilizara el valor por defecto del estilo
        if let icon_id = iconStyleData["icon_id"].optInt64 ?? defIconId {
            
            let icon_color = iconStyleData["icon_color"].optString ?? STYLE_DEFAULT_COLOR
            let icon_scale = iconStyleData["icon_scale"].optDouble ?? STYLE_DEFAULT_SCALE
            
            let iconStyle = GStyleInfoPoint(
                iconID:Int(icon_id),
                colorHex:icon_color,
                scale:icon_scale)
            
            return iconStyle
            
        } else {
            
            return nil
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private class func _parseLineStyleArray(style:GStyle, data:Array<TArrayValue>, defColor:String?) -> GStyleInfoLine? {
        
        // Define la informacion necesaria para acceder a los elementos del array
        let lineStyleData = Template("lineStyleData", data:data)
        lineStyleData.define(
            Field(name: "line_width", type:.FT_Int64,  indexes:[1,0],   optional:true),
            Field(name: "line_color", type:.FT_String, indexes:[1,1,0], optional:true),
            Field(name: "line_alpha", type:.FT_Double, indexes:[1,1,1], optional:true))
        
        
        // Debe tener un color, en otro caso utilizara el valor por defecto del estilo
        if let line_color = lineStyleData["line_color"].optString ?? defColor {
            
            let line_width = lineStyleData["line_width"].optInt64  ?? Int64(STYLE_DEFAULT_WIDTH)
            let line_alpha = lineStyleData["line_alpha"].optDouble ?? STYLE_DEFAULT_ALPHA
            
            let lineStyle = GStyleInfoLine(
                colorHex:line_color,
                width:Int(line_width),
                alpha:line_alpha)
            
            return lineStyle
            
        } else {
            return nil
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private class func _parsePolygonStyleArray(style:GStyle, data:Array<TArrayValue>, defColor:String?) -> GStyleInfoPolygon? {
        
        // Define la informacion necesaria para acceder a los elementos del array
        let polygonStyleData = Template("polygonStyleData", data:data)
        polygonStyleData.define(
            Field(name: "polygon_width", type:.FT_Int64,  indexes:[2,1],   optional:true),
            Field(name: "polygon_color", type:.FT_String, indexes:[2,0,0], optional:true),
            Field(name: "polygon_alpha", type:.FT_Double, indexes:[2,0,1], optional:true))
        
        
        // Debe tener un color, en otro caso utilizara el valor por defecto del estilo
        if let polygon_color = polygonStyleData["polygon_color"].optString ?? defColor {
            
            let polygon_width = polygonStyleData["polygon_width"].optInt64  ?? Int64(STYLE_DEFAULT_WIDTH)
            let polygon_alpha = polygonStyleData["polygon_alpha"].optDouble ?? STYLE_DEFAULT_ALPHA
            
            let polygonStyle = GStyleInfoPolygon(
                colorHex:polygon_color,
                width:Int(polygon_width),
                alpha:polygon_alpha)
            
            return polygonStyle
            
        } else {
            return nil
        }
    }
    
}