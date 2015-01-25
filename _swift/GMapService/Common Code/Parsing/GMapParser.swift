//
//  GMapParser.swift
//  GMapService
//
//  Created by Jose Zarzuela on 30/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation



internal class GMapParser : GBaseParser {
    
    //------------------------------------------------------------------------------------------------------------------------
    internal class func parseMapFromArray(data:Array<TArrayValue>) -> GMap {
        
        // prettyPrint(data)
        
        // Define la informacion necesaria para acceder a los elementos del array
        let mapData = Template("mapData", data:data)
        mapData.define(
            Field(name: "gid",              type:.FT_String, indexes:[0]),
            Field(name: "name",             type:.FT_String, indexes:[1]),
            Field(name: "desc",             type:.FT_String, indexes:[2], optional:true),
            Field(name: "creationTime",     type:.FT_Int64,  indexes:[5,1]),
            Field(name: "lastModifiedTime", type:.FT_Int64,  indexes:[5,3]))
        
        
        // Construye una instancia de GMap con los datos obtenidos
        let mapGID = mapData["gid"].string
        let map = GMap(gid: mapGID)
        map.name = mapData["name"].string
        map.desc = mapData["desc"].string
        map.creationTime = mapData["creationTime"].int64
        map.lastModifiedTime = mapData["lastModifiedTime"].int64
        
        // Retorna la instancia creada
        return map
    }
    
}