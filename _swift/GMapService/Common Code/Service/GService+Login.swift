//
//  GService+Login.swift
//  GMapService
//
//  Created by Jose Zarzuela on 24/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation
import JZBUtils



public extension GService {
    
    
    //------------------------------------------------------------------------------------------------------------------------
    public func login(email:String, password:String, inout error:NSError?) -> Bool {
        
        // Logarse es conseguir TODAS las cookies que haran falta en sucesivas llamadas
        log.debug("Login for user email: \(email)")
        
        
        // Intenta primero utilizar las cookies desde la cache
        if let allCookies = CookieJar.readCookies(email, mandatoryNames:["GAPS", "GALX", "SID", "SSID", "HSID"]) {
            log.debug("Google login cookies read from CookieJar")
            self.googleLoginCookies = allCookies
            self.email = email
            return true
        }
        
        
        // Sino, las pide al servidor para la informacion facilitada
        var error:NSError? = nil
        if let appCookies = fetchGoogleAppCookies(error:&error) {
            
            // Pide las cookies de usuario
            if let loginCookies = fetchGoogleLoginCookies(email, password: password, appCookies: appCookies, error: &error) {
                
                var allCookies = appCookies
                for (key,value) in loginCookies {
                    allCookies.updateValue(value, forKey: key)
                }
                
                // Cachea las cookies para evitar pedirlas siempre
                CookieJar.persistCookieJar(email, cookies: allCookies)
                
                // Las almacena en la instancia para dar al servicio como logado
                self.googleLoginCookies = allCookies
                self.email = email
                
                // Todo OK
                return true
            }
        }
        
        // Algo salio mal
        return false
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private func logout() {
        
        googleLoginCookies = nil
        email = nil
    }

    
    //========================================================================================================================
    // MARK: Private support methods
    
    //------------------------------------------------------------------------------------------------------------------------
    private func fetchGoogleAppCookies(inout #error:NSError?) -> TCookiesDict? {
        
        log.debug("Getting all Google APP cookies")
        
        let request = GMapURLConnection.GET("https://accounts.google.com/ServiceLogin", params: [
            ("service"  , "mapsengine"),
            ("passive"  , "1209600"),
            ("continue" , "https://mapsengine.google.com/map/splash"),
            ("followup" , "https://mapsengine.google.com/map/splash")])
        
        if let reqRsp = GMapURLConnection.sendSynchronousRequest(request, cookies:[:], error:&error) {
            
            let allCookies = _extractCookies(reqRsp.httpRsp as NSHTTPURLResponse)
            
            return _checkMandatoryCookies(allCookies, names:["GAPS", "GALX"], error:&error)
            
        } else {
            return nil
        }
        
    }
    
    
    //------------------------------------------------------------------------------------------------------------------------
    private func fetchGoogleLoginCookies(email:String, password:String, appCookies:TCookiesDict, inout error:NSError?) -> TCookiesDict? {
        
        log.debug("Getting all Google login cookies")
        
        let request = GMapURLConnection.POST("https://accounts.google.com/ServiceLoginAuth", queryParams:[], bodyParams: [
            ("GALX"             , appCookies["GALX"]?.value() ?? ""),
            ("continue"         , "https://mapsengine.google.com/map/splash"),
            ("followup"         , "https://mapsengine.google.com/map/splash"),
            ("service"          , "mapsengine"),
            ("_utf8"            , "â"),
            ("bgresponse"       , ""),
            ("pstMsg"           , "1"),
            ("dnConn"           , ""),
            ("checkConnection"  , ""),
            ("checkedDomains"   , "youtube"),
            ("Email"            , email),
            ("Passwd"           , password),
            ("signIn"           , "Sign+in"),
            ("PersistentCookie" , "yes"),
            ("rmShown"          , "1")])
        
        
        if let reqRsp = GMapURLConnection.sendSynchronousRequest(request, cookies:appCookies, error:&error) {
            
            let allCookies = _extractCookies(reqRsp.httpRsp as NSHTTPURLResponse)
            
            return _checkMandatoryCookies(allCookies, names:["SID", "SSID", "HSID"], error:&error)
            
        } else {
            return nil
        }
        
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _checkMandatoryCookies(cookies:TCookiesDict, names:[String], inout error:NSError?) -> TCookiesDict? {
        
        var notFoundNames = [String]()
        for name in names {
            if cookies[name]==nil {
                notFoundNames.append(name)
            }
        }
        
        if notFoundNames.count>0 {
            error = _error("Missing mandatory cookies in response: \(notFoundNames)")
            return nil
        } else {
            return cookies
        }
        
    }
    
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _extractCookies(response : NSHTTPURLResponse) -> TCookiesDict {
        
        // .google.com
        
        var allCookies : [NSHTTPCookie] = NSHTTPCookie.cookiesWithResponseHeaderFields(response.allHeaderFields, forURL: NSURL(string: ".google.com")!) as [NSHTTPCookie]
        
        var dict = TCookiesDict()
        for cookie in allCookies {
            dict[cookie.name] = cookie
        }
        return dict;
    }
    
    
}