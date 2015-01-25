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
    public func createMap(inout error:NSError?) -> GMap? {
        
        // Se debe estar logado para poder pedir informacion al servicio remoto
        if let error = _checkIfLoggedIn() {
            return nil
        }
        
        // Necesita un xsrfToken para la peticion
        if let xsrfToken = getXsrfToken(&error) {
            
            // Realiza la peticion de creacion
            if let jsonData = _requestCreateMap(xsrfToken, error:&error) {
                
                // Parseamos el mapa desde la informacion JSON
                if let map = _createMapFromJSON(jsonData, error: &error) {
                    return map
                }
                
            }
            
        }
        
        // Algo ha salido mal y no hay mapa
        return nil
        
    }
    
    
    //========================================================================================================================
    // MARK: Private support methods
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _requestCreateMap(xsrfToken:String, inout error:NSError?) -> JSON? {
        
        log.debug("Creating new Map")
        
        
        // Hace la peticion de creacion de mapa
        let request = GMapURLConnection.POST("https://mapsengine.google.com/map/new",
            queryParams:[
                ("cid", "mp"),
                ("cv", "xxxxxxxxxxx.en."),
                ("_reqid", "\(arc4random_uniform(1000000))"),
                ("rt", "j")],
            bodyParams: [
                ("at", xsrfToken)])
        
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