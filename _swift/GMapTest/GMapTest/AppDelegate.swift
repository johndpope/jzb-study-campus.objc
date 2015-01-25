//
//  AppDelegate.swift
//  GMapTest
//
//  Created by Jose Zarzuela on 26/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Cocoa
import JZBUtils
import GMapService


let log = XCGLogger.defaultInstance()


extension Array {
    
    func forEach(closure:(T)->Void) {
        for item in self {
            closure(item)
        }
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    //------------------------------------------------------------------------------------------------------------------------
    func loggerSetup() {
        
        /*
        let logPath : NSString = "~/Desktop/XCGLogger_Log.txt".stringByExpandingTildeInPath
        log.setup(logLevel: .Debug, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil /*logPath*/)
        
        
        log.verbose("Verbose button tapped")
        log.verboseExec {
        log.verbose("Executed verbose code block")
        }
        */
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    func __addTestFeature(table:GTable) -> GFeature {
        
        
        let feature = table.createFeature(GFeature.GeoType.POINT)

        let geometry = GGeometryPoint(lng: Double(arc4random_uniform(20)), lat: Double(arc4random_uniform(20)))
        feature.geometry = geometry
        
        feature.userProperties["nombre"] = "name - \(arc4random_uniform(10000))"
        feature.userProperties["descripción"] = "desc - \(arc4random_uniform(10000))"
        
        return feature
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    func examples() {
        
        var error : NSError? = nil
        
        var srvc = GService(cacheUsage: ECacheUsage.READ_WRITE)
        
        let email = Crypto.decriptString("DRcAAiUGAA8TJRMKDAgccRAKDg==", passwd: "gmap_secret")
        let pwd = Crypto.decriptString("RBoEEigWB1JLUkU=", passwd: "gmap_secret")
        srvc.login(email, password: pwd, error: &error)
        
        srvc.getMapData("zeLPXIl-X_4c.k8MVjbnOWqqs", error:&error)
        
        var mapList : [UserMapData]? = srvc.getUserMapList(&error)
        
        
        
        if let map2 = srvc.createMap(&error) {
            
            println("Mapa creado - gid = \(map2.gid)")
            
            NSThread.sleepForTimeInterval(0.5)
            map2.name = "mapaCreadoPorMi"
            map2.desc = "Con esta descripcion"
            if srvc.updateMap(map2, error: &error) {
                
                println("Mapa actualizado - gid = \(map2.gid)")
                
                NSThread.sleepForTimeInterval(0.5)
                if srvc.deleteMap(map2, error: &error) {
                    println("Mapa borrado - gid = \(map2.gid)")
                }
            }
        }
        
        var map:GMap!
        
        // Features
        var createdFeatures = Array<GFeature>()
        
        for n in 1...1 {
            let f = __addTestFeature(map.layers[0].table)
            createdFeatures.append(f)
        }
        
        if !srvc.createFeatures(createdFeatures, error: &error) {
            println("Error -> \(error)")
        } else {
            println("Creados puntos con exito")
        }
        
        var features = map.layers[0].table.features
        
        var index = 1
        for feature in features {
            feature.userProperties["nombre"] = "cambiado_\(index)"
            index++
        }
        
        if !srvc.updateFeatures(features, error: &error) {
            println("Error -> \(error)")
        } else {
            println("Actualizados puntos con exito")
        }
        
        
        if !srvc.deleteFeatures(features, error: &error) {
            println("Error -> \(error)")
        } else {
            println("Borrados puntos con exito")
        }
        
        
        for feature in map.layers[0].table.features {
            var style1 = feature.style as GStyleInfoPoint
            var style2 = GStyleInfoPoint(iconID: 71, colorHex: style1.colorHex, scale: style1.scale)
            feature.style = style2
        }
        
        if !srvc.updateLayerStyle(map.layers[0], error:&error) {
            println("Error -> \(error)")
        } else {
            println("Actualizado style con exito")
        }
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        // Setup XCGLogger OSX
        loggerSetup()
        
        
        var srvc = GService(cacheUsage: ECacheUsage.JUST_WRITE)
        
        let email = Crypto.decriptString("DRcAAiUGAA8TJRMKDAgccRAKDg==", passwd: "gmap_secret")
        let pwd = Crypto.decriptString("RBoEEigWB1JLUkU=", passwd: "gmap_secret")
        
        var error : NSError? = nil
        if srvc.login(email, password:pwd, error:&error) {
            
            // zeLPXIl-X_4c.k8MVjbnOWqqs
            // zeLPXIl-X_4c.klCb1Y58BMcc
            if let map = srvc.getMapData("zeLPXIl-X_4c.kUltqR9zev3I", error:&error) {
                println("OK \(map.name)")
                
                //println(map)
                
            } else {
                println("ERROR: \(error)")
            }
            
        }
        
        
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    
}

