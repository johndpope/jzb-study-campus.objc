//
//  ViewController.swift
//  GMapTest
//
//  Created by Jose Zarzuela on 26/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Cocoa
import MapKit
import JZBUtils
import GMapService


internal protocol MainViewController : NSObjectProtocol {
    func loadMap(mapGID:String)
    func selectFeature(feature:GFeature)
    func deselectFeature()
}

class ViewController: NSViewController, MainViewController {
    
    @IBOutlet weak var mapsTableView: NSTableView!
    @IBOutlet weak var mapDataTreeView: NSOutlineView!
    @IBOutlet weak var detailTableView: NSTableView!
    @IBOutlet weak var mapView: MKMapView!
    
    
    private var mapListWrapper : MapListTableWrapper!
    private var mapInfoWrapper : MapInfoTreeWrapper!
    private var mapViewWrapper:  MKMapViewWrapper!
    private var detailWrapper : DetailTableWrapper!
    
    
    //------------------------------------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view
        
        mapListWrapper = MapListTableWrapper(owner: self, tableView:mapsTableView)
        mapInfoWrapper = MapInfoTreeWrapper(owner: self, treeView: mapDataTreeView)
        mapViewWrapper = MKMapViewWrapper(owner: self, mapView: mapView)
        detailWrapper = DetailTableWrapper(owner: self, tableView:detailTableView)
        
        loadMapsFromCache()
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
    //------------------------------------------------------------------------------------------------------------------------
    internal func deselectFeature() {
        
        mapDataTreeView.deselectAll(nil)
        
        detailWrapper.feature = nil
        
        if mapView.selectedAnnotations != nil {
            for annotation in mapView.selectedAnnotations {
                mapView.deselectAnnotation(annotation as MKAnnotation, animated: false)
            }
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    internal func selectFeature(feature:GFeature) {
        
        // Detalle
        detailWrapper.feature = feature
        
        // Arbol de features
        let index = mapDataTreeView.rowForItem(feature)
        if index >= 0 {
            mapDataTreeView.selectRowIndexes(NSIndexSet(index:index), byExtendingSelection: false)
            
            //mapDataTreeView.scrollRowToVisible(index)
            // Con scroll
            let clipView = mapDataTreeView.superview as NSClipView
            let scrollView = clipView.superview as NSScrollView
            let range = mapDataTreeView.rowsInRect(scrollView.contentView.visibleRect)
            if index<range.location || index>=range.location+range.length {
                let rowRect = mapDataTreeView.rectOfRow(index)
                var scrollOrigin = rowRect.origin
                scrollOrigin.y += max(0, round(0.5*(rowRect.size.height-clipView.frame.size.height)))
                scrollView.flashScrollers()
                clipView.animator().setBoundsOrigin(scrollOrigin)
            }
        }
        
        // Mapa
        let geoPoint = feature.geometry as GGeometryPoint
        let center = CLLocationCoordinate2D(latitude: geoPoint.lat, longitude: geoPoint.lng)
        let span = MKCoordinateSpan(
            latitudeDelta: min(0.03, mapView.region.span.latitudeDelta),
            longitudeDelta: min(0.03, mapView.region.span.longitudeDelta))
        mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
        
        var fAnn : GPointAnnotation? = nil
        if mapView.annotations != nil {
            for annotation in mapView.annotations {
                if let item = annotation as? GPointAnnotation {
                    if item.feature_gid == feature.gid {
                        fAnn = item
                        break
                    }
                }
            }
        }
        
        if fAnn != nil {
            mapView.selectAnnotation(fAnn, animated: true)
        }
    }
    
    
    //------------------------------------------------------------------------------------------------------------------------
    internal func loadMap(mapGID:String) {
        
        self.mapViewWrapper.setMap(nil)
        self.mapInfoWrapper.map = nil
        self.detailWrapper.feature = nil
        
        
        Async.exec(
            { () -> (result: Any?, error: NSError?) in
                
                var srvc = GService(cacheUsage: ECacheUsage.READ_WRITE)
                
                let email = Crypto.decriptString("DRcAAiUGAA8TJRMKDAgccRAKDg==", passwd: "gmap_secret")
                let pwd = Crypto.decriptString("RBoEEigWB1JLUkU=", passwd: "gmap_secret")
                
                var error : NSError? = nil
                if srvc.login(email, password:pwd, error:&error) {
                    
                    let now1 = NSDate().timeIntervalSince1970
                    if let map = srvc.getMapData(mapGID, error:&error) {
                        
                        let now2 = NSDate().timeIntervalSince1970
                        println("**** CARGA DE MAPA '\(map.name)' EN: \(now2-now1)")
                        
                        return (map, nil)
                    }
                }
                
                return (nil, error)
                
            }, onSuccess: { (result:Any?) -> Void in
                
                let map = result as? GMap
                
                self.mapInfoWrapper.map = map
                self.mapViewWrapper.setMap(map)
                
            }, onError:{ (error) -> Void in
                
                println("**** Error loading GMap: \(error)")
            }
        )
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    private func loadMapsFromCache() {
        
        Async.exec(
            {
                var mapDataArray = CacheMapInfo.cachedMapNamesAndIDs()
                return mapDataArray
                
            }, onMain: { (result:Any?) -> Void in
                
                if let data = result as? Array<(name:String, gid:String)> {
                    self.mapListWrapper.mapDataArray = data
                } else {
                    self.mapListWrapper.mapDataArray = []
                }
                self.mapsTableView.reloadData()
            }
        )
        
        
    }
    
    
}


// =======================================================================================================================
// MARK: ---------------------------------------------------
// MARK: MapListTableWrapper
public class MapListTableWrapper : NSObject, NSTableViewDataSource, NSTableViewDelegate  {
    
    private let owner : MainViewController
    private let tableView: NSTableView!
    
    public var mapDataArray : Array<(name:String, gid:String)> = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    // ------------------------------------------------------------------------
    private init(owner : MainViewController, tableView: NSTableView!) {
        
        self.owner = owner
        self.tableView = tableView
        super.init()
        
        tableView.setDataSource(self)
        tableView.setDelegate(self)
        tableView.reloadData()
    }
    
    // ========================================================================
    // MARK: NSTableViewDataSource
    
    // ------------------------------------------------------------------------
    public func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return mapDataArray.count
    }
    
    // ------------------------------------------------------------------------
    public func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return NSString(string: mapDataArray[row].name)
    }
    
    
    // ========================================================================
    // MARK: NSTableViewDelegate
    
    // ------------------------------------------------------------------------
    public func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        owner.loadMap(mapDataArray[row].gid)
        return true
    }
    
}


// =======================================================================================================================
// MARK: ---------------------------------------------------
// MARK: MapInfoTreeWrapper
public class MapInfoTreeWrapper : NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate  {
    
    private let owner : MainViewController
    private let treeView: NSOutlineView!
    
    
    public var map : GMap?  {
        didSet {
            treeView.reloadData()
            treeView.expandItem(nil, expandChildren: true)
        }
    }
    
    // ------------------------------------------------------------------------
    private init(owner : MainViewController, treeView: NSOutlineView!) {
        
        self.owner = owner
        self.treeView = treeView
        super.init()
        
        treeView.setDataSource(self)
        treeView.setDelegate(self)
        treeView.reloadData()
    }
    
    // ========================================================================
    // MARK: NSOutlineViewDataSource
    
    // ------------------------------------------------------------------------
    public func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        
        switch item {
            
        case nil:
            return map?.layers[index] ?? NSNull()
            
        case let layer as GLayer:
            return layer.table.features[index]
            
        default:
            return "NoSe"
            
        }
    }
    
    // ------------------------------------------------------------------------
    public func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        
        switch item {
            
        case nil:
            return map?.layers.count ?? 0
            
        case let layer as GLayer:
            return layer.table.features.count
            
        default:
            return 0
            
        }
    }
    
    // ------------------------------------------------------------------------
    public func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        
        return item is GLayer
    }
    
    // ------------------------------------------------------------------------
    public func outlineView(outlineView: NSOutlineView, shouldSelectItem item: AnyObject) -> Bool {
        
        if let feature = item as? GFeature {
            
            if feature.geometry is GGeometryPoint {
                owner.selectFeature(feature)
            }
        }
        
        return true
    }
    
    
    // ========================================================================
    // MARK: NSOutlineViewDelegate
    
    public func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        
        
        var title : String!
        var image : NSImage? = nil
        
        switch item {
            
        case let layer as GLayer:
            title = layer.name
            
        case let feature as GFeature:
            title = feature.title
            
            if feature.geometry is GGeometryPoint {
                let style = feature.style as GStyleInfoPoint
                image = GStyleIndividual.imageForIcon(style.iconID)
            }
            
        default:
            title = "*No*Se*"
            
        }
        
        
        if let cellView = outlineView.makeViewWithIdentifier("MyTreeCell", owner: owner) as? NSTableCellView {
            
            cellView.textField?.stringValue = title
            cellView.imageView?.image=image
            return cellView
            
        } else {
            return nil
        }
        
    }
    
}

// =======================================================================================================================
// MARK: ---------------------------------------------------
// MARK: MKMapViewWrapper
public class MKMapViewWrapper : NSObject, MKMapViewDelegate  {
    
    
    private let owner : MainViewController
    private var overlay : MKTileOverlay!
    private let mapView: MKMapView
    private var map : GMap?
    private var lines = Dictionary<MKPolyline,GStyleInfo>()
    
    // ------------------------------------------------------------------------
    private init(owner: MainViewController, mapView: MKMapView!) {
        
        self.owner = owner
        self.mapView = mapView
        super.init()
        
        mapView.delegate = self
        
        let template = "http://tile.openstreetmap.org/{z}/{x}/{y}.png"
        overlay = MKTileOverlay(URLTemplate: template)
        overlay.canReplaceMapContent = true
        mapView.addOverlay(overlay, level: MKOverlayLevel.AboveLabels)
        
    }
    
    // ------------------------------------------------------------------------
    public func setMap(newMap:GMap?) {
        
        self.map = newMap
        mapView.removeAnnotations(mapView.annotations)
        
        var lineOverlays = Array<AnyObject>()
        for overlay in mapView.overlays {
            if overlay is MKPolyline {
                lineOverlays.append(overlay)
            }
        }
        mapView.removeOverlays(lineOverlays)
        
        lines.removeAll()
        
        if newMap == nil {
            return
        }
        
        var minLat = Double.infinity
        var maxLat = -Double.infinity
        
        var minLng = Double.infinity
        var maxLng = -Double.infinity
        
        for layer in map!.layers {
            for feature in layer.table.features {
                switch feature.geometry {
                    
                case let geoPoint as GGeometryPoint:
                    minLat = min(minLat,geoPoint.lat)
                    maxLat = max(maxLat,geoPoint.lat)
                    
                    minLng = min(minLng,geoPoint.lng)
                    maxLng = max(maxLng,geoPoint.lng)
                    
                    mapView.addAnnotation(GPointAnnotation(feature:feature))
                    
                case let geoLine as GGeometryLine:
                    // mapView.addOverlay(GLineOverlay(feature: feature), level: MKOverlayLevel.AboveLabels)
                    
                    let geoLine = feature.geometry as GGeometryLine
                    var coords = geoLine.coordinates
                    let polyLine = MKPolyline(coordinates:&coords, count:coords.count)
                    polyLine.title = feature.title
                    
                    self.lines[polyLine] = feature.style
                    
                    mapView.addOverlay(polyLine, level: MKOverlayLevel.AboveLabels)
                    
                    
                default:
                    break
                }
                
            }
        }
        
        if abs(minLat) != Double.infinity && abs(maxLat) != Double.infinity && abs(minLng) != Double.infinity && abs(maxLng) != Double.infinity {
            let center = CLLocationCoordinate2D(latitude: (minLat+maxLat)/2, longitude: (minLng+maxLng)/2)
            let span = MKCoordinateSpan(latitudeDelta: 1.05*(maxLat-minLat), longitudeDelta: 1.05*(maxLng-minLng))
            mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
        }
        
    }
    
    // ========================================================================
    // MARK: MKMapViewDelegate
    
    // ------------------------------------------------------------------------
    public func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        
        switch overlay {
            
        case let tile as MKTileOverlay:
            return MKTileOverlayRenderer(overlay:overlay)
            
        case let line as GLineOverlay:
            var polylineRenderer = MKPolylineRenderer(overlay: line.polyLine)
            polylineRenderer.strokeColor = NSColor.colorWithHexString(line.style.colorHex, alpha: line.style.alpha)
            polylineRenderer.lineWidth = CGFloat(line.style.width)/1000.0
            return polylineRenderer
            
        case let line as MKPolyline:
            var polylineRenderer = MKPolylineRenderer(overlay: overlay)
            if let style = lines[line] as? GStyleInfoLine {
                polylineRenderer.strokeColor = NSColor.colorWithHexString(style.colorHex, alpha: style.alpha)
                polylineRenderer.lineWidth = CGFloat(style.width)/1000.0
            } else {
                polylineRenderer.strokeColor = NSColor.blackColor()
                polylineRenderer.lineWidth = 10.0
            }
            return polylineRenderer
            
        default:
            return nil
        }
        
    }
    
    // ------------------------------------------------------------------------
    public func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let fAnn : GPointAnnotation! = annotation as?  GPointAnnotation
        
        if fAnn == nil {
            return nil
        }
        
        let reuseId = "test"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView.canShowCallout = true
        }
        
        anView.annotation = fAnn
        anView.image = fAnn.image
        
        return anView
    }
    
    // ------------------------------------------------------------------------
    public func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        
        if let fAnn = view.annotation as? GPointAnnotation {
            if let feature = map?.featureByID(fAnn.feature_gid) {
                owner.selectFeature(feature)
            }
        }
    }
    
    // ------------------------------------------------------------------------
    public func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
        owner.deselectFeature()
    }
    
}


// =======================================================================================================================
// MARK: ---------------------------------------------------
// MARK: DetailTableWrapper
public class DetailTableWrapper : NSObject, NSTableViewDataSource, NSTableViewDelegate  {
    
    private let owner : MainViewController
    private let tableView: NSTableView!
    
    public var feature : GFeature?   {
        didSet {
            tableView.reloadData()
        }
    }
    
    // ------------------------------------------------------------------------
    private init(owner : MainViewController, tableView: NSTableView!) {
        
        self.owner = owner
        self.tableView = tableView
        super.init()
        
        tableView.setDataSource(self)
        tableView.setDelegate(self)
        tableView.reloadData()
    }
    
    // ========================================================================
    // MARK: NSTableViewDataSource
    
    // ------------------------------------------------------------------------
    public func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return feature?.table.schema.count ?? 0
    }
    
    // ------------------------------------------------------------------------
    public func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        var result = "*NoSe*"
        
        if let feature = self.feature {

            feature.userProperties["pepe"] = "juan"
            
            if let (name, _) = feature.table.schema.byIndex(row) {
                
                let id : String = tableColumn?.identifier ?? ""
                result = (id == "col_name") ? name : (feature.allProperties[name]?.description ?? "nil")
                
            }
            
        }
        
        return result
    }
    
    
    // ========================================================================
    // MARK: NSTableViewDelegate
    
    // ------------------------------------------------------------------------
    
}



// =======================================================================================================================
// MARK: ---------------------------------------------------
// MARK: GPointAnnotation
public class GPointAnnotation : NSObject, MKAnnotation {
    
    public let feature_gid : String
    public let coordinate : CLLocationCoordinate2D
    public let title : String
    public let image : NSImage?
    
    // ------------------------------------------------------------------------
    public init(feature:GFeature) {
        
        self.feature_gid = feature.gid
        
        if let coord = feature.geometry as? GGeometryPoint {
            self.coordinate = coord.coordinate
            let style = feature.style as GStyleInfoPoint
            self.image = GStyleIndividual.imageForIcon(style.iconID)
        } else {
            self.coordinate = CLLocationCoordinate2D(latitude:0, longitude:0)
            self.image = nil
        }
        
        self.title = feature.title
    }
    
}

// =======================================================================================================================
// MARK: ---------------------------------------------------
// MARK: GPointAnnotation
@objc public class GLineOverlay : NSObject, MKOverlay {
    
    public let feature_gid : String
    public let style : GStyleInfoLine
    public let polyLine : MKPolyline
    
    // ------------------------------------------------------------------------
    public init(feature:GFeature) {
        
        let geoLine = feature.geometry as GGeometryLine
        var coords = geoLine.coordinates
        self.polyLine = MKPolyline(coordinates:&coords, count:coords.count)
        
        polyLine.title = feature.title
        
        self.style = feature.style as GStyleInfoLine
        self.feature_gid = feature.gid
        
        super.init()
    }
    
    // ------------------------------------------------------------------------
    public var coordinate: CLLocationCoordinate2D {
        return polyLine.coordinate
    }
    
    // ------------------------------------------------------------------------
    public var boundingMapRect: MKMapRect {
        return polyLine.boundingMapRect
    }
    
    // ------------------------------------------------------------------------
    public func intersectsMapRect(mapRect: MKMapRect) -> Bool {
        return polyLine.intersectsMapRect(mapRect)
    }
    
    // ------------------------------------------------------------------------
    public func canReplaceMapContent() -> Bool {
        return polyLine.canReplaceMapContent()
    }
    
}

internal extension NSColor {
    
    class func colorWithHexString(hex:String, alpha:Double) -> NSColor {
        
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.subString(1)
        }
        
        if (countElements(cString) != 6) {
            return NSColor.grayColor()
        }
        
        var rString = cString.subString(0, length: 2)
        var gString = cString.subString(2, length: 2)
        var bString = cString.subString(4, length: 2)
        
        var r:UInt32 = 0, g:UInt32 = 0, b:UInt32 = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
        
        let fr : CGFloat = CGFloat(r) / 255.0
        let fg : CGFloat = CGFloat(g) / 255.0
        let fb : CGFloat = CGFloat(b) / 255.0
        
        return NSColor(red: fr, green: fg, blue: fb, alpha: CGFloat(alpha))
    }
    
}



