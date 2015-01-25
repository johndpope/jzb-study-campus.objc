//
//  MapArrayParser.swift
//  GMapService
//
//  Created by Jose Zarzuela on 30/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation
import JZBUtils


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
internal func prettyPrint(value:TArrayValue?, showAllIndexes:Bool = true) {
    
    if value != nil {
        _prettyPrint(value!, "", "", showAllIndexes)
    } else {
        println("*nil*")
    }
    println()
}


//------------------------------------------------------------------------------------------------------------------------
private func _prettyPrint(value:TArrayValue, padding:String, strIndex:String, showAllIndexes:Bool) {
    
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
                _prettyPrint(item,"","",showAllIndexes)
            }
            print("]")
            
        } else {
            
            print("[\n")
            for (index, item) in enumerate(array) {
                let iStr = String(format: "%02d", index)
                if showAllIndexes {
                    print("\(padding)\(strIndex)\(iStr): ")
                } else {
                    print("\(padding)\(iStr): ")
                }
                _prettyPrint(item, "\(padding)    ","\(strIndex)\(iStr).",showAllIndexes)
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
        var prevChar = UInt32(0)
        
        
        let iterator = UnicodeIterator(strValue: jsonMapData)

        while let c = _nextUnicode(iterator, error:&error) {
            
            //println("c -> \(c)")
            
            // Marca si esta procesando una cadena
            if c == 34 && prevChar != 92 {
                inString = !inString
            }
            
            // Cuando esta en una cadena todo se añade
            if inString {
                currentValue?.append(UnicodeScalar(c))
                continue
            }
            
            // Procesa el caracter leido
            switch c {
                
            case 91:  // [
                arrayStack.append(currentArray)
                currentArray = Array<TArrayValue>()
                currentValue = ""
                
            case 93:  // ]
                if currentValue != nil && !_addCurrentValue(currentValue!, toArray: &currentArray, error: &error) {
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
                
                
            case 44: // ,
                if currentValue != nil && !_addCurrentValue(currentValue!, toArray: &currentArray, error: &error) {
                    return nil
                }
                currentValue = ""

            case 32, 9, 10, 13: // espacio, \n, \t
                // como no esta dentro de una cadena, se salta estos caracteres
                break

            default:
                currentValue?.append(UnicodeScalar(c))
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
    private class func _addCurrentValue(str:String, inout toArray currentArray:Array<TArrayValue>, inout error:NSError?) -> Bool {
        
        let len = distance(str.startIndex, str.endIndex)
        
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
        error = _error("Unknown type value: \(str)")
        return false
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private class func _nextUnicode(iterator:UnicodeIterator, inout error:NSError?) -> UInt32? {
        
        // Consigue el siguiente caracter pendiente
        if let c1 = iterator.next() {
            
            // Si no es el caracter de escape lo retorna
            if c1 != 92 { // \
                return c1
            }
            
            // Procesa el caracter de control
            if let c2 = iterator.next() {
                
                switch c2 {
                    
                case 40:            // (
                    return 40
                    
                case 41:            // )
                    return 41
                    
                case 110:           // n
                    return 10       // \n
                    
                case 116:           // t
                    return 9        // \t
                    
                case 34:            // "
                    return 34
                    
                case 92:            // \
                    return 92
                    
                case 117:           // u
                    if let hexChar = _scanHexChar(iterator, error: &error) {
                        return hexChar
                    } else {
                        return nil
                    }
                    
                default:
                    error = _error("Error processing unknown control character: '\(c2)'", prevError:iterator.error)
                    return nil
                }
                
            } else {
                error = _error("End of data processing control character", prevError:iterator.error)
                return nil
            }
            
        } else {
            
            // Se han terminado los caracteres a procesar
            error = iterator.error
            return nil
        }
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private class func _scanHexChar(iterator:UnicodeIterator, inout error:NSError?) -> UInt32? {
        
        var value = UInt32(0)
        for _ in 1...4 {
            if let x = iterator.next() {
                switch x {
                case 48...57:
                    value = (value << 4) | (UInt32(x)-UInt32(48))
                case 65...70:
                    value = (value << 4) | (UInt32(x)-UInt32(55))
                case 97...102:
                    value = (value << 4) | (UInt32(x)-UInt32(87))
                default:
                    error = _error("Error reading \\uxxxx character from string. UnicodeScalar: \(x)")
                    return nil
                }
            } else {
                error = _error("Error reading \\uxxxx character from string: Not enough chars")
                return nil
            }
        }
        return value
    }
    
}






