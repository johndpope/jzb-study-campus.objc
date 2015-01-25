//
//  OrderedDictionary.swift
//  JZBUtils
//
//  Created by Jose Zarzuela on 24/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation


public struct OrderedDictionary<Key:Hashable, Value> : DebugPrintable, SequenceType {
    
    private var _dict : Dictionary<Key,Value> = [:]
    private var _keys : [Key] = []

    
    //------------------------------------------------------------------------------------------------------------------------
    public init() {
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    public func generate() -> GeneratorOf<(key:Key, value:Value)> {
        
        var index = 0
        
        return GeneratorOf() {
            
            if self._keys.isEmpty {
                return nil
            } else if(index<self._keys.count){
                let key = self._keys[index++]
                let value = self._dict[key]!
                return (key, value)
            } else {
                return nil
            }
        }
    }
    
    
    //------------------------------------------------------------------------------------------------------------------------
    public func byIndex(index : Int) -> (key:Key, value:Value)? {

        if index>=0 && index<_keys.count {
            let key = _keys[index]
            return (key, _dict[key]!)
        } else {
            return nil
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    public subscript (key : Key?) -> Value? {
        
        get {
            let value = (key != nil ? _dict[key!] : nil)
            return value
        }
        set {
            if key == nil {
                return
            }
            if newValue != nil {
                if _dict.updateValue(newValue!, forKey: key!) == nil {
                    _keys.append(key!)
                }
            } else {
                if _dict.removeValueForKey(key!) != nil {
                    if let index = find(_keys, key!) {
                        _keys.removeAtIndex(index)
                    }
                }
            }
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    public var count : Int {
        return _keys.count
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    public var keys : KeysSequence<Key> {
        return KeysSequence<Key>(keys: _keys)
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    public var values : ValuesSequence<Key, Value> {
        return ValuesSequence<Key, Value>(keys: _keys, values:_dict)
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    public var debugDescription : String {
        
        var strVal = "{ "
        for key in _keys {
            strVal += "[\(key) : \(_dict[key])] "
        }
        strVal += "}"
        
        return strVal
    }
    
}


//========================================================================================================================
public struct KeysSequence<Key:Hashable> : SequenceType {
    
    private let keys : [Key]
    
    internal init(keys:[Key]) {
        self.keys = keys
    }
    
    public func generate() -> GeneratorOf<Key> {
        
        var index = 0
        
        return GeneratorOf() {
            
            if self.keys.isEmpty {
                return nil
            } else if(index<self.keys.count){
                let key = self.keys[index++]
                return key
            } else {
                return nil
            }
        }
    }
}

//========================================================================================================================
public struct ValuesSequence<Key:Hashable,Value> : SequenceType {
    
    private let values : [Key:Value]
    private let keys : [Key]
    
    internal init(keys:[Key], values:[Key:Value]) {
        self.keys = keys
        self.values = values
    }
    
    public func generate() -> GeneratorOf<Value> {
        
        var index = 0
        
        return GeneratorOf() {
            
            if self.keys.isEmpty {
                return nil
            } else if(index<self.keys.count){
                let key = self.keys[index++]
                return self.values[key]
            } else {
                return nil
            }
        }
    }
}
