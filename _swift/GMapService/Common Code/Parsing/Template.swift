//
//  Template.swift
//  GMapService
//
//  Created by Jose Zarzuela on 31/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation
import JZBUtils

private let TEMPLATE_EXCEPTION = "TEMPLATE_EXCEPTION"

//------------------------------------------------------------------------------------------------------------------------
internal enum EFieldType : String, DebugPrintable {
    
    case FT_NSNull  = "FT_NSNull"
    case FT_String  = "FT_String"
    case FT_Int64   = "FT_Int64"
    case FT_Double  = "FT_Double"
    case FT_Bool    = "FT_Bool"
    case FT_Array   = "FT_Array"
    case FT_Unknown = "FT_Unknown"
    
    internal var debugDescription : String {
        return self.rawValue
    }
}

//------------------------------------------------------------------------------------------------------------------------
internal struct Field : DebugPrintable {
    private var name:String
    private let type:EFieldType
    private let indexes:[Int]
    private let optional:Bool
    
    internal init(name:String, type:EFieldType, indexes:[Int], optional:Bool = false) {
        self.name = name
        self.type = type
        self.indexes = indexes
        self.optional = optional
    }
    
    internal var debugDescription : String {
        return "Field: {name: '\(name)', type: \(type), indexes: \(indexes), optional: \(optional)"
    }
}

//------------------------------------------------------------------------------------------------------------------------
internal struct ValueWrapper : Printable, DebugPrintable {
    
    private let value : TArrayValue
    
    private init(value:TArrayValue) {
        self.value = value
    }
    
    internal var string : String {
        return (value is String) ? value as String : ""
    }

    internal var optString : String? {
        return value as? String
    }

    internal var int64 : Int64 {
        return (value is Int64) ? value as Int64 : Int64(0)
    }
    
    internal var optInt64 : Int64? {
        return value as? Int64
    }

    internal var double : Double {
        return (value is Double) ? value as Double : Double(0)
    }

    internal var optDouble : Double? {
        return value as? Double
    }
    
    internal var bool : Bool {
        return (value is Bool) ? value as Bool : false
    }
    
    internal var optBool : Bool? {
        return value as? Bool
    }

    internal var array : Array<TArrayValue> {
        return (value is Array<TArrayValue>) ? value as Array<TArrayValue> : Array<TArrayValue>()
    }

    internal var optArray : Array<TArrayValue>? {
        return value as? Array<TArrayValue>
    }

    internal var debugDescription : String {
        return "\(value)"
    }
    
    internal var description : String {
        return debugDescription
    }
}



//------------------------------------------------------------------------------------------------------------------------
internal class Template {
    
    private let templateName : String
    private let data : Array<TArrayValue>
    private var values = Dictionary<String,ValueWrapper>()
    
    
    //------------------------------------------------------------------------------------------------------------------------
    internal init(_ name:String, data:TArrayValue?) {
        
        if data == nil || !(data is Array<TArrayValue>) {
            throw(TEMPLATE_EXCEPTION, "Template data for '\(name)' should be a not nil Array<TArrayValue> instance: '\(data?.typeName)'")
        }
        self.data = data as Array<TArrayValue>
        self.templateName = name
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    internal subscript(name:String) -> ValueWrapper {
        
        if let v = values[name] {
            return v
        } else {
            return ValueWrapper(value: NSNull())
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    internal func define(fields:Field...) {
        
        for field in fields {
            let value = _defineOne(field)
            values[field.name] = value
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _defineOne(field:Field) -> ValueWrapper {
        
        if let value = _innerFieldValue(field.indexes) {
            
            var realType =  _fieldType(value)
            
            if field.type == realType {
                return ValueWrapper(value:value)
            } else {
                return GBaseParser._throwExceptionNil("Template: '\(templateName)' => Field '\(field.name)' real type (\(realType)) doesn't match specified value's type (\(field.type))")
            }
            
        } else {
            
            if !field.optional {
                return GBaseParser._throwExceptionNil("Template: '\(templateName)' => Field '\(field.name)' is not optional and was not found at indexes \(field.indexes)")
            } else {
                return ValueWrapper(value:NSNull())
            }
            
        }
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _innerFieldValue(indexes:[Int]) -> TArrayValue? {
        
        var value : TArrayValue? = nil
        
        var container = data
        
        // Primero itera los indices intermedios
        for(var n=0;n<(indexes.count-1);n++) {
            
            let index = indexes[n]
            
            if index<0 || index >= container.count {
                return nil
            }
            
            value = container[index]
            
            if value is Array<TArrayValue> {
                container = value as Array
            } else {
                return nil
            }
        }
        
        
        // Recoge el ultimo valor
        let index2 = indexes[indexes.count-1]
        
        if index2<0 || index2 >= container.count {
            return nil
        }
        
        value = container[index2]
        
        return value is NSNull ? nil : value
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private func _fieldType(value:TArrayValue) -> EFieldType {
        
        switch value {
            
        case let x as NSNull:
            return .FT_NSNull
            
        case let x as String:
            return .FT_String
            
        case let x as Int64:
            return .FT_Int64
            
        case let x as Double:
            return .FT_Double
            
        case let x as Bool:
            return .FT_Bool
            
        case let x as Array<TArrayValue>:
            return .FT_Array
            
        default:
            return .FT_Unknown
        }
    }
    
}
