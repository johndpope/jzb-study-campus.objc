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
    public func updateLayerStyle(layer:GLayer, inout error:NSError?) -> Bool {
        
        // Se debe estar logado para poder pedir informacion al servicio remoto
        if let error = _checkIfLoggedIn() {
            return false
        }
        
        // Necesita un xsrfToken para la peticion
        if let xsrfToken = getXsrfToken(&error) {
            
            // Realiza la peticion de creacion
            let strReq = _strRequestLayerStyleUpdate(layer)
            
            return _requestAssetCRUD(xsrfToken, crudStr:strReq , error: &error)
        }
        
        // Algo ha salido mal
        return false
        
    }
    
    //========================================================================================================================
    // MARK: Private support methods
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _strRequestLayerStyleUpdate(layer:GLayer) -> String {
        
        var reqStr = "[\"\(layer.map.gid)\", null, null, null, null, null, "
        reqStr += "[\"\(layer.gid)\", "
        reqStr += "[\"\(layer.style.gid)\", null, ["
        
        // Features' Styles
        for feature in layer.table.features {
            
            reqStr += "["
            
            // Feature info
            reqStr += "[1, [1, null, [[null, null, 1, 0], [[null, null, null, null, \"\(feature.gid)\", null, null, 0], null, null, 0]]], [], 0],"
            
            // Feature Style
            _renderFeatureStyleText(layer, feature:feature, reqStr:&reqStr)
            
            reqStr += "], "
            
        }
        
        // Global default Style
        reqStr += "[null, "
        _renderFeatureStyleText(layer, feature:nil, reqStr:&reqStr)
        reqStr += "]"
        
        //
        reqStr += "]],"
        
        //
        _renderTailStyleText(layer, reqStr:&reqStr)
        
        //
        reqStr += "], null, null, null, null, null, null, null, null, null, [[]]]"
        
        return reqStr
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _renderFeatureStyleText(layer:GLayer, feature:GFeature?, inout reqStr:String) {
        
        let style : GStyleIndividual = layer.style as GStyleIndividual
        
        let pointStyle  = feature?.style is GStyleInfoPoint ? feature?.style as GStyleInfoPoint : style.defaultPointStyle
        let lineStyle    = feature?.style is GStyleInfoLine ? feature?.style as GStyleInfoLine : style.defaultLineStyle
        let polygonStyle = feature?.style is GStyleInfoPolygon ? feature?.style as GStyleInfoPolygon : style.defaultPolygonStyle
        
        //
        reqStr += "["
        
        // Icono
        reqStr += "[\(pointStyle.iconID), null, null, [\"\(pointStyle.colorHex)\", \(pointStyle.scale)], null,"
        _renderStyleLayerSchema(layer, reqStr:&reqStr)
        reqStr += ", null, null, [null, null, null, 0]],"
        
        // Linea
        reqStr += "[\(lineStyle.width), [\"\(lineStyle.colorHex)\", \(lineStyle.alpha)], null,"
        _renderStyleLayerSchema(layer, reqStr:&reqStr)
        reqStr += ", null, null, []],"
        
        // Poligono
        reqStr += "[[\"\(polygonStyle.colorHex)\", 1], \(polygonStyle.width), [\"\(polygonStyle.colorHex)\", \(polygonStyle.alpha)], null, "
        _renderStyleLayerSchema(layer, reqStr:&reqStr)
        reqStr += ", 0]"
        
        //
        reqStr += "]"
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _renderStyleLayerSchema(layer:GLayer, inout reqStr:String) {
        
        let title = layer.style.titlePropName
        var customPropNames = Array<String>()
        for (name,(type,sysProp)) in layer.table.schema {
            if (name != title) && !sysProp {
                customPropNames.append(name)
            }
        }
        
        //
        reqStr += "["
        
        //
        reqStr += "[\"\(title)\""
        for name in customPropNames {
            reqStr += ", \"\(name)\""
        }
        
        //
        reqStr += ", \"gx_image_links\", \"place_ref\"],"
        
        //
        reqStr += "\"{\(title)|title}{gx_image_links|images}"
        for name in customPropNames {
            reqStr += "{\(name)|attributerow}"
        }
        reqStr += "{place_ref|placeref}\""
        
        //
        reqStr += "]"
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _renderTailStyleText(layer:GLayer, inout reqStr:String) {
        
        let title = layer.style.titlePropName
        var customPropNames = Array<String>()
        for (name,(type,sysProp)) in layer.table.schema {
            if (name != title) && !sysProp {
                customPropNames.append(name)
            }
        }

        reqStr += "[6,"
        reqStr += "[1200, 1200, 0.3, \"000000\", \"DB4436\", null, \"000000\", 503],"
        reqStr += "null, null, [], [], [0, 1], null, null,"
        reqStr += "[\"\(title)\""
        for name in customPropNames {
            reqStr += ", \"\(name)\""
        }
        reqStr += "], null, null, null, null,[], null, []"
        reqStr += "]"

    }
    
    
}