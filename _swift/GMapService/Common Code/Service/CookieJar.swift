//
//  CookieJar.swift
//  GMapService
//
//  Created by Jose Zarzuela on 28/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation
import JZBUtils

private let JAR_PASSWORD = "JAR_PASSWORD"

internal class CookieJar {
    
    //------------------------------------------------------------------------------------------------------------------------
    internal class func readCookies(email:String, mandatoryNames:[String]) -> TCookiesDict? {
        
        var result : TCookiesDict?
        
        // Si no hay un fichero termina
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(jarPath) {
            return nil
        }
        
        // Lee el contenido del fichero con las cookies de usuario
        var error:NSError? = nil
        if let base64Str = NSString(contentsOfFile:jarPath, encoding:NSUTF8StringEncoding, error: &error) {
            
            if let data = Crypto.decriptData(base64Str, passwd: JAR_PASSWORD) {
                
                let magicNumber = data.subdataWithRange(NSRange(location:0, length:4))
                let cookiesData = data.subdataWithRange(NSRange(location:4, length:data.length-4))
                
                let crcBuffer = CRC32.crc32(cookiesData)
                
                if crcBuffer.isEqualToData(magicNumber) {
                    
                    if let dict = NSKeyedUnarchiver.unarchiveObjectWithData(cookiesData) as? NSDictionary {
                        
                        let jarEmail = dict.valueForKey("email") as? String ?? ""
                        let jarCookies = dict.valueForKey("cookies") as? Array<[NSObject : AnyObject]> ?? []
                        
                        if jarEmail == email && jarCookies.count>0 {
                            
                            result = TCookiesDict()
                            
                            for props in jarCookies {
                                if let cookie = NSHTTPCookie(properties: props) {
                                    result!.updateValue(cookie, forKey: cookie.name)
                                } else {
                                    log.warning("Error creating cookie from properties content")
                                    break
                                }
                            }
                            
                            result = _checkMandatoryCookies(result!, names:mandatoryNames)
                            
                        } else {
                            log.warning("Error reading cookie jar info (empty or different email")
                        }
                        
                    }
                    
                } else {
                    log.warning("Error checking CRC for CookieJar file")
                }
                
            } else {
                log.warning("Error decryting cookie jar info")
            }
            
        } else {
            log.warning("Error reading cookies from CookieJar file: \(error)")
        }
        
        // Si ha habido algun problema leyendo las cookies borra el fichero
        if result==nil {
            deleteCookieJar()
        }
        
        // Retorna el resultado
        return result
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    internal class func persistCookieJar(email:String, cookies:TCookiesDict) {
        
        let cookieJarInfo = NSMutableDictionary()
        
        // Guarda el email al que pertenecen las cookies
        cookieJarInfo.setValue(email, forKey: "email")
        
        // Recoje la representacion interna de las cookies
        var cookieArray : Array<[NSObject : AnyObject]> = []
        for cookie:NSHTTPCookie in cookies.values {
            
            if let props = cookie.properties {
                cookieArray.append(props)
            }
        }
        
        // Guarda todas las cookies
        cookieJarInfo.setValue(cookieArray, forKey: "cookies")
        
        
        // Le pega un "MagicNumber" para saber que es un fichero genuino
        // Y luego el contenido de las cookies
        let cookiesData = NSKeyedArchiver.archivedDataWithRootObject(cookieJarInfo)
        let crcBuffer = CRC32.crc32(cookiesData)
        let fileData = NSMutableData(data: crcBuffer)
        fileData.appendData(cookiesData)
        
        
        
        // Cifra el contenido
        let base64Str = Crypto.encriptData(fileData, passwd: JAR_PASSWORD)
        
        
        // Escribe el resultado a un fichero en base64
        var error:NSError? = nil
        if !base64Str.writeToFile(jarPath, atomically: true, encoding: NSUTF8StringEncoding, error: &error) {
            log.warning("Error writing cookies to CookieJar: \(error)")
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private class func deleteCookieJar() {
        
        let fileManager = NSFileManager.defaultManager()
        
        if fileManager.fileExistsAtPath(jarPath) {
            var error:NSError? = nil
            if !fileManager.removeItemAtPath(jarPath, error: &error) {
                log.warning("Error deleting CookieJar: \(error)")
            }
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private class var jarPath : String {

        // Directorios para almacenar la informacion de la aplicacion
        let appID = NSBundle.mainBundle().bundleIdentifier! as String
        let localAppDocsPath : String = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)[0] as String
        let appDocsPath2 = localAppDocsPath + "/" + appID
        
        
        // *********************************************************
        // De momento en el HOME como la aplicacion Java
        let home = NSHomeDirectory()
        let appDocsPath = home + "/gmap"
        // *********************************************************
        
        
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(appDocsPath) {
            var error : NSError? = nil
            fileManager.createDirectoryAtPath(appDocsPath, withIntermediateDirectories: true, attributes: nil, error: &error)
        }

        // Nombre del fichero en base a la carpeta
        return appDocsPath+"/cookieJar.data"
    }
    
    // ----------------------------------------------------------------------------------------------------
    private class func _checkMandatoryCookies(cookies:TCookiesDict, names:[String]) -> TCookiesDict? {
        
        // Fecha de comparacion (ahora + 5 minutos) para dar un margen en el uso de las cookies
        let nowTime = NSDate(timeIntervalSinceNow: 5*60).timeIntervalSince1970
        
        // Chequea los nombres y que no esten caducadas
        var notFoundNames = [String]()
        for name in names {
            if let cookie = cookies[name] {
                
                let expirationTime = cookie.expiresDate?.timeIntervalSince1970 ?? Double.infinity
                
                if expirationTime<nowTime {
                    log.warning("Cookie in CookieJar is already expired")
                    return nil
                }
                
            } else {
                notFoundNames.append(name)
            }
        }
        
        // Si faltaba algun nombre lo toma como un error
        if notFoundNames.count>0 {
            log.warning("Missing mandatory cookies in CookieJar: \(notFoundNames)")
            return nil
        }
        
        
        // todo esta OK
        return cookies
    }

    
}