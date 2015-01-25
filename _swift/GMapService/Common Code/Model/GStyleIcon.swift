//
//  GStyleIcon.swift
//  GMapService
//
//  Created by Jose Zarzuela on 24/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation

//private let ICON_BASE_URL  = "http://mt.googleapis.com/vt/icon/name=icons/onion/"
private let ICON_BASE_URL     = "http://www.gstatic.com/mapspro/images/stock/"
private let ICON_UNKNOWN_URL  = "http://www.gstatic.com/mapspro/images/stock/172-grey.png"



private let namedIconNamesForID : Dictionary<Int, String> = GStyleIcon.loadIconNamesForIDs("GStyleIconNamed")
private let coloredIconNamesForID : Dictionary<Int, String> = GStyleIcon.loadIconNamesForIDs("GStyleIconColored")


private class GStyleIcon: DebugPrintable {
    
    private var iconID:Int
    private var hexColor:String
    private var scale:Float

    
    //------------------------------------------------------------------------------------------------------------------------
    private init(iconID:Int, hexColor:String, scale:Float) {
       
        self.iconID = iconID
        self.hexColor = hexColor
        self.scale = scale
        
        namedIconNamesForID.count
        coloredIconNamesForID.count
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private var url : String {
        
        if let iconName = namedIconNamesForID[iconID] {
            return "\(ICON_BASE_URL)\(iconID)-\(iconName).png";
        } else if let iconName = coloredIconNamesForID[iconID] {
            // @TODO: Aqui habra que ver que se hace con el dato del color
            return "\(ICON_BASE_URL)\(iconID)-\(iconName).png";
        } else {
            return ICON_UNKNOWN_URL;
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private class func loadIconNamesForIDs(iconBundleName:String) -> Dictionary<Int, String> {
        
        var iconInfoDict : Dictionary<Int, String> = [:]
        
        if let path = NSBundle(identifier: "com.zetLabs.GMapService")?.pathForResource(iconBundleName, ofType: "plist") {
            if let values = NSArray(contentsOfFile: path) {
                for item in values {
                    if let strItem = item as? String {
                        let id_name = strItem.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "="))
                        if let id = id_name[0].toInt() {
                            iconInfoDict[id_name[0].toInt()!] = id_name[1]
                        }
                    }
                }
            }
        }
        
        log.debug("icon id-name items: \(iconInfoDict.count)")
        
        return iconInfoDict;
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    internal var debugDescription : String {
        let strVal = "GStyleIcon { iconID: \(iconID), color: #\(hexColor), scale: \(scale), url: \(url)"
        return strVal
    }
}