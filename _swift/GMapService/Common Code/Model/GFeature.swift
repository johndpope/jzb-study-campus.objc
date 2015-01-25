//
//  GFeature.swift
//  GMapService
//
//  Created by Jose Zarzuela on 24/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation
import JZBUtils


// Posibles tipos de valores que pueden establecerse en una property
public protocol GPropertyType: Printable, DebugPrintable {
}


typealias DateTime = Int64  // Since 1970


// Tambien GGeometry -> GPropertyType
extension String    : GPropertyType {
    public var description : String { return self }
    public var debugDescription : String { return self }
}
extension Double    : GPropertyType {
    public var description : String { return "\(self)" }
    public var debugDescription : String { return "\(self)" }
}
extension DateTime  : GPropertyType { //TODO: NOOOOOOOO -> Hay que distinguir Date de un numero
    public var description : String { return "\(self)" }
    public var debugDescription : String { return "\(self)" }
}
extension Bool      : GPropertyType {
    public var description : String { return self ? "true" : "false" }
    public var debugDescription : String { return self ? "true" : "false" }
}



//========================================================================================================================
public class GFeature : GAsset {
    
    public enum GeoType : Int {
        case POINT = 1, LINE = 2, POLYGON = 3
    }
    
    unowned public let table:GTable
    public let geoType : GeoType
    
    private var rawPropValues = Dictionary<String, GPropertyType?>()
    
