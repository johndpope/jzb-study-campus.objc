//
//  FeatureParser.swift
//  GMapService
//
//  Created by Jose Zarzuela on 31/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation
import JZBUtils


private let PARSING_EXCEPTION = "PARSING_EXCEPTION"


internal class GBaseParser {
    
    //------------------------------------------------------------------------------------------------------------------------
    internal class func parseStrArrays(dataArray:Array<TArrayValue>?, inout error:NSError?) -> GMap? {
        
        var map : GMap? = try(
            {
                //prettyPrint(dataArray!, showAllIndexes:false)
                let map = self._parseStrArrays(dataArray)
                return map
            },
            catch: { (ex:NSException!) -> Void in
                error = _error("Error creating map instance from parsing array Info: \(ex.reason)")
            }
        )
        
        return map
        
    }
    //------------------------------------------------------------------------------------------------------------------------
    private class func _parseStrArrays(dataArray:Array<TArrayValue>?) -> GMap {
        
        // Define la informacion necesaria para acceder a los elementos del array
        let globalData = Template("global", data:dataArray)
        globalData.define(
            Field(name: "mapInfo",      type: .FT_Array, indexes: [0]),
            Field(name: "layersInfo",   type: .FT_Array, indexes: [1]),
            Field(name: "tablesInfo",   type: .FT_Array, indexes: [2]),
            Field(name: "stylesInfo",   type: .FT_Array, indexes: [3]),
            Field(name: "featuresInfo", type: .FT_Array, indexes: [4]))
        
        
        // Parsea la informacion del mapa, que esta en el array con indice [0]
        let map = GMapParser.parseMapFromArray(globalData["mapInfo"].array)
        
        // Parsea la informacion de las capas, que esta en el array con indice [1]
        GLayerParser.parseAllLayersFromArray(map, data:globalData["layersInfo"].array)
        
        // Parsea la informacion de las tablas, que esta en el array con indice [2]
        GTableParser.parseAllTablesFromArray(map, data:globalData["tablesInfo"].array)
        
        // Parsea la informacion de las features, que esta en el array con indice [4]
        // PRIMERO LAS FEATURES PARA HACER UN PARSEO GUIADO DE LOS ESTILOS
        GFeatureParser.parseAllFeaturesFromArray(map, data:globalData["featuresInfo"].array)
        
        // Parsea la informacion de los styles, que esta en el array con indice [3]
        GStyleParser.parseAllStylesFromArray(map, data:globalData["stylesInfo"].array)
        
        // Retorna la instancia del mapa creado
        return map
        
    }
    
    //=====================================================================================================
    // MARK: "Protected" (private) util methods

    //------------------------------------------------------------------------------------------------------------------------
    internal class func _searchTable(ownerMap:GMap, tableGID:String) -> GTable! {
        
        for layer in ownerMap.layers {
            if layer.table.gid == tableGID {
                return layer.table
            }
        }
        
        return _throwExceptionNil("Table not found for table_gid = '\(tableGID)'")
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    internal class func _searchStyle(ownerMap:GMap, styleGID:String) -> GStyle! {
        
        for layer in ownerMap.layers {
            if layer.style.gid == styleGID {
                return layer.style
            }
        }
        
        return _throwExceptionNil("Stytle not found for style_gid = '\(styleGID)'")
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    internal class func _searchFeature(ownerMap:GMap, featureGID:String) -> GFeature? {
        
        for layer in ownerMap.layers {
            for feature in layer.table.features {
                if feature.gid == featureGID {
                    return feature
                }
            }
        }
        
        // No la ha encontrado
        return nil
    }
    
    
    //------------------------------------------------------------------------------------------------------------------------
    internal class func _throwException(msg:String) {
        throw(PARSING_EXCEPTION, "Error while parsing: \(msg)")
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    internal class func _throwExceptionNil<T>(msg:String) -> T! {
        throw(PARSING_EXCEPTION, "Error while parsing: \(msg)")
        return nil
    }
    
}