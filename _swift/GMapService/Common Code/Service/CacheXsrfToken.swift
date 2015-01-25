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

internal class CacheXsrfToken {
    
    //------------------------------------------------------------------------------------------------------------------------
    internal class func readXsrfToken(email:String) -> (String, Double)? {
        
        var result : (String, Double)? = nil
        
        
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
                let xsrfTokenData = data.subdataWithRange(NSRange(location:4, length:data.length-4))
                
                let crcBuffer = CRC32.crc32(xsrfTokenData)
                
                if crcBuffer.isEqualToData(magicNumber) {
                    
                    if let dict = NSKeyedUnarchiver.unarchiveObjectWithData(xsrfTokenData) as? NSDictionary {
                        
                        let jarEmail = dict.valueForKey("email") as? String ?? ""
                        let jarXsrfToken = dict.valueForKey("xsrfToken") as? String ?? ""
                        let jarXsrfTokenTime = dict.valueForKey("xsrfTokenTime") as? Double ?? -1.0
                        
                        if jarEmail == email && jarXsrfToken != "" && jarXsrfTokenTime != -1.0 {
                            
                            result = (jarXsrfToken, jarXsrfTokenTime)
                            
                        } else {
                            log.warning("Error reading cookie jar info (empty or different email")
                        }
                        
                    }
                    
                } else {
                    log.warning("Error checking CRC for XsrfTokenJar file")
                }
                
            } else {
                log.warning("Error decryting XsrfTokenJar info")
            }
            
        } else {
            log.warning("Error reading token from XsrfTokenJar file: \(error)")
        }
        
        // Si ha habido algun problema leyendo el token borra el fichero
        if result==nil {
            deleteXsrfTokenJar()
        }
        
        // Retorna el resultado
        return result
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    internal class func writeXsrfToken(email:String, xsrfToken:String, xsrfTokenTime:Double) {
        
        let xsrfTokenInfo = NSMutableDictionary()
        
        // Guarda el email al que pertenece el XsrfToken
        xsrfTokenInfo.setValue(email, forKey: "email")
        
        // Guarda el valor del token y su expiracion
        xsrfTokenInfo.setValue(xsrfToken, forKey: "xsrfToken")
        xsrfTokenInfo.setValue(xsrfTokenTime, forKey: "xsrfTokenTime")
        
        // Le pega un "MagicNumber" para saber que es un fichero genuino
        // Y luego el contenido del token
        let xsrfTokenData = NSKeyedArchiver.archivedDataWithRootObject(xsrfTokenInfo)
        let crcBuffer = CRC32.crc32(xsrfTokenData)
        let fileData = NSMutableData(data: crcBuffer)
        fileData.appendData(xsrfTokenData)
        
        
        // Cifra el contenido
        let base64Str = Crypto.encriptData(fileData, passwd: JAR_PASSWORD)
        
        
        // Escribe el resultado a un fichero en base64
        var error:NSError? = nil
        if !base64Str.writeToFile(jarPath, atomically: true, encoding: NSUTF8StringEncoding, error: &error) {
            log.warning("Error writing XsrfToken to XsrfTokenJar: \(error)")
            deleteXsrfTokenJar()
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private class func deleteXsrfTokenJar() {
        
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
        return appDocsPath+"/xsrfTokenJar.data"
    }

    
}