//
//  GGeometry.swift
//  GMapService
//
//  Created by Jose Zarzuela on 31/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation
import CoreLocation


public protocol GGeometry : GPropertyType, Printable, DebugPrintable {
    
}


//------------------------------------------------------------------------------------------------------------------------
public struct GGeometryPoint : GGeometry  {
    
    public let lat : Double
    public let lng : Double
    
    public init(lng:Double, lat:Double) {
        self.lat = lat
        self.lng = lng
    }

    internal init(array:[Double]) {
        assert(array.count==2, "GGeometryPoint initialization array size must be 2")
        self.lat = array[0]
        self.lng = array[1]
    }

    internal func toArray() -> [Double] {
        return [lat,lng]
    }
    
    public var coordinate : CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    
    public var debugDescription : String {
        return "GGeometryPoint [lat:\(lat), lng:\(lng)]"
    }
    
    public var description : String {
        return debugDescription
    }
}


//------------------------------------------------------------------------------------------------------------------------
public struct GGeometryLine : GGeometry {
    
    public let points : Array<GGeometryPoint> = []
    
    public init(points : Array<GGeometryPoint> = []) {
        self.points = points
    }
    
    internal init(array:[[Double]]) {
        for pointArray in array {
            let point = GGeometryPoint(array: pointArray)
            points.append(point)
        }
    }
    
    internal func toArray() -> [[Double]] {
        var array : [[Double]] = []
        for point in points {
            array.append(point.toArray())
        }
        return array
    }

    public var coordinates : [CLLocationCoordinate2D] {
        var array : [CLLocationCoordinate2D] = points.map { $0.coordinate }
        return array
    }
    
    public var debugDescription : String {
        var str = "GGeometryLine ["
        for (index, point) in enumerate(points) {
            str += index > 0 ? ", " : ""
            str += point.debugDescription
        }
        str += "]"
        return str
    }
    
    public var description : String {
        return debugDescription
    }
}


//------------------------------------------------------------------------------------------------------------------------
public struct GGeometryPolygon : GGeometry {
    
    public let points : Array<GGeometryPoint> = []
    
    public init(points : Array<GGeometryPoint> = []) {
        self.points = points
    }
    
    internal init(array:[[Double]]) {
        for pointArray in array {
            let point = GGeometryPoint(array: pointArray)
            points.append(point)
        }
    }
    
    internal func toArray() -> [[Double]] {
        var array : [[Double]] = []
        for point in points {
            array.append(point.toArray())
        }
        return array
    }

    public var coordinates : [CLLocationCoordinate2D] {
        var array : [CLLocationCoordinate2D] = points.map { $0.coordinate }
        return array
    }

    public var debugDescription : String {
        var str = "GGeometryPolygon ["
        for (index, point) in enumerate(points) {
            str += index > 0 ? ", " : ""
            str += point.debugDescription
        }
        str += "]"
        return str
    }
    
    public var description : String {
        return debugDescription
    }
}