//
//  GService+Login.swift
//  GMapService
//
//  Created by Jose Zarzuela on 24/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation
import JZBUtils

private let XsrfToken_Max_Time : Double = 12.0 * 3600.0 // 12h de tiempo de expiracion


internal extension GService {
    
    
    //------------------------------------------------------------------------------------------------------------------------
    internal func getXsrfToken(inout error:NSError?) -> String? {
        
        // Si no tiene un token en memoria lo intenta cargar de la cache (dura varias horas)
        if self.xsrfToken == nil && self.email != nil {
            if let (xsrfToken, xsrfTokenTime) = CacheXsrfToken.readXsrfToken(self.email!) {
                self.xsrfToken = xsrfToken
                self.xsrfTokenTime = xsrfTokenTime
            }
        }
        
        // Mira a ver si el que ya tiene es valido
        if let xsrfToken = _getTokenIfValid() {
            return xsrfToken
        }
        
        // Se debe estar logado para poder pedir informacion al servicio remoto
        if let error = _checkIfLoggedIn() {
            return nil
        }

        // Sino, intenta conseguir otro haciendo una peticion
        if let xsrfToken = _requestXsrfToken(&error) {
            self.xsrfToken = xsrfToken
            self.xsrfTokenTime = NSDate().timeIntervalSince1970
            log.debug("Got a new xsrfToken: \(xsrfToken)")
            
            // lo almacena para mas usos futuros
            CacheXsrfToken.writeXsrfToken(self.email!, xsrfToken: self.xsrfToken!, xsrfTokenTime: self.xsrfTokenTime)
            
            // Retorna el valor
            return xsrfToken
        }
        
        // Algo ha salido mal y no hay token
        return nil
    }
    
    
    //========================================================================================================================
    // MARK: Private support methods
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _getTokenIfValid() -> String? {
        
        // Primero debe haber algun token que validar
        if self.xsrfToken == nil {
            log.debug("There is no valid xsrfToken yet")
            return nil
        }
        
        // Comprueba que no ha excedido el tiempo maximo
        let timeDiff = NSDate().timeIntervalSince1970 - self.xsrfTokenTime
        if timeDiff >= XsrfToken_Max_Time {
            self.xsrfTokenTime = 0
            self.xsrfToken = nil
            log.debug("Previously stored xsrfToken is expired")
            return nil
        }
        
        // Todo OK
        return self.xsrfToken
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _requestXsrfToken(inout error:NSError?) -> String? {
        
        log.debug("Requesting new xsrfToken")
        
        let request = GMapURLConnection.GET("https://www.google.com/maps/d/", params: [])
        
        if let reqRsp = GMapURLConnection.sendSynchronousRequest(request, cookies: googleLoginCookies!, error:&error) {
            
            // Lee la parte JSON con los datos del mapa
            let responseBody = _getResponseBodyText(reqRsp.data)
            
            let json : JSON! = _extractJSONPageData(responseBody, error: &error)
            if json == nil {
                return nil
            }
            
            // La chequea
            if json["xsrfToken"].object is NSNull {
                error = _error("Invalid JSON response found: 'xsrfToken'=null")
                return nil
            }
            
            // Devuelve la respuesta
            return json["xsrfToken"].string
            
        } else {
            return nil
        }
        
    }
    


    
}