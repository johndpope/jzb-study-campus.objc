class MyClass {
    var p2:String?
}

class MyOtherClass {
    private var prop:MyClass?
    private(set) var numberOfEdits = 0
}


var v = MyOtherClass()

if let value = v.prop?.p2 {
    println(value)
}

v.numberOfEdits = 2

v