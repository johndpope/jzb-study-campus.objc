//
//  GService+GetMapData.swift
//  GMapService
//
//  Created by Jose Zarzuela on 24/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation
import JZBUtils



//============================================================================================================================
public extension GService {
    
    
    //------------------------------------------------------------------------------------------------------------------------
    public func getMapData(mapGID:String, inout error:NSError?) -> GMap? {
        
        // Se debe estar logado para poder pedir informacion al servicio remoto
        if let error = _checkIfLoggedIn() {
            return nil
        }
        
        
        // Comprueba si ya esta el mapa cacheado en binario
        if let map = cacheMapInfo.readMap(mapGID) {
            return map
        }
        
        
        // Intenta conseguir la informacion JSON de la cache
        // Sino, la consigue desde la web y la guarda en la cache
        var jsonData = cacheMapInfo.readJSONMapData(mapGID)
        if jsonData == nil {
            jsonData = _fetchMapData(mapGID, error:&error)
            if jsonData != nil {
                cacheMapInfo.writeJSONMapData(mapGID, json: jsonData!)
            } else {
                // Tenemos un error
                return nil
            }
        }

        // Parseamos el mapa desde la informacion JSON
        let map = _createMapFromJSON(jsonData!, error: &error)
        return map
        
    }
    
    
    //========================================================================================================================
    // MARK: Private support methods
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _fetchMapData(mapGID:String, inout error:NSError?) -> JSON? {
        
        log.debug("Getting Map data")
        
        // Hace la peticion del mapa indicado (gid)
        let request = GMapURLConnection.GET("https://www.google.com/maps/d/edit", params: [
            ("mid"      , mapGID),
            ("authuser" , "0"),
            ("hl"       , "en")])
        
        if let reqRsp = GMapURLConnection.sendSynchronousRequest(request, cookies:googleLoginCookies!, error:&error) {
            
            // Lee la parte JSON con los datos del mapa
            let responseBody = _getResponseBodyText(reqRsp.data)
            
            let json : JSON! = _extractJSONPageData(responseBody, error: &error)
            if json == nil {
                return nil
            }
            
            // La chequea
            if json["isPartialResult"].boolValue {
                error = _error("Invalid JSON response found: isPartialResult=true")
                return nil
            }
            
            let fieldsToCheck = ["mapdataJson", "userToken", "xsrfToken"]
            for fieldName in fieldsToCheck {
                if json[fieldName].object is NSNull {
                    error = _error("Invalid JSON response found: '\(fieldName)'=null")
                    return nil
                }
            }
            
            // Devuelve la respuesta
            return json
            
        } else {
            
            // Algo fue mal
            return nil
        }
        
    }
    
}