// Playground - noun: a place where people can play

import Foundation

var str = "Hello, playground"



class constrained<K : Hashable, V> {
    
    private let ptr : UnsafeMutablePointer<Dictionary<K,V>?>
    
    init(dict:UnsafeMutablePointer<Dictionary<K,V>?>) {
        self.ptr = dict
    }
    
    func pepe(key:K, value:V) {
        ptr.memory?.updateValue(value, forKey: key)
    }
    
    func juan() -> Dictionary<K,V>? {
        return ptr.memory
    }
    
}

class malo {
    
    private var dict : Dictionary<String,Int>? = ["uno":1, "dos":2, "tres":3]
    
    deinit {
        println("deinit malo")
    }
    
    func mata() -> constrained<String,Int> {
        return constrained(dict: &self.dict)
    }
    
    func dor() {
        dict = ["uno":11, "dos":22, "tres":33]
        dict = nil
    }
    
}

var m : malo? = malo()

/*
var x = m?.mata()

x?.juan()

m?.dor()

x?.juan()
*/
m = nil