    private(set) public var allProperties  : RONamedSubscript<String, GPropertyType?>!
    private(set) public var userProperties : NamedSubscript<String, GPropertyType?>!
    
    
    //------------------------------------------------------------------------------------------------------------------------
    internal init(gid: String, table:GTable, geoType:GeoType) {
        
        self.table = table
        self.geoType = geoType
        
        super.init(gid:gid)
        
        _setNamedProperties()
    }
    
    
    //------------------------------------------------------------------------------------------------------------------------
    required public init(coder decoder: NSCoder) {
        
        table = decoder.decodeObjectForKey("ownerTable") as GTable
        geoType = GeoType(rawValue:decoder.decodeIntegerForKey("geoType"))!
        
        super.init(coder: decoder)
        
        _setNamedProperties()
        
        // Properties
        let count = decoder.decodeIntegerForKey("propCount")
        for var index=0; index<count; index++ {
            let name = decoder.decodeObjectForKey("propName_\(index)") as String
            let value = _decodePropValue(decoder, forIndex:index)
            _setPropValue(name, value: value, justUserProps:false)
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    override public func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(table, forKey: "ownerTable")
        aCoder.encodeInteger(geoType.rawValue, forKey: "geoType")
        
        super.encodeWithCoder(aCoder)
        
        // Properties
        aCoder.encodeInteger(rawPropValues.count, forKey: "propCount")
        var index = 0
        for (name, value) in rawPropValues {
            aCoder.encodeObject(name, forKey: "propName_\(index)")
            _encodePropValue(aCoder, forIndex:index, value:value)
            index++
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _decodePropValue(decoder: NSCoder, forIndex:Int) -> GPropertyType? {
        
        let keyType  = "propType_\(forIndex)"
        let keyValue = "propValue_\(forIndex)"
        
        let type = decoder.decodeIntegerForKey(keyType)
        
        switch type {
        case 0:
            return nil
        case 1:
            return decoder.decodeObjectForKey(keyValue) as String
            
        case 2:
            return decoder.decodeDoubleForKey(keyValue)
            
        case 3:
            return decoder.decodeInt64ForKey(keyValue)
            
        case 4:
            return decoder.decodeBoolForKey(keyValue)
            
        case 5:
            let array = decoder.decodeObjectForKey(keyValue) as [Double]
            return GGeometryPoint(array: array)
            
        case 6:
            let array = decoder.decodeObjectForKey(keyValue) as [[Double]]
            return GGeometryLine(array: array)
            
        case 7:
            let array = decoder.decodeObjectForKey(keyValue) as [[Double]]
            return GGeometryPolygon(array: array)
            
        default:
            // Aqui no deberia llegar
            assertionFailure("Cannot decode unknown feature property type")
        }
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _encodePropValue(coder: NSCoder, forIndex:Int, value:GPropertyType?) {
        
        let keyType  = "propType_\(forIndex)"
        let keyValue = "propValue_\(forIndex)"
        
        switch value {
        case nil:
            coder.encodeInteger(0, forKey: keyType)
            
        case let s as String:
            coder.encodeInteger(1, forKey: keyType)
            coder.encodeObject(s, forKey: keyValue)
            
        case let d as Double:
            coder.encodeInteger(2, forKey: keyType)
            coder.encodeDouble(d, forKey: keyValue)
            
        case let t as DateTime:
            coder.encodeInteger(3, forKey: keyType)
            coder.encodeInt64(t, forKey: keyValue)
            
        case let b as Bool:
            coder.encodeInteger(4, forKey: keyType)
            coder.encodeBool(b, forKey: keyValue)
            
        case let gi as GGeometryPoint:
            coder.encodeInteger(5, forKey: keyType)
            coder.encodeObject(gi.toArray() , forKey: keyValue)
            
        case let gl as GGeometryLine:
            coder.encodeInteger(6, forKey: keyType)
            coder.encodeObject(gl.toArray() , forKey: keyValue)
            
        case let gp as GGeometryPolygon:
            coder.encodeInteger(7, forKey: keyType)
            coder.encodeObject(gp.toArray() , forKey: keyValue)
            
        default:
            // Aqui no deberia llegar
            assertionFailure("Cannot encode unknown feature property type")
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    public var geometry : GGeometry {
        
        get {
            let geo = _getPropValue(PROPNAME_GME_GEOMETRY, justUserProps:false)
            
            switch geo {
                
            case let point as GGeometryPoint:
                return point
                
            case let line as GGeometryLine:
                return line
                
            case let polygon as GGeometryPolygon:
                return polygon
                
            default:
                // TODO: Aqui no deberia llegar porque todos las features deben tener geometria
                return GGeometryPoint(lng: 0.0, lat: 0.0)
            }
        }
        set {
            _setPropValue(PROPNAME_GME_GEOMETRY, value: newValue, justUserProps:false)
        }
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    public var title : String {
        
        let titlePropName = table.layer.style.titlePropName
        if let title = _getPropValue(titlePropName, justUserProps:false) as? String {
            return title
        } else {
            // TODO: Quitar esto y retornar vacio
            return "** SIN TITULO **"
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    public var style : GStyleInfo {
        
        get {
            
            // TODO: Como obtenemos el estilo en otros tipos
            let style = table.layer.style as GStyleIndividual
            return style[self]
        }
        set {
            // TODO: Como obtenemos el estilo en otros tipos
            let style = table.layer.style as GStyleIndividual
            style[self] = newValue
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    internal func addProperties(props:Dictionary<String, GPropertyType?>) {
        
        for (key, value) in props {
            _setPropValue(key, value:value, justUserProps:false)
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _setNamedProperties() {
        
        // SOLO ACCEDE A PROPIEDADES NO RESERVADAS (DE LAS CONOCIDAS) DE GOOGLE
        self.userProperties =  NamedSubscript<String, GPropertyType?>(
            getter: {
                return self._getPropValue($0, justUserProps: true)
            },
            setter: {
                let b = self._setPropValue($0, value: $1, justUserProps: true)
            },
            generator: {
                var schema_iterator = self.table.schema.generate()
                return GeneratorOf() {
                    while true {
                        if let item = schema_iterator.next() {
                            if !item.value.sysProp {
                                let name : String = item.key
                                return (name, self.rawPropValues[name]?)
                            }
                        } else {
                            return nil
                        }
                    }
                }
            }
        )
        
        
        // ACCEDE A TODAS PROPIEDADES
        self.allProperties =  RONamedSubscript<String, GPropertyType?>(
            getter: {
                return self._getPropValue($0, justUserProps: false)
            },
            generator: {
                var schema_iterator = self.table.schema.generate()
                return GeneratorOf() {
                    if let item = schema_iterator.next() {
                        let name : String = item.key
                        return (name, self.rawPropValues[name]?)
                    } else {
                        return nil
                    }
                }
            }
        )
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _getPropValue(name:String, justUserProps:Bool) -> GPropertyType? {
        
        // No se retorna nada que no este en el Schema y que sea del tipo adecuado
        if let (type, sysProp) = table.schema[name] {
            
            // Comprueba si debe restringir el acceso a SOLO las propiedades de usuario
            if justUserProps && sysProp {
                return nil
            }
            
            return rawPropValues[name]?
            
        } else {
            return nil
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _setPropValue(name:String, value: GPropertyType?, justUserProps:Bool) -> Bool {
        
        // No se deja asignar nada que no este en el Schema y que sea del tipo adecuado
        if let (type, sysProp) = table.schema[name] {
            
            // Comprueba si debe restringir el acceso a SOLO las propiedades de usuario
            if justUserProps && sysProp {
                return false
            }
            
            // Y si los tipos concuerdan o es NIL
            if value == nil || _valueHasProperType(value, type: type) {
                rawPropValues.updateValue(value, forKey: name)
                return true
            }
        }
        
        return false
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _valueHasProperType(value: GPropertyType?, type:GESchemaType) -> Bool {
        
        switch value {
        case let v as GGeometryPoint:
            return (type == GESchemaType.ST_GEOMETRY) || (geoType == GeoType.POINT)
            
        case let v as GGeometryLine:
            return (type == GESchemaType.ST_GEOMETRY) || (geoType == GeoType.LINE)
            
        case let v as GGeometryPolygon:
            return (type == GESchemaType.ST_GEOMETRY) || (geoType == GeoType.POLYGON)
            
        case let v as String:
            return type == GESchemaType.ST_STRING
            
        case let v as Double:
            return type == GESchemaType.ST_NUMERIC
            
        case let v as DateTime:
            return type == GESchemaType.ST_DATE
            
        case let v as Bool:
            return type == GESchemaType.ST_BOOL
            
        default:
            return false
        }
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    override internal var _assetClassName : String {
        return "GFeature";
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    override internal func _debugDescriptionInner(inout strVal:String, padding:String, tabIndex:UInt) {
        
        super._debugDescriptionInner(&strVal, padding: padding, tabIndex:tabIndex)
        
        strVal += "\(padding)title: '\(title)'\n"
        strVal += "\(padding)style: \(style)\n"
        strVal += "\(padding)properties: {\n"
        for (propName,(propType,sysProp)) in table.schema {
            if let propValue = rawPropValues[propName] {
                strVal += "\(padding)    '\(propName)' : \(propType) -> \(propValue)\n"
            }
        }
        strVal += "\(padding)}\n"
    }
    
}