//
//  CookieJar.swift
//  GMapService
//
//  Created by Jose Zarzuela on 28/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation
import JZBUtils

private let EXT_JSON = ".json"
private let EXT_BIN = ".bin"
private let NAME_ID_SEPARATOR = "=="


public class CacheMapInfo {
    
    private let cacheUsage : ECacheUsage
    
    
    //------------------------------------------------------------------------------------------------------------------------
    internal init(cacheUsage : ECacheUsage) {
        
        self.cacheUsage = cacheUsage
        if cacheUsage != .READ_WRITE {
            log.debug("Use of cached files for maps is disabled")
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    public class func cachedMapNamesAndIDs() -> [(name:String, gid:String)] {
        
        var mapIDs = Dictionary<String,(name:String, gid:String)>()
        
        // Consigue la carpeta donde estan los ficheros
        let cacheFolderPath = _cacheFolderPath()
        
        // Itera buscando tanto los JSON como los BIN
        let filemanager:NSFileManager = NSFileManager()
        let files = filemanager.enumeratorAtPath(cacheFolderPath)
        while let file : String = files?.nextObject() as? String {
            
            if file.hasSuffix(EXT_JSON) || file.hasSuffix(EXT_BIN) {
                
                let p1 = file.indexOf(NAME_ID_SEPARATOR)
                let p2 = file.lastIndexOf(".")
                if p1>=0 && p2>0 {
                    let mapName = file.subString(0, endIndex: p1)
                    let map_gid = file.subString(p1+2, endIndex: p2)
                    mapIDs[map_gid] = (name:mapName, gid:map_gid)
                }
            }
            
        }
        
        // Retorna los IDs que haya encontrado
        let result = Array<((name:String, gid:String))>(mapIDs.values)
        return result.sorted{$0.name < $1.name}
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private func deleteMap(mapGID:String) {
        
        var error : NSError? = nil
        let filemanager:NSFileManager = NSFileManager()
        
        if let jsonMapCacheFilePath = _searchMapCachedFilePath(mapGID, fExt:EXT_JSON) {
            if !filemanager.removeItemAtPath(jsonMapCacheFilePath, error: &error) {
                log.error("Error deleting JSON map file cache (id: \(mapGID)): \(error)")
            }
        }
        
        if let binMapCacheFilePath = _searchMapCachedFilePath(mapGID, fExt:EXT_BIN) {
            if !filemanager.removeItemAtPath(binMapCacheFilePath, error: &error) {
                log.error("Error deleting binary map file cache (id: \(mapGID)): \(error)")
            }
        }
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    internal func readMap(mapGID:String) -> GMap? {
        
        // Solo debe hacer algo si la cache esta activa
        if(cacheUsage != .READ_WRITE) {
            return nil
        }
        
        
        // Comprueba si hay una version preprocesada del fichero
        if let mapCacheFilePath = _searchMapCachedFilePath(mapGID, fExt:EXT_BIN) {
            
            log.debug("Found binary cached file for map GID '\(mapGID)': \(mapCacheFilePath)")
            
            if let data = NSData(contentsOfFile: mapCacheFilePath) {
                let map = GMap.fromData(data)
                return map
            } else {
                log.warning("Error reading binary cached map(id: \(mapGID))")
                return nil
            }
            
        } else {
            log.debug("Binary cached file for map(id: \(mapGID)) doesn't exist")
            return nil
        }
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    internal func writeMap(map:GMap) {
        
        // Solo debe hacer algo si la cache esta activa
        if(cacheUsage == .NONE) {
            return
        }
        
        
        // Crea el nombre del fichero
        let mapCacheFilePath = _createMapCacheFilePath(map.gid, map_name: map.name, fExt: EXT_BIN)
        
        // Escribe el contenido al fichero
        let mapData = map.toData()
        if !mapData.writeToFile(mapCacheFilePath, atomically: true) {
            log.warning("Error writing binary map file cache (id: \(map.gid), name: \(map.name))")
        }
        
        log.debug("Cache JSON map file (id: \(map.gid)) has been written successfuly")
        
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    internal func readJSONMapData(mapGID:String) -> JSON? {
        
        // Solo debe hacer algo si la cache esta activa
        if(cacheUsage != .READ_WRITE) {
            return nil
        }
        
        
        // Lee el contenido del fichero de cache con infomacion en formato JSON
        if let mapCacheFilePath = _searchMapCachedFilePath(mapGID, fExt:EXT_JSON) {
            
            log.debug("Found JSON cached file for map GID '\(mapGID)': \(mapCacheFilePath)")
            
            var error:NSError? = nil
            if let mapJSonStr = NSString(contentsOfFile: mapCacheFilePath, encoding: NSUTF8StringEncoding, error: &error) {
                
                // Parsea la respuesta JSON
                let json = JSON(jsonStr: mapJSonStr, error: &error)
                if json.object is NSNull {
                    log.warning("Invalid JSON response found in map file cache (id: \(mapGID)): \(error)")
                    return nil
                }
                
                // Retorna el resultado
                return json
                
            } else {
                log.warning("Error reading JSON cached map(id: \(mapGID)) info: \(error)")
                return nil
            }
            
        } else {
            log.debug("JSON Cached file for map(id: \(mapGID)) doesn't exist")
            return nil
        }
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    internal func writeJSONMapData(mapGID:String, json:JSON) {
        
        // Solo debe hacer algo si la cache esta activa
        if(cacheUsage == .NONE) {
            return
        }
        
        
        if let jsonStr = json.rawString(encoding: NSUTF8StringEncoding, options: .PrettyPrinted) {
            
            // Escribe el resultado a un fichero en base64
            var error:NSError? = nil
            
            // Crea el nombre del fichero
            let mapCacheFilePath = _createMapCacheFilePath(mapGID, map_name: "unknownMapName", fExt: EXT_JSON)
            
            // Escribe el contenido al fichero
            if !jsonStr.writeToFile(mapCacheFilePath, atomically: true, encoding: NSUTF8StringEncoding, error: &error) {
                log.warning("Error writing JSON map file cache (id: \(mapGID)): \(error)")
            }
            
            log.debug("Cache JSON map file (id: \(mapGID)) has been written successfuly")
            
        } else {
            log.warning("Can't get valid JSON string representation for map(id: \(mapGID))")
        }
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    internal func updateJSONMapFileName(mapGID:String, mapName:String) {
        
        // Solo debe hacer algo si la cache esta activa
        if(cacheUsage == .NONE) {
            return
        }
        
        
        // Crea los nombres del fichero (nuevo y antiguo)
        let newMapCacheFilePath = _createMapCacheFilePath(mapGID, map_name: mapName, fExt: EXT_JSON)
        let oldCacheFilePath = _createMapCacheFilePath(mapGID, map_name: "unknownMapName", fExt: EXT_JSON)
        
        // Comprueba si el fichero sin nombre exise, en cuyo caso lo renombra
        let filemanager:NSFileManager = NSFileManager()
        var error:NSError? = nil
        
        if filemanager.fileExistsAtPath(newMapCacheFilePath) {
            if !filemanager.removeItemAtPath(newMapCacheFilePath, error: &error) {
                log.warning("Error removing existing JSON map file cache (id: \(mapGID), name: \(mapName)): \(error)")
            }
        }
        if filemanager.fileExistsAtPath(oldCacheFilePath) {
            if !filemanager.moveItemAtPath(oldCacheFilePath, toPath:newMapCacheFilePath , error: &error) {
                log.warning("Error renaming JSON map file cache (id: \(mapGID), name: \(mapName)): \(error)")
            } else {
                log.debug("Map file cache (id: \(mapGID)) renamed to name: \(mapName)")
            }
        }
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _searchMapCachedFilePath(mapGID:String, fExt:String) -> String? {
        
        // Consigue la carpeta donde estan los ficheros
        let cacheFolderPath = CacheMapInfo._cacheFolderPath()
        
        // Itera buscandolo
        let filemanager:NSFileManager = NSFileManager()
        let files = filemanager.enumeratorAtPath(cacheFolderPath)
        while let file : String = files?.nextObject() as? String {
            
            if file.hasSuffix(fExt) && file.indexOf(mapGID)>=0 {
                return cacheFolderPath+"/"+file
            }
        }
        
        // No lo ha encontrado
        return nil
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _createMapCacheFilePath(map_gid:String, map_name:String, fExt:String) -> String {
        
        let cacheFolderPath = CacheMapInfo._cacheFolderPath()
        let mapCacheFilePath = cacheFolderPath+"/\(map_name)\(NAME_ID_SEPARATOR)\(map_gid)\(fExt)"
        return mapCacheFilePath
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private class func _cacheFolderPath() -> String {
        
        // Directorios para almacenar la informacion de la aplicacion
        let appID = NSBundle.mainBundle().bundleIdentifier! as String
        let localAppDocsPath : String = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)[0] as String
        let appDocsPath2 = localAppDocsPath + "/" + appID + "/map_html_data"
        
        
        // *********************************************************
        // De momento en el HOME como la aplicacion Java
        let home = NSHomeDirectory()
        let appDocsPath = home + "/gmap/map_html_data"
        // *********************************************************
        
        
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(appDocsPath) {
            var error : NSError? = nil
            fileManager.createDirectoryAtPath(appDocsPath, withIntermediateDirectories: true, attributes: nil, error: &error)
        }
        
        // Nombre de la carpeta para almacenar los ficheros
        return appDocsPath
    }
    
}