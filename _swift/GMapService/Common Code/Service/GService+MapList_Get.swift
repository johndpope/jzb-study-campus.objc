//
//  GService+GetMapList.swift
//  GMapService
//
//  Created by Jose Zarzuela on 24/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation
import JZBUtils



//============================================================================================================================
public struct UserMapData : Printable, DebugPrintable {
    
    public let name : String
    public let desc : String
    public let gid : String
    public let lastEditedUtc : Int64
    public let url : String
    
    private init?(json:JSON ) {
        
        var sName = json["name"].string
        var sDesc = json["description"].string
        var sGID  = json["id"].string
        var sURL  = json["url"].string
        var leUtc = json["lastEditedUtc"].int64
        
        if sName != nil && sGID != nil && leUtc != nil && sURL != nil {
            name = sName!
            desc = sDesc ?? ""
            gid = sGID!
            lastEditedUtc = leUtc!
            url = sURL!
        } else {
            return nil
        }
    }
    
    public var debugDescription : String  {
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(lastEditedUtc)/1000.0)
        return "UserMapData: {name:'\(name)', gid:'\(gid)', lastEditedUtc:\(date), url:'\(url)'}"
    }
    
    public var description : String  {
        return debugDescription
    }
}


//============================================================================================================================
public extension GService {
    
    
    //------------------------------------------------------------------------------------------------------------------------
    public func getUserMapList(inout error:NSError?) -> [UserMapData]? {
        
        // Se debe estar logado para poder pedir informacion al servicio remoto
        if let error = _checkIfLoggedIn() {
            return nil
        }
        
        // Consigue la informacion de los mapas
        if let jsonDocs = fetchUserMapList(&error) {
            
            // Crea el array de valores
            var userMapdata = [UserMapData]()
            for jsonItem in jsonDocs {
                
                if let mapData = UserMapData(json:jsonItem) {
                    userMapdata.append(mapData)
                } else {
                    error = _error("Incorrect JSON mapData format (name, id, lastEditedUtc, url)")
                    return nil
                }
                
            }
            
            // Devuelve el resultado
            return userMapdata
            
        } else {
            
            // Algo ha fallado
            return nil
            
        }
    }
    
    
    //========================================================================================================================
    // MARK: Private support methods
    
    //------------------------------------------------------------------------------------------------------------------------
    private func fetchUserMapList(inout error:NSError?) -> [JSON]? {
        
        log.debug("Getting User MapList data")
        
        // Se necesita cierta informacion de la pagina previa para pedir la lista de documentos
        var tokenAndClientUser = fetchMapListTokenAndClientUser(&error)
        if tokenAndClientUser == nil {
            return nil
        }
        
        // Hace la peticion del listado de mapas de los que el usuario es dueño
        let request = GMapURLConnection.POST("https://docs.google.com/picker/pvr?hl=es&hostId=MapsPro", queryParams:[], bodyParams: [
            ("start"      , "0"),
            ("numResults" , "999999"),
            ("sort"       , "0"),
            ("desc"       , "true"),
            ("cursor"     , ""),
            ("service"    , "mapspro"),
            ("type"       , "owned"),
            ("options"    , "null"),
            ("token"      , tokenAndClientUser!.token),
            ("version"    , "4"),
            ("subapp"     , "5"),
            ("app"        , "2"),
            ("clientUser" , tokenAndClientUser!.clientUser),
            ("authuser"   , "0")])
        
        
        if let reqRsp = GMapURLConnection.sendSynchronousRequest(request, cookies:googleLoginCookies!, error:&error) {
            
            // Busca la parte de la cadena JSON
            let responseBody = _getResponseBodyText(reqRsp.data)
            let p1 = responseBody.indexOf("{")
            if ( p1 < 0) {
                error = _error("Invalid JSON response found")
                return nil
            }
            
            // Parsea la respuesta JSON
            let jsonTxt = responseBody.subString(p1)
            var jsonError : NSError? = nil
            let json = JSON(jsonStr: jsonTxt, error: &jsonError)
            if json.object is NSNull {
                error = _error("Invalid JSON response found", failureReason: nil, prevError: jsonError)
                return nil
            }
            
            // La chequea
            if json["response","success"].boolValue==false {
                error = _error("Invalid JSON response found", failureReason: nil, prevError: json.error)
            }
            
            // Retorna el array de documentos
            if let docs = json["response"]["docs"].array {
                
                return docs
                
            } else {
                
                error = _error("Invalid JSON response found", failureReason: nil, prevError: json.error)
                return nil
                
            }
            
        } else {
            // La peticion ha fallado
            return nil
        }
        
    }
    
    
    //------------------------------------------------------------------------------------------------------------------------
    private func fetchMapListTokenAndClientUser(inout error:NSError?) -> (token:String, clientUser:String)? {
        
        log.debug("Getting TokenAndClientUser in other to get UserMapList")
        
        let navStr = "({root:(null,\"My+Maps\"),items:((\"maps-pro\",\"Created\",{\"type\":\"owned\"}),(\"maps-pro\",\"Shared with me\",{\"type\":\"shared\"})),options:{\"collapsible\":\"expanded\"}})"
        let request = GMapURLConnection.GET("https://docs.google.com/picker", params: [
            ("protocol"   , "gadgets"),
            ("origin"     , "https://mapsengine.google.com"),
            ("relayUrl"   , "https://mapsengine.google.com"),
            ("authuser"   , "0"),
            ("hl"         , "en"),
            ("title"      , "Open+map"),
            ("hostId"     , "MapsPro"),
            ("ui"         , "2"),
            ("nav"        , navStr),
            ("rpctoken"   , "xxxxxxxx"),
            ("rpcService" , "xxxxxxxx"),
            ("ppli"       , "2")])
        
        if let reqRsp = GMapURLConnection.sendSynchronousRequest(request, cookies: googleLoginCookies!, error:&error) {
            
            let responseBody = _getResponseBodyText(reqRsp.data)
            
            if (responseBody.indexOf("rawConfig") < 0) {
                error = _error("Invalid response: 'rawConfig' info expected")
                return nil
            }
            
            let tokenP1 = responseBody.indexOf("token:'")
            let tokenP2 = responseBody.indexOf("'", startIndex: tokenP1, offset:7)
            if tokenP1<0 || tokenP2<0 {
                error = _error("Invalid response: 'rawConfig:token' info expected")
                return nil
            }
            
            let clientUserP1 = responseBody.indexOf("clientUser:'")
            let clientUserP2 = responseBody.indexOf("'", startIndex: clientUserP1, offset:12)
            if clientUserP1<0 || clientUserP2<0 {
                error = _error("Invalid response: 'rawConfig:clientUser' info expected")
                return nil
            }
            
            let token = responseBody.subString(tokenP1 + 7, endIndex:tokenP2);
            let clientUser = responseBody.subString(clientUserP1 + 12, endIndex:clientUserP2);
            return (token:token, clientUser:clientUser)
            
        } else {
            return nil
        }
        
    }
    
}