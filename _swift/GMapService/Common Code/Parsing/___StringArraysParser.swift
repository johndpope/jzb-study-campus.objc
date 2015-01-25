//
//  MapArrayParser.swift
//  GMapService
//
//  Created by Jose Zarzuela on 30/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation

// Posibles tipos de valores que pueden recibirse
internal protocol TArrayValue {
    var typeName : String {get}
}


extension NSNull : TArrayValue {
    internal var typeName : String {
        return "NSNull"
    }
}

extension String : TArrayValue {
    internal var typeName : String {
        return "String"
    }
}

extension Int64  : TArrayValue {
    internal var typeName : String {
        return "Int64"
    }
}

extension Double : TArrayValue {
    internal var typeName : String {
        return "Double"
    }
}

extension Bool   : TArrayValue {
    internal var typeName : String {
        return "Bool"
    }
}

extension Array  : TArrayValue {
    internal var typeName : String {
        return "Array"
    }
}



//------------------------------------------------------------------------------------------------------------------------
internal func prettyPrint(value:TArrayValue) {
    
    _prettyPrint(value, "", "")
    println()
}


//------------------------------------------------------------------------------------------------------------------------
private func _prettyPrint(value:TArrayValue, padding:String, strIndex:String) {
    
    switch value {
        
    case let array as Array<TArrayValue>:
        
        var noArrays = array.reduce(true) {
            (pV,item) -> Bool in
            let isArray = item is Array<TArrayValue>
            return pV && !isArray
        }
        
        if noArrays {
            
            print("[")
            for (index, item) in enumerate(array) {
                if index>0 {
                    print(", ")
                }
                _prettyPrint(item,"","")
            }
            print("]")
            
        } else {
            
            print("[\n")
            for (index, item) in enumerate(array) {
                let iStr = String(format: "%02d", index)
                print("\(padding)\(strIndex)\(iStr): ")
                _prettyPrint(item, "\(padding)    ","\(strIndex)\(iStr).")
                print("\n")
            }
            print("\(padding)]")
            
        }
        
    case let v as String:
        print("'\(v)'")
        
    case let v as Bool:
        let vv = v ? "true" : "false"
        print("\(vv)")
        
    default:
        print(value)
        
    }
}



//============================================================================================================================
internal class StringArraysParser {
    
    
    //------------------------------------------------------------------------------------------------------------------------
    internal class func parseStringArrays(jsonMapData:String, inout error:NSError?) -> Array<TArrayValue>? {
        
        var arrayStack = Array<Array<TArrayValue>>()
        var currentArray = Array<TArrayValue>()
        var currentValue : String? = ""
        var inString : Bool = false
        var prevChar = Character(" ")
        
        var iterator = jsonMapData.generate()
        while let c = _nextChar(&iterator, error:&error) {
            
            //println("c -> \(c)")
            
            // Marca si esta procesando una cadena
            if c == "\"" && prevChar != "\\" {
                inString = !inString
            }
            
            // Cuando esta en una cadena todo se añade
            if inString {
                currentValue?.append(c)
                continue
            }
            
            // Procesa el caracter leido
            switch c {
                
            case "[":
                arrayStack.append(currentArray)
                currentArray = Array<TArrayValue>()
                currentValue = ""
                
            case "]":
                if !_addCurrentValue(currentValue, toArray: &currentArray, error: &error) {
                    return nil
                }
                
                if arrayStack.count <= 0 {
                    error = _error("Unbalanced ']' found")
                    return nil
                }
                
                var parentArray = arrayStack.removeLast()
                parentArray.append(currentArray)
                currentArray = parentArray
                currentValue = nil
                
                
            case ",":
                if !_addCurrentValue(currentValue, toArray: &currentArray, error: &error) {
                    return nil
                }
                currentValue = ""
                
            default:
                currentValue?.append(c)
            }
            
            // Recuerda el ultimo caracter
            prevChar = c
            
        }
        
        
        // Comprobamos que se han cerrado todos los elementos
        if arrayStack.count > 0 {
            error = _error("Unbalanced '[' found")
            return nil
        } else {
            let result : Array<TArrayValue>  = currentArray[0] as Array<TArrayValue>
            return result
        }
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private class func _addCurrentValue(strValue:String?, inout toArray currentArray:Array<TArrayValue>, inout error:NSError?) -> Bool {
        
        // Mira si hay un valor
        if strValue == nil {
            return true
        }
        
        
        // Procesa el valor actual y lo deja vacio para el siguiente
        var str = strValue!.trim()
        
        
        while str.hasSuffix("\n") {
            str = str.subString(0, endIndex: str.length-1).trim()
        }
        
        let len = str.length
        
        // Es un valor null
        if len == 0 {
            currentArray.append(NSNull())
            return true
        }
        
        // Es un boolean
        if str == "true" || str == "false" {
            let boolValue = (str as NSString).boolValue
            currentArray.append(boolValue)
            return true
        }
        
        // Es una cadena de texto
        if str.hasPrefix("\"") && str.hasSuffix("\"") {
            let strValue = str.subString(1, endIndex: str.length-1)
            currentArray.append(strValue)
            return true
        }
        
        // Es un numero
        let c = str[0]
        if (c >= "0" && c <= "9") || c == "-" {
            if str.indexOf(".")>0 {
                let doubleValue = (str as NSString).doubleValue
                currentArray.append(doubleValue)
                return true
            } else {
                let intValue : Int64 = (str as NSString).longLongValue
                currentArray.append(intValue)
                return true
            }
        }
        
        // No sabemos como parsear ese valor
        error = _error("Unknown type value: \(strValue)")
        return false
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private class func _nextChar(inout iterator:IndexingGenerator<String>, inout error:NSError?) -> Character? {
        
        // Consigue el siguiente caracter pendiente
        if let c1 = iterator.next() {
            
            // Si no es el caracter de escape lo retorna
            if c1 != "\\" {
                return c1
            }
            
            // Procesa el caracter de control
            if let c2 = iterator.next() {
                
                switch c2 {
                    
                case "(":
                    return "("
                    
                case ")":
                    return ")"
                    
                case "n":
                    return "\n"
                    
                case "t":
                    return "\t"
                    
                case "\"":
                    return "\""
                    
                case "\\":
                    return "\\"
                    
                case "u":
                    if let hexChar = _scanHexChar(&iterator, error: &error) {
                        return hexChar
                    } else {
                        return nil
                    }
                    
                default:
                    error = _error("Error processing unknown control character: '\(c2)'")
                    return nil
                }
                
            } else {
                error = _error("End of data processing control character")
                return nil
            }
            
        } else {
            
            // Se han terminado los caracteres a procesar
            return nil
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private class func _scanHexChar(inout iterator:IndexingGenerator<String>, inout error:NSError?) -> Character? {
        
        var hexStr = ""
        for _ in 1...4 {
            if let c = iterator.next() {
                hexStr.append(c)
            } else {
                error = _error("Error reading \\uxxxx character from string: Not enough chars")
                return nil
            }
        }
        
        var value : UInt32 = 0
        let scanner = NSScanner(string: hexStr)
        
        if scanner.scanHexInt(&value) {
            return Character(UnicodeScalar(value))
        } else {
            error = _error("Error reading \\uxxxx character from string: \(hexStr)")
            return nil
        }
        
    }
    
}