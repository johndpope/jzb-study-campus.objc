//
//  GService.swift
//  GMapService
//
//  Created by Jose Zarzuela on 24/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation
import JZBUtils



public enum ECacheUsage {
    case READ_WRITE, JUST_WRITE, NONE
}

public class GService {
    
    internal let cacheMapInfo : CacheMapInfo
    internal var email : String?
    internal var googleLoginCookies : TCookiesDict?
    internal var xsrfToken : String?
    internal var xsrfTokenTime : Double = 0
    
    
    //------------------------------------------------------------------------------------------------------------------------
    public init(cacheUsage:ECacheUsage) {
        
        self.cacheMapInfo = CacheMapInfo(cacheUsage: cacheUsage)
    }
    
    
    
    //=====================================================================================================
    // MARK: "Protected" (private) util methods
        
    //------------------------------------------------------------------------------------------------------------------------
    internal func _requestAssetCRUD(xsrfToken:String, crudStr:String, inout error:NSError?) -> Bool {
        
        log.debug("Making GMap Asset CRUD request")
        
        
        // Hace la peticion de creacion de mapa
        let request = GMapURLConnection.POST("https://mapsengine.google.com/map/save",
            queryParams:[
                ("cid", "mp"),
                ("cv", "xxxxxxxxxxx.en."),
                ("_reqid", "\(arc4random_uniform(1000000))"),
                ("rt", "j")],
            bodyParams: [
                ("f.req", crudStr),
                ("at", xsrfToken)])
        
        if let reqRsp = GMapURLConnection.sendSynchronousRequest(request, cookies:googleLoginCookies!, error:&error) {
            
            // Todo fue bien
            return true
            
        } else {
            
            // Algo fue mal
            return false
        }
        
    }

    // ----------------------------------------------------------------------------------------------------
    internal func _extractJSONPageData(responseBody:String, inout error:NSError?) -> JSON? {
        
        let jsonP1 = responseBody.indexOf("var _pageData = {")
        let jsonP2 = responseBody.indexOf("};</script>", startIndex: jsonP1, offset:17)
        if jsonP1<0 || jsonP2<0 {
            //println("\(responseBody)")
            error = _error("JSON '_pageData' info not found in HTML page")
            return nil
        }
        
        let jsonStr = responseBody.subString(jsonP1 + 16, endIndex:jsonP2+1);
        //println("\(jsonStr)")
        
        
        // Parsea la respuesta JSON
        var jsonError : NSError? = nil
        let json = JSON(jsonStr: jsonStr, error: &jsonError)
        if json.object is NSNull {
            error = _error("Invalid JSON response found in HTML page", failureReason: nil, prevError: jsonError)
            return nil
        }
        
        // Devuelve la respuesta
        return json
        
    }
    
    // ----------------------------------------------------------------------------------------------------
    internal func _createMapFromJSON(jsonData:JSON, inout error:NSError?) -> GMap? {
        
        // Parseamos el mapa desde la informacion JSON
        if let mapdataJson = jsonData["mapdataJson"].string {
            
            // Parsea la informacion de los arrays recibidos
            if let globalArraysData = StringArraysParser.parseStringArrays(mapdataJson, error: &error) {
                
                // Parsea el mapa desde los arrays
                if let map = GBaseParser.parseStrArrays(globalArraysData, error: &error) {
                    
                    // Actualiza la cache
                    cacheMapInfo.updateJSONMapFileName(map.gid, mapName:map.name)
                    cacheMapInfo.writeMap(map)
                    
                    //println("map -> \(map)")
                    
                    // Retorna el resultado
                    return map
                    
                } else {
                    error = _error("Error parsing GMap from string array", prevError:error)
                    return nil
                }
                
            } else {
                error = _error("Error parsing string array from 'mapdataJson' field", prevError:error)
                return nil
            }
            
        } else {
            error = _error("JSON map data resposse should have 'mapdataJson' field in it")
            return nil
        }
    }
    
    // ----------------------------------------------------------------------------------------------------
    internal func _getResponseBodyText(data:NSData?) -> String {
        
        if data != nil {
            let str = NSString(data: data!, encoding: NSUTF8StringEncoding) ?? ""
            return str
        } else {
            return ""
        }
    }
    
    
    
    // ----------------------------------------------------------------------------------------------------
    internal func _checkIfLoggedIn() -> NSError? {
        
        // Comprueba que tenga cookies... De otra forma no estaria logado
        if googleLoginCookies==nil || googleLoginCookies!.count==0 {
            return _error("Not logged in!")
        }
        
        // Fecha de comparacion (ahora + 5 minutos) para dar un margen en el uso de las cookies
        let nowTime = NSDate(timeIntervalSinceNow: 5*60).timeIntervalSince1970
        
        // Chequea que no esten caducadas
        for cookie in googleLoginCookies!.values {
            
            let expirationTime = cookie.expiresDate?.timeIntervalSince1970 ?? Double.infinity
            
            if expirationTime<nowTime {
                return _error("Session has expired. Need to log in again")
            }
        }
        
        // todo esta OK
        return nil
        
    }
    
}