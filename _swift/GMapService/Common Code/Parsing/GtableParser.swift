//
//  GtableParser.swift
//  GMapService
//
//  Created by Jose Zarzuela on 31/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation
import JZBUtils


internal class GTableParser : GBaseParser {
    
    //------------------------------------------------------------------------------------------------------------------------
    internal class func parseAllTablesFromArray(ownerMap:GMap, data:Array<TArrayValue>) {
        
        // Itera el array con los items que contienen la informacion de las diferentes tablas
        for tableArray in data {
            
            _parseTableFromArray(ownerMap, data: tableArray)
        }
        
    }
    
    
    //------------------------------------------------------------------------------------------------------------------------
    private class func _parseTableFromArray(ownerMap:GMap, data:TArrayValue) {
        
        // Define la informacion necesaria para acceder a los elementos del array
        let tableData = Template("table", data:data)
        tableData.define(
            Field(name: "gid",         type:.FT_String, indexes:[0]),
            Field(name: "schemaArray", type:.FT_Array,  indexes:[2,0]))
        
        
        // Construye una instancia de GTable con los datos obtenidos
        let table_id = tableData["gid"].string
        let table = _searchTable(ownerMap, tableGID: table_id)
        
        _parseSchema(table, data: tableData["schemaArray"].array)
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private class func _parseSchema(table:GTable, data:Array<TArrayValue>) {
        
        for schemaArray in data {
            
            // Define la informacion necesaria para acceder a los elementos del array
            let schemaData = Template("schemaData", data:schemaArray)
            schemaData.define(
                Field(name: "prop_name", type:.FT_String, indexes:[0]),
                Field(name: "prop_type", type:.FT_Int64,  indexes:[1]))
            
            // Construye una instancia de property con los datos obtenidos
            let typeValue = Int(schemaData["prop_type"].int64)
            let propType = _propTypeFromValue(typeValue)
            let propName = schemaData["prop_name"].string
            
            table.addSchemaItem(propName, type: propType)
            
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private class func _propTypeFromValue(value:Int) -> GESchemaType! {
        
        if let type = GESchemaType(rawValue: value) {
            return type
        } else {
            return _throwExceptionNil("Unknown schema property type: \(value)")
        }
    }
}