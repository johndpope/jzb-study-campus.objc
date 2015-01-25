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
    public func updateMap(map:GMap, inout error:NSError?) -> Bool {
        
        // Se debe estar logado para poder pedir informacion al servicio remoto
        if let error = _checkIfLoggedIn() {
            return false
        }
        
        // Necesita un xsrfToken para la peticion
        if let xsrfToken = getXsrfToken(&error) {
            
            // Realiza la peticion de actualizacion
            return _requestUpdateMap(map, xsrfToken:xsrfToken, error:&error)
            
        }
        
        // Algo ha salido mal
        return false
        
    }
    
    
    //========================================================================================================================
    // MARK: Private support methods
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _requestUpdateMap(map:GMap, xsrfToken:String, inout error:NSError?) -> Bool {
        
        log.debug("Updating Map: name = '\(map.name)', gid = '\(map.gid)'")
        
        
        // Genera la cadena de la peticion
        let baseMap = "1" // Normal, 3 - Satellite
        let viewPort = "[0.83,25.88,53.67,46.33]"
        let reqStr = "[\"\(map.gid)\",null,null,null,null,null,null,[\(baseMap),[]],[\"\(map.name)\",\"\(map.desc)\",\(viewPort)],null,null,null,null,null,null,null,[[]]]"
        
        // Hace la peticion de creacion de mapa
        let request = GMapURLConnection.POST("https://mapsengine.google.com/map/save",
            queryParams:[
                ("cid", "mp"),
                ("cv", "xxxxxxxxxxx.en."),
                ("_reqid", "\(arc4random_uniform(1000000))"),
                ("rt", "j")],
            bodyParams: [
                ("f.req", reqStr),
                ("at", xsrfToken)])
        
        if let reqRsp = GMapURLConnection.sendSynchronousRequest(request, cookies:googleLoginCookies!, error:&error) {
            
            return true
            
        } else {
            
            return false
        }
        
    }
    
}