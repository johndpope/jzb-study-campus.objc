//
//  GLayerParser.swift
//  GMapService
//
//  Created by Jose Zarzuela on 31/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation
import JZBUtils


internal class GLayerParser : GBaseParser {
    
    //------------------------------------------------------------------------------------------------------------------------
    internal class func parseAllLayersFromArray(ownerMap:GMap, data:Array<TArrayValue>) {
        
        // Itera el array con los items que contienen la informacion de las diferentes layers
        for layerArray in data {
            
            _parseLayerFromArray(ownerMap, data: layerArray)
        }
    }
    
    
    //------------------------------------------------------------------------------------------------------------------------
    private class func _parseLayerFromArray(ownerMap:GMap, data:TArrayValue) {
        
        // Define la informacion necesaria para acceder a los elementos del array
        let layerData = Template("layerData", data:data)
        layerData.define(
            Field(name: "gid",              type:.FT_String, indexes:[0]),
            Field(name: "name",             type:.FT_String, indexes:[1]),
            Field(name: "creationTime",     type:.FT_Int64,  indexes:[7,1]),
            Field(name: "lastModifiedTime", type:.FT_Int64,  indexes:[7,3]),
            Field(name: "style_id",         type:.FT_String, indexes:[3,0]),
            Field(name: "table_id",         type:.FT_String, indexes:[4,0]))
        
        
        // Construye una instancia de GLayer con los datos obtenidos
        let layer_id = layerData["gid"].string
        let style_id = layerData["style_id"].string
        let table_id = layerData["table_id"].string
        let layer = ownerMap.addLayerWithID(layer_id, tableGID: table_id, styleGID: style_id)
        
        layer.name = layerData["name"].string
        layer.creationTime = layerData["creationTime"].int64
        layer.lastModifiedTime = layerData["lastModifiedTime"].int64
    }
    
}