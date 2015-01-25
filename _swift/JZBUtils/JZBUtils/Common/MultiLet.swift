//
//  MultiLet.swift
//  JZBUtils
//
//  Created by Jose Zarzuela on 01/01/2015.
//  Copyright (c) 2015 Jose Zarzuela. All rights reserved.
//

import Foundation


//------------------------------------------------------------------------------------------------------------------------
public class MultiLetResult {
    
    private var items : Dictionary<String,Any> = [:]
    
    internal init() {
        
    }
    
    public func $<T>(name:String) -> T! {
        let value = items[name]
        assert(value != nil, "Cannot access item with name not defined previously: '\(name)'")
        return value! as T
    }
    
    internal func set(name:String, value:Any) {
        items[name]=value
    }
    
}

//------------------------------------------------------------------------------------------------------------------------
public func multiLet(items:Dictionary<String,Any?>) -> MultiLetResult? {
    
    // Donde pondra la copia si todos son no NIL
    var newItems = MultiLetResult()
    
    // Comprueba todos los elementos
    for (key, value) in items {
        
        if let v = value {
            // Almacena ese valor como no opcional
            newItems.set(key, value:v)
        } else {
            // Si algun valor es NIL no retorna nada
            return nil
        }
        
    }
    
    // Todos los valores eran no NIL
    return newItems
}

//------------------------------------------------------------------------------------------------------------------------
public func multiLet(inout result:MultiLetResult!, items:Dictionary<String,Any?>) -> Bool {
    
    result = multiLet(items)
    return result != nil
}
