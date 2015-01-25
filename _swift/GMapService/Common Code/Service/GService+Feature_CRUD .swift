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
    public func createFeatures(features:[GFeature], inout error:NSError?) -> Bool {
        
        return _commonCode(features, strRequestFunc:_strRequestCreate, error: &error)
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    public func updateFeatures(features:[GFeature], inout error:NSError?) -> Bool {
        
        return _commonCode(features, strRequestFunc:_strRequestUpdate, error: &error)
    }

    //------------------------------------------------------------------------------------------------------------------------
    public func deleteFeatures(features:[GFeature], inout error:NSError?) -> Bool {
        
        return _commonCode(features, strRequestFunc:_strRequestDelete, error: &error)
    }
    
    
    //========================================================================================================================
    // MARK: Private support methods
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _commonCode(features:[GFeature], strRequestFunc:(features:[GFeature])->String, inout error:NSError?) -> Bool {
        
        // Comprueba si hay algo que hacer
        if features.count == 0 {
            return true
        }
        
        // Comprueba que todas son del mismo mapa
        let ownerMap = features[0].table.layer.map
        for feature in features {
            if !(ownerMap === feature.table.layer.map) {
                error = _error("Al features must belong to the same map")
                return false
            }
        }
        
        // Se debe estar logado para poder pedir informacion al servicio remoto
        if let error = _checkIfLoggedIn() {
            return false
        }
        
        // Necesita un xsrfToken para la peticion
        if let xsrfToken = getXsrfToken(&error) {
            
            // Realiza la peticion de creacion
            let strReq = strRequestFunc(features: features)
            
            return _requestAssetCRUD(xsrfToken, crudStr:strReq , error: &error)
        }
        
        // Algo ha salido mal
        return false
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _strRequestCreate(features:[GFeature]) -> String {
        
        let map_id = features[0].table.layer.map.gid
        let table_id = features[0].table.gid
        
        var reqStr = "[\"\(map_id)\",[\"\(table_id)\",["
        
        for (index,feature) in enumerate(features) {
            
            if index>0 {
                reqStr += ","
            }
            
            reqStr += "[\"\(feature.gid)\","
            reqStr += "null,null,null,null,null,null,null,null,null,null,["
            
            var firstItem = true
            for (name,(type, userProp)) in feature.table.schema {
                if firstItem {
                    firstItem = false
                } else {
                    reqStr += ","
                }
                reqStr += _propertyRender(name, propType: type, propValue: feature.allProperties[name])
            }
            
            reqStr += "]]"
        }
        
        reqStr += "]],null,null,null,null,null,null,null,null,null,null,null,null,null,null,[[]]]"
        
        return reqStr
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _strRequestUpdate(features:[GFeature]) -> String {
        
        let map_id = features[0].table.layer.map.gid
        let table_id = features[0].table.gid
        
        
        var reqStr = "[\"\(map_id)\",null,null,null,[\"\(table_id)\",["
        
        for (index,feature) in enumerate(features) {
            
            if index>0 {
                reqStr += ","
            }
            
            reqStr += "[\"\(feature.gid)\","
            reqStr += "null,null,null,null,null,null,null,null,null,null,["
            
            var firstItem = true
            for (name,(type,userProp)) in feature.table.schema {
                if firstItem {
                    firstItem = false
                } else {
                    reqStr += ","
                }
                reqStr += _propertyRender(name, propType: type, propValue: feature.allProperties[name])
            }
            
            reqStr += "]]"
        }
        
        reqStr += "]],null,null,null,null,null,null,null,null,null,null,null,[[]]]"
        
        return reqStr
    }

    //------------------------------------------------------------------------------------------------------------------------
    private func _strRequestDelete(features:[GFeature]) -> String {
        
        
        let map_id = features[0].table.layer.map.gid
        let table_id = features[0].table.gid
        
        var reqStr = "[\"\(map_id)\", null,[\"\(table_id)\",["
        
        for (index,feature) in enumerate(features) {
            
            if index>0 {
                reqStr += ","
            }
            
            reqStr += "\"\(feature.gid)\""
        }
        
        reqStr += "]],null,null,null,null,null,null,null,null,null,null,null,null,null,[[]]]"
        
        return reqStr
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _propertyRender(propName:String, propType:GESchemaType, propValue:GPropertyType?) -> String {
        
        var strValue = "[\"\(propName)\""
        
        if let value = propValue {
            
            switch propType {
                
            case .ST_DIRECTIONS:
                // TODO: COMO SE HACE ESTO?
                break
                
            case .ST_BOOL:
                strValue += ", null, \"\(value)\", null, null, null, null, true" //2
                
            case .ST_NUMERIC:
                strValue += ", null, null, \"\(value)\", null, null, null, true" // 3
                
            case .ST_STRING:
                strValue += ", null, null, null, \"\(value)\", null, null, true" // 4
                
            case .ST_DATE:
                strValue += ", null, null, null, null, \"\(value)\", null, true" // 5
                
            case .ST_GEOMETRY:
                strValue += ", null, null, null, null, null, [\(_geometryRender(value))], true"
                
            case .ST_GX_METADATA:
                // TODO: COMO SE HACE ESTO?
                break
            }
        }
        
        strValue += "]"
        
        return strValue
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _geometryRender(value:GPropertyType) -> String {
        
        switch value {
            
        case let point as GGeometryPoint:
            return "[\(_geoPointRender(point))], [], []"
            
        case let line as GGeometryLine:
            var strValue = "[], [[["
            for (index, point) in enumerate(line.points) {
                let comma = index>0 ? "x" : "u"
                strValue += "\(comma)\(_geoPointRender(point))"
            }
            strValue += "]]], []"
            return strValue
            
        case let polygon as GGeometryPolygon:
            var strValue = "[], [], [[[[["
            for (index, point) in enumerate(polygon.points) {
                let comma = index>0 ? "x" : "u"
                strValue += "\(comma)\(_geoPointRender(point))"
            }
            strValue += "]]]]]"
            return strValue
            
        default:
            // TODO: Aqui no deberia llegar
            return "null"
        }
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _geoPointRender(point:GGeometryPoint) -> String {
        return "[\(point.lat),\(point.lng)]"
    }
    
    
}