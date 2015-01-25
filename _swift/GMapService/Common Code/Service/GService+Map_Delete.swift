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
    public func deleteMap(map:GMap, inout error:NSError?) -> Bool {
        
        // Se debe estar logado para poder pedir informacion al servicio remoto
        if let error = _checkIfLoggedIn() {
            return false
        }
        
        // Necesita un xsrfToken para la peticion
        if let xsrfToken = getXsrfToken(&error) {
            
            // Realiza la peticion de actualizacion
            return _requestDeleteMap(map, xsrfToken:xsrfToken, error:&error)
            
        }
        
        // Algo ha salido mal
        return false
    }
    
    
    //========================================================================================================================
    // MARK: Private support methods
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _requestDeleteMap(map:GMap, xsrfToken:String, inout error:NSError?) -> Bool {
        
        log.debug("Deleting Map: name = '\(map.name)', gid = '\(map.gid)'")
        
        
        // Hace la peticion de creacion de mapa
        let request = GMapURLConnection.POST("https://mapsengine.google.com/map/delete",
            queryParams:[
                ("cid", "mp"),
                ("cv", "xxxxxxxxxxx.en.")],
            bodyParams: [
                ("at", xsrfToken),
                ("mid", map.gid)])
        
        if let reqRsp = GMapURLConnection.sendSynchronousRequest(request, cookies:googleLoginCookies!, error:&error) {
            
            return true
            
        } else {
            
            return false
        }
        
    }
    
}