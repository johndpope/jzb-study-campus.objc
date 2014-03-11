//
//  PointMapViewController.m
//  iTravelPoint-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __TestMapViewController__IMPL__
#import <MapKit/MapKit.h>
#import "TestMapViewController.h"


@interface TPointPath : NSObject

@property (assign,nonatomic) NSInteger x;
@property (assign,nonatomic) NSInteger y;
@end

@implementation TPointPath



@end

//*********************************************************************************************************************
@interface CustomOfflineTileOverlayRenderer : MKTileOverlayRenderer
//@interface CustomOfflineTileOverlayRenderer : MKOverlayRenderer

@end

@implementation CustomOfflineTileOverlayRenderer

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)canDrawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale {

    //NSLog(@"canDrawMapRect  %f,%f - %f,%f - %f - %f,%f",mapRect.origin.x,mapRect.origin.y,mapRect.size.width,mapRect.size.height, 1/zoomScale, mapRect.size.width*zoomScale, mapRect.size.height*zoomScale);
    return [super canDrawMapRect:mapRect zoomScale:zoomScale];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
    
    //NSLog(@"drawMapRect     %0.2f, %0.2f - %0.2f, %0.2f - %0.2f - %0.2f, %0.2f",mapRect.origin.x,mapRect.origin.y,mapRect.size.width,mapRect.size.height, 1/zoomScale, mapRect.size.width*zoomScale, mapRect.size.height*zoomScale);
    [super drawMapRect:mapRect zoomScale:zoomScale inContext:context];
}

@end

//*********************************************************************************************************************
@interface CustomOfflineTileOverlay : MKTileOverlay

@property (strong,nonatomic) NSMutableArray *pointPaths;

@end

@implementation CustomOfflineTileOverlay

//---------------------------------------------------------------------------------------------------------------------
- (NSURL *)URLForTilePath:(MKTileOverlayPath)path {
    
    NSURL *url = [super URLForTilePath:path];
    
    // http://mt0.google.com/vt/x=7&y=7&z=3
    
    //NSLog(@"-------------------------------------------------------------------------------------------------");
    //    NSLog(@"x = %d",path.x);
    //    NSLog(@"y = %d",path.y);
    //    NSLog(@"z = %d",path.z);
    //    NSLog(@"contentScaleFactor = %f",path.contentScaleFactor);
    //    NSLog(@"url = %@",url);
    //    NSLog(@"-------------------------------------------------------------------------------------------------");
    
    return url;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) isNearAnnotation:(MKTileOverlayPath)path {

    for(TPointPath *point in self.pointPaths) {
        if(abs(path.x-point.x)<3 && abs(path.y-point.y)<3) {
            return TRUE;
        }
    }
    return FALSE;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)loadTileAtPath2X:(MKTileOverlayPath)path result:(void (^)(NSData *tileData, NSError *error))result {
    
    double zoomScale = 2;

    MKTileOverlayPath scaledPath;
    scaledPath.contentScaleFactor = path.contentScaleFactor;
    scaledPath.z = path.z-1;
    double spX = path.x/zoomScale;
    double spY = path.y/zoomScale;
    scaledPath.x=floor(spX);
    scaledPath.y=floor(spY);
    double offsetX =   256 * zoomScale * (spX-scaledPath.x);
    double offsetY = 256 * zoomScale * (spY-scaledPath.y);
    
    NSURL *scaledUrl = [super URLForTilePath:scaledPath];
    NSData * scaledData = [[NSData alloc] initWithContentsOfURL:scaledUrl];
    if ( scaledData != nil ) {
        UIImage *scaledImg = [UIImage imageWithData: scaledData];
        UIGraphicsBeginImageContext(CGSizeMake(256, 256));
        CGRect rect = CGRectMake(-offsetX,-offsetY,zoomScale * 256,zoomScale * 256);
        [scaledImg drawInRect:rect];
        UIImage* tileImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *tileData = UIImagePNGRepresentation(tileImage);
        result(tileData, nil);
    }

}

//---------------------------------------------------------------------------------------------------------------------
- (void)loadTileAtPathSmall:(MKTileOverlayPath)path result:(void (^)(NSData *tileData, NSError *error))result {
    
    MKTileOverlayPath scaledPath;
    scaledPath.contentScaleFactor = path.contentScaleFactor;
    scaledPath.z = 16;

    double zoomScale = pow(2,16-path.z);
    
    UIGraphicsBeginImageContext(CGSizeMake(256, 256));

    for(int y=0;y<zoomScale;y++) {
        
        scaledPath.y=y+path.y*zoomScale;
        double offsetY = 256 * y / zoomScale;

        for(int x=0;x<zoomScale;x++) {

            scaledPath.x=x+path.x*zoomScale;
            double offsetX = 256 * x / zoomScale;

            if(![self isNearAnnotation:scaledPath]) continue;

            NSURL *scaledUrl = [super URLForTilePath:scaledPath];
            NSData * scaledData = [[NSData alloc] initWithContentsOfURL:scaledUrl];
            if (scaledData != nil) {
                UIImage *scaledImg = [UIImage imageWithData: scaledData];
                CGRect rect = CGRectMake(offsetX,offsetY,256/zoomScale,256/zoomScale);
                [scaledImg drawInRect:rect];
            }
        }
    }
    
    UIImage* tileImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *tileData = UIImagePNGRepresentation(tileImage);
    result(tileData, nil);
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData *tileData, NSError *error))result {
    
    if(path.z<=6) {
        [self loadTileAtPath2X:path result:result];
    } else if(path.z==17) {
        [self loadTileAtPath2X:path result:result];
    } else {
        [self loadTileAtPathSmall:path result:result];
    }
}

@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface TestMapViewController () <MKMapViewDelegate>


@property (weak, nonatomic) IBOutlet MKMapView          *mapView;

@property (assign, nonatomic) NSInteger mapZoom;
@property (weak, nonatomic) IBOutlet UILabel *zoomLabel;
@property (weak, nonatomic) IBOutlet UISlider *zoomSlider;
@property (strong, nonatomic) CustomOfflineTileOverlay *overlay;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation TestMapViewController





//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (IBAction)zoomChanged:(UISlider *)sender {
    
    self.mapZoom = floor(sender.value);

    self.zoomLabel.text = [NSString stringWithFormat:@"Zoom: %u", self.mapZoom];
    self.overlay.minimumZ = self.overlay.maximumZ = self.mapZoom;
    [self centerMap:self.mapView centre:self.mapView.centerCoordinate withZoom:self.mapZoom animated:FALSE];
}


//---------------------------------------------------------------------------------------------------------------------
- (void) downloadWorld {
    
    NSUInteger totalSize = 0;
    
    for(int zoom=6;zoom<11;zoom++) {
        
        NSUInteger tiles = pow(2, zoom);
        NSUInteger zoomTotalSize = 0;
        NSLog(@"** Downloading zoom %d",zoom);
        
        for(NSUInteger y=0;y<tiles;y++) {
            for(NSUInteger x=0;x<tiles;x++) {
                NSString *urlStr = [NSString stringWithFormat:@"http://otile3.mqcdn.com/tiles/1.0.0/osm/%d/%d/%d.jpg",zoom,x,y];
                //NSLog(@"Downloading %@",urlStr);
                NSData * imgData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:urlStr]];
                if (imgData!= nil) {
                    //NSLog(@"Done!");
                    zoomTotalSize+=imgData.length;
                    NSString *filePath = [NSString stringWithFormat:@"/Users/jzarzuela/Desktop/imgs/z%d/mapTile_%d_%d_%d.jpg",zoom,zoom,x,y];
                    [imgData writeToFile:filePath atomically:YES];
                } else {
                    NSLog(@"--- ERROR ---");
                }
            }
        }
        NSLog(@"    Zoom %d --> %d bytes",zoom, zoomTotalSize);
        totalSize += zoomTotalSize;
    }
    NSLog(@"Total size %d bytes",totalSize);

}
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        [self mercatorTest];
    }
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //OpenCycleMap:     http://b.tile.opencyclemap.org/cycle/8/76/94.png
    //MapQuest [19]:         http://otile3.mqcdn.com/tiles/1.0.0/osm/8/76/94.jpg
    //OpenStreetMap:    http://tile.openstreetmap.org/8/76/94.png
    //GMaps[22]:            http://mt0.google.com/vt/x=76&y=94&z=8
    
    
    // Place this into your -viewDidLoad method
    //OpenCycleMap:   NSString *template = @"http://b.tile.opencyclemap.org/cycle/{z}/{x}/{y}.png";          // (1)
    //MapQuest:
    NSString *template = @"http://otile3.mqcdn.com/tiles/1.0.0/osm/{z}/{x}/{y}.jpg";       // (1)
                                                                                           //OpenStreetMap:  NSString *template = @"http://tile.openstreetmap.org/{z}/{x}/{y}.png";                 // (1)
                                                                                           //GMaps:          NSString *template = @"http://mt0.google.com/vt/x={x}&y={y}&z={z}";                    // (1)
    
    // latDelta=97.292972, lngDelta=112.468432  |  latDelta=0.001038, lngDelta=0.000977
    // latDelta=112.030317, lngDelta=112.358547  | latDelta=0.001147, lngDelta=0.001080
    // latDelta=53.384587, lngDelta=180.000000
    
    self.mapZoom = 17;
    
    self.overlay = [[CustomOfflineTileOverlay alloc] initWithURLTemplate:template];          // (2)
    self.overlay.canReplaceMapContent = YES;                                                     // (3)
    self.overlay.minimumZ = 0;
    self.overlay.maximumZ = 21;
    self.overlay.minimumZ = self.overlay.maximumZ = self.mapZoom;
    [self.mapView addOverlay:self.overlay level:MKOverlayLevelAboveLabels];                // (4)
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    //[self downloadWorld];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewWillAppear:(BOOL)animated {
    
    
    [super viewWillAppear:animated];
    
    [self _setMapAnnotations];
    
    self.zoomSlider.value = self.mapZoom;
    self.zoomLabel.text = [NSString stringWithFormat:@"Zoom: %u", self.mapZoom];
    
    CLLocationCoordinate2D centre = [self _calcAllPointsCentre];
    
    centre = CLLocationCoordinate2DMake(40.42369,-3.600361); // Casa Madrid
    centre = CLLocationCoordinate2DMake(42.360093, -71.055831); // Boston
    centre = CLLocationCoordinate2DMake(42.298801, -70.952254); // Mapa 1

    centre = CLLocationCoordinate2DMake(42.36324150000002, -71.05624399999999); // Mapa 2
    
    [self centerMap:self.mapView centre:centre withZoom:self.mapZoom animated:FALSE];
    
    
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




//=====================================================================================================================
#pragma mark -
#pragma mark <IBAction> outlet methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark <MKMapViewDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    static NSString *myMapAnnotationID = @"myMapAnnotationID";
    
    
    // Solo gestionamos el tipo de anotaciones indicado
    if(![annotation isKindOfClass:[MKPointAnnotation class]]) {
        // Parece que es el UserLocation
        return nil;
    }
    
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:myMapAnnotationID];
    if(!view) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:myMapAnnotationID];
        view.draggable = NO;
        view.canShowCallout = NO;
    }
    
    view.annotation = annotation;
    view.enabled = YES;
    //view.centerOffset = CGPointMake(0, -point.icon.image.size.height/2);
    
    return view;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    /*
    MKCoordinateRegion region = self.mapView.region;
    CGRect bounds = self.mapView.bounds;
    MKMapRect vrect = self.mapView.visibleMapRect;
    
    NSLog(@"------------------");
    NSLog(@"bounds  => x=%f, y=%f, w=%f, h=%f",bounds.origin.x,bounds.origin.y,bounds.size.width,bounds.size.height);
    NSLog(@"region  => lat=%f, lng=%f, latDelta=%f, lngDelta=%f",region.center.latitude,region.center.longitude,region.span.latitudeDelta,region.span.longitudeDelta);
    NSLog(@"vrect   => x=%f, y=%f, w=%f, h=%f",vrect.origin.x,vrect.origin.y,vrect.size.width,vrect.size.height);
    NSLog(@"vrectCC => Cx=%f, Cy=%f",vrect.origin.x+vrect.size.width/2,vrect.origin.y+vrect.size.height/2);
    NSLog(@"------------------");
     */
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    NSLog(@"===================================================================================================");
    NSLog(@"- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error -> %@", error);
}

//---------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    NSLog(@"===================================================================================================");
    NSLog(@"- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error -> %@ ",error);
}







//---------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    //    NSLog(@"===================================================================================================");
    //    NSLog(@"- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated");
}


//---------------------------------------------------------------------------------------------------------------------
- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
    //    NSLog(@"===================================================================================================");
    //    NSLog(@"- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView");
}

//---------------------------------------------------------------------------------------------------------------------
- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    //    NSLog(@"===================================================================================================");
    //    NSLog(@"- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView");
}



//---------------------------------------------------------------------------------------------------------------------
// mapView:didAddAnnotationViews: is called after the annotation views have been added and positioned in the map.
// The delegate can implement this method to animate the adding of the annotations views.
// Use the current positions of the annotation views as the destinations of the animation.
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    //    NSLog(@"===================================================================================================");
    //    NSLog(@"- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views ");
}


//---------------------------------------------------------------------------------------------------------------------
// Overlays
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    //    NSLog(@"===================================================================================================");
    //    NSLog(@"- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay ");
    return nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews {
    //    NSLog(@"===================================================================================================");
    //    NSLog(@"- (void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews ");
}


//---------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    //    NSLog(@"===================================================================================================");
    //    NSLog(@"- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation ");
}

//---------------------------------------------------------------------------------------------------------------------
- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView {
    //    NSLog(@"===================================================================================================");
    //    NSLog(@"- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView ");
}

//---------------------------------------------------------------------------------------------------------------------
- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView {
    //    NSLog(@"===================================================================================================");
    //    NSLog(@"- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView ");
}

//---------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    //    NSLog(@"===================================================================================================");
    //    NSLog(@"- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState ");
    
}

//---------------------------------------------------------------------------------------------------------------------
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    
    if ([overlay isKindOfClass:[CustomOfflineTileOverlay class]]) {
        MKTileOverlay *to = overlay;
        NSLog(@"-------------------------------------------------------------------------------------------------");
        NSLog(@"coordinate lat=%f, lng=%f",to.coordinate.latitude, to.coordinate.longitude);
        NSLog(@"boundingMapRect = %f,%f - %f,%f",to.boundingMapRect.origin.x,to.boundingMapRect.origin.y,to.boundingMapRect.size.width,to.boundingMapRect.size.height);
        NSLog(@"tileSize = %f,%f",to.tileSize.width,to.tileSize.height);
        NSLog(@"geometryFlipped = %d",to.geometryFlipped);
        NSLog(@"minimumZ = %d",to.minimumZ);
        NSLog(@"maximumZ = %d",to.maximumZ);
        NSLog(@"canReplaceMapContent = %d",to.canReplaceMapContent);
        NSLog(@"URLTemplate = %@",to.URLTemplate);
        NSLog(@"-------------------------------------------------------------------------------------------------");
        return [[CustomOfflineTileOverlayRenderer alloc] initWithOverlay:overlay];
    }
    return nil;
}


//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _setMapAnnotations {
    
    id userLocation = self.mapView.userLocation;
    
    // Avoid removing user location off the map
    if ( userLocation != nil ) {
        
        NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[self.mapView annotations]];
        [pins removeObject:userLocation];
        [self.mapView removeAnnotations:pins];
        
    } else {
        
        [self.mapView removeAnnotations:self.mapView.annotations];
    }
    
    // Add new annotations from points
    
     [self.mapView addAnnotation:[self pointWithLng:-69.950356 lat:41.671513]];
     [self.mapView addAnnotation:[self pointWithLng:-69.957260 lat:41.680035]];
     [self.mapView addAnnotation:[self pointWithLng:-70.101318 lat:41.282074]];
     [self.mapView addAnnotation:[self pointWithLng:-70.185417 lat:42.051407]];
     [self.mapView addAnnotation:[self pointWithLng:-70.188637 lat:42.052288]];
     [self.mapView addAnnotation:[self pointWithLng:-70.277054 lat:41.651031]];
     [self.mapView addAnnotation:[self pointWithLng:-70.477661 lat:43.361835]];
     [self.mapView addAnnotation:[self pointWithLng:-70.496544 lat:41.757843]];
     [self.mapView addAnnotation:[self pointWithLng:-70.560204 lat:41.455608]];
     [self.mapView addAnnotation:[self pointWithLng:-70.616920 lat:42.658627]];
     [self.mapView addAnnotation:[self pointWithLng:-70.626190 lat:41.937851]];
     [self.mapView addAnnotation:[self pointWithLng:-70.657707 lat:42.606136]];
     [self.mapView addAnnotation:[self pointWithLng:-70.662132 lat:41.958076]];
     [self.mapView addAnnotation:[self pointWithLng:-70.662209 lat:41.959778]];
     [self.mapView addAnnotation:[self pointWithLng:-70.665390 lat:41.959923]];
     [self.mapView addAnnotation:[self pointWithLng:-70.670273 lat:41.522282]];
     [self.mapView addAnnotation:[self pointWithLng:-70.850548 lat:42.502922]];
     [self.mapView addAnnotation:[self pointWithLng:-70.883453 lat:42.521915]];
     [self.mapView addAnnotation:[self pointWithLng:-70.888260 lat:42.519924]];
     [self.mapView addAnnotation:[self pointWithLng:-70.891655 lat:42.523113]];
     [self.mapView addAnnotation:[self pointWithLng:-70.891983 lat:42.522057]];
     [self.mapView addAnnotation:[self pointWithLng:-70.892609 lat:42.520699]];
     [self.mapView addAnnotation:[self pointWithLng:-70.895653 lat:42.521442]];
     [self.mapView addAnnotation:[self pointWithLng:-70.897202 lat:42.522469]];
     [self.mapView addAnnotation:[self pointWithLng:-70.898834 lat:42.521378]];
     [self.mapView addAnnotation:[self pointWithLng:-71.049530 lat:42.319176]];
     [self.mapView addAnnotation:[self pointWithLng:-71.051300 lat:42.357880]];
     [self.mapView addAnnotation:[self pointWithLng:-71.051628 lat:42.359581]];
     [self.mapView addAnnotation:[self pointWithLng:-71.053017 lat:42.365448]];
     [self.mapView addAnnotation:[self pointWithLng:-71.053200 lat:42.357300]];
     [self.mapView addAnnotation:[self pointWithLng:-71.053299 lat:42.332100]];
     [self.mapView addAnnotation:[self pointWithLng:-71.053467 lat:42.364029]];
     [self.mapView addAnnotation:[self pointWithLng:-71.053535 lat:42.364632]];
     [self.mapView addAnnotation:[self pointWithLng:-71.054642 lat:42.366402]];
     [self.mapView addAnnotation:[self pointWithLng:-71.055519 lat:42.366707]];
     [self.mapView addAnnotation:[self pointWithLng:-71.055832 lat:42.359951]];
     [self.mapView addAnnotation:[self pointWithLng:-71.055862 lat:42.360203]];
     [self.mapView addAnnotation:[self pointWithLng:-71.056549 lat:42.359776]];
     [self.mapView addAnnotation:[self pointWithLng:-71.056969 lat:42.361221]];
     [self.mapView addAnnotation:[self pointWithLng:-71.057213 lat:42.358620]];
     [self.mapView addAnnotation:[self pointWithLng:-71.057327 lat:42.358383]];
     [self.mapView addAnnotation:[self pointWithLng:-71.057426 lat:42.356274]];
     [self.mapView addAnnotation:[self pointWithLng:-71.057678 lat:42.358685]];
     [self.mapView addAnnotation:[self pointWithLng:-71.058151 lat:42.372669]];
     [self.mapView addAnnotation:[self pointWithLng:-71.058472 lat:42.357407]];
     [self.mapView addAnnotation:[self pointWithLng:-71.058830 lat:42.356899]];
     [self.mapView addAnnotation:[self pointWithLng:-71.059280 lat:42.356525]];
     [self.mapView addAnnotation:[self pointWithLng:-71.059494 lat:42.357742]];
     [self.mapView addAnnotation:[self pointWithLng:-71.059868 lat:42.351265]];
     [self.mapView addAnnotation:[self pointWithLng:-71.060158 lat:42.354816]];
     [self.mapView addAnnotation:[self pointWithLng:-71.060417 lat:42.358040]];
     [self.mapView addAnnotation:[self pointWithLng:-71.061012 lat:42.375980]];
     [self.mapView addAnnotation:[self pointWithLng:-71.061577 lat:42.356892]];
     [self.mapView addAnnotation:[self pointWithLng:-71.061996 lat:42.356529]];
     [self.mapView addAnnotation:[self pointWithLng:-71.062798 lat:42.371532]];
     [self.mapView addAnnotation:[self pointWithLng:-71.063171 lat:42.357746]];
     [self.mapView addAnnotation:[self pointWithLng:-71.067749 lat:42.350948]];
     [self.mapView addAnnotation:[self pointWithLng:-71.068260 lat:42.351185]];
     [self.mapView addAnnotation:[self pointWithLng:-71.068466 lat:42.354488]];
     [self.mapView addAnnotation:[self pointWithLng:-71.068810 lat:42.358360]];
     [self.mapView addAnnotation:[self pointWithLng:-71.069290 lat:42.357517]];
     [self.mapView addAnnotation:[self pointWithLng:-71.071121 lat:42.355968]];
     [self.mapView addAnnotation:[self pointWithLng:-71.072121 lat:42.349369]];
     [self.mapView addAnnotation:[self pointWithLng:-71.075249 lat:42.350132]];
     [self.mapView addAnnotation:[self pointWithLng:-71.075706 lat:42.361507]];
     [self.mapView addAnnotation:[self pointWithLng:-71.078583 lat:42.347786]];
     [self.mapView addAnnotation:[self pointWithLng:-71.082405 lat:42.348904]];
     [self.mapView addAnnotation:[self pointWithLng:-71.082466 lat:42.348530]];
     [self.mapView addAnnotation:[self pointWithLng:-71.082588 lat:42.348476]];
     [self.mapView addAnnotation:[self pointWithLng:-71.083649 lat:42.349300]];
     [self.mapView addAnnotation:[self pointWithLng:-71.087601 lat:42.348221]];
     [self.mapView addAnnotation:[self pointWithLng:-71.095329 lat:42.348789]];
     [self.mapView addAnnotation:[self pointWithLng:-71.095833 lat:42.359932]];
     [self.mapView addAnnotation:[self pointWithLng:-71.100723 lat:42.350349]];
     [self.mapView addAnnotation:[self pointWithLng:-71.115746 lat:42.376156]];
     [self.mapView addAnnotation:[self pointWithLng:-71.117195 lat:42.374500]];
     [self.mapView addAnnotation:[self pointWithLng:-71.118790 lat:42.373360]];
     [self.mapView addAnnotation:[self pointWithLng:-71.137199 lat:42.339027]];
     [self.mapView addAnnotation:[self pointWithLng:-71.191406 lat:42.666283]];
     [self.mapView addAnnotation:[self pointWithLng:-71.229942 lat:42.448765]];
     [self.mapView addAnnotation:[self pointWithLng:-71.312553 lat:41.489952]];
     [self.mapView addAnnotation:[self pointWithLng:-71.332962 lat:42.458839]];
     [self.mapView addAnnotation:[self pointWithLng:-71.346886 lat:42.461842]];
     [self.mapView addAnnotation:[self pointWithLng:-71.349022 lat:42.461010]];
     [self.mapView addAnnotation:[self pointWithLng:-71.350510 lat:42.036568]];
     [self.mapView addAnnotation:[self pointWithLng:-71.351021 lat:42.459789]];

    
    self.overlay.pointPaths = [NSMutableArray array];
    for(id<MKAnnotation> ann1 in self.mapView.annotations) {
        MKMapPoint p1 = MKMapPointForCoordinate(ann1.coordinate);
        TPointPath *path = [[TPointPath alloc] init];
        path.x  = p1.x / 4096;
        path.y  = p1.y / 4096;
        [self.overlay.pointPaths addObject:path];
    }
    
    NSLog(@"---");
    
}

//---------------------------------------------------------------------------------------------------------------------
- (MKPointAnnotation *) pointWithLng:(CLLocationDegrees)lng lat:(CLLocationDegrees)lat {
    return [self pointWithLat:lat lng:lng title:@""];
}

//---------------------------------------------------------------------------------------------------------------------
- (MKPointAnnotation *) pointWithLat:(CLLocationDegrees)lat lng:(CLLocationDegrees)lng title:(NSString *)title {
    
    MKPointAnnotation *p = [[MKPointAnnotation alloc] init];
    p.coordinate = CLLocationCoordinate2DMake(lat, lng);
    p.title = title;
    return p;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _centerMapToShowAllPoints {
    
    
    CLLocationDegrees regMinLat=1000, regMaxLat=-1000, regMinLng=1000, regMaxLng=-1000;
    CLLocationCoordinate2D regCenter = CLLocationCoordinate2DMake(0, 0);
    MKCoordinateSpan regSpan = MKCoordinateSpanMake(0, 0);
    
    if(self.mapView.annotations.count==0) {
        
        MKUserLocation *uloc=self.mapView.userLocation;
        regCenter.latitude = uloc.coordinate.latitude;
        regCenter.longitude = uloc.coordinate.longitude;
        regSpan.latitudeDelta = 0.05;
        regSpan.longitudeDelta = 0.05;
        
    } else if(self.mapView.annotations.count==1) {
        
        id<MKAnnotation> pin = self.mapView.annotations[0];
        regCenter.latitude = pin.coordinate.latitude;
        regCenter.longitude = pin.coordinate.longitude;
        regSpan.latitudeDelta = 0.05;
        regSpan.longitudeDelta = 0.05;
        
    } else {
        
        // Calcula los extremos
        for(id<MKAnnotation> pin in self.mapView.annotations) {
            
            // Se salta la posicion del usuario y se centra en los puntos
            if([pin isKindOfClass:MKUserLocation.class]) continue;
            
            regMinLat = MIN(regMinLat, pin.coordinate.latitude);
            regMaxLat = MAX(regMaxLat, pin.coordinate.latitude);
            regMinLng = MIN(regMinLng, pin.coordinate.longitude);
            regMaxLng = MAX(regMaxLng, pin.coordinate.longitude);
        }
        
        // Establece el centro
        regCenter.latitude = regMinLat+(regMaxLat-regMinLat)/2;
        regCenter.longitude = regMinLng+(regMaxLng-regMinLng)/2;
        
        // Establece el span
        regSpan.latitudeDelta = regMaxLat-regMinLat;
        regSpan.longitudeDelta = regMaxLng-regMinLng;
        
        // Deja espacio para que se vean los iconos
        double degreesByPoint1 = regSpan.longitudeDelta / self.mapView.frame.size.height;
        double iconSizeInDegrees1 = 64.0 * degreesByPoint1;
        regSpan.longitudeDelta  += iconSizeInDegrees1;
        
        double degreesByPoint2 = regSpan.latitudeDelta / self.mapView.frame.size.width;
        double iconSizeInDegrees2 = 64.0 * degreesByPoint2;
        regSpan.latitudeDelta  += iconSizeInDegrees2;
        
        // Ajusta por si nos hemos pasado
        regSpan.latitudeDelta = MIN(89, regSpan.latitudeDelta);
        regSpan.longitudeDelta = MIN(179, regSpan.longitudeDelta);
    }

    // Ajusta la vista del mapa a la region, centrandolo
    MKCoordinateRegion region1 = MKCoordinateRegionMake(regCenter, regSpan);
    NSLog(@"region1 lat=%f, lng=%f - spanLat=%f, spanLng=%f",region1.center.latitude, region1.center.longitude,region1.span.latitudeDelta,region1.span.longitudeDelta);
    MKCoordinateRegion region2 =[self.mapView regionThatFits:region1];
    NSLog(@"region2 lat=%f, lng=%f - spanLat=%f, spanLng=%f",region2.center.latitude, region2.center.longitude,region2.span.latitudeDelta,region2.span.longitudeDelta);
    //self.mapView.centerCoordinate = region2.center;
    [self.mapView setRegion:region1 animated:FALSE]; //TRUE

    [self.mapView setRegion:MKCoordinateRegionMake(regCenter, MKCoordinateSpanMake(12, 12)) animated:FALSE]; //TRUE

    //    [self.mapView setVisibleMapRect:MKMapRectMake(100139008.497242, 108003327.420955, 68157439.005516, 52428801.158090) animated:FALSE];
    //[self.mapView setVisibleMapRect:MKMapRectMake(67108864, 100663296, 134217728, 67108864) animated:FALSE];

    // Zoom = 4????
    [self.mapView setVisibleMapRect:MKMapRectMake(117178368, 121110528, 34078720, 26214400) animated:FALSE];
    
    
    region2 = self.mapView.region;
    NSLog(@"region2 lat=%f, lng=%f - spanLat=%f, spanLng=%f",region2.center.latitude, region2.center.longitude,region2.span.latitudeDelta,region2.span.longitudeDelta);

    
    
    CGSize size = self.mapView.bounds.size;
    CLLocationCoordinate2D coord;
    
    coord = [self.mapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:self.mapView];
    NSLog(@"TL lat=%f, lng=%f",coord.latitude, coord.longitude);
    coord = [self.mapView convertPoint:CGPointMake(size.width,0) toCoordinateFromView:self.mapView];
    NSLog(@"TR lat=%f, lng=%f",coord.latitude, coord.longitude);
    coord = [self.mapView convertPoint:CGPointMake(0, size.height) toCoordinateFromView:self.mapView];
    NSLog(@"BL lat=%f, lng=%f",coord.latitude, coord.longitude);
    coord = [self.mapView convertPoint:CGPointMake(size.width, size.height) toCoordinateFromView:self.mapView];
    NSLog(@"BR lat=%f, lng=%f",coord.latitude, coord.longitude);
    coord = [self.mapView convertPoint:CGPointMake(size.width/2, size.height/2) toCoordinateFromView:self.mapView];
    NSLog(@"CC lat=%f, lng=%f",coord.latitude, coord.longitude);

    coord = [self.mapView convertPoint:CGPointMake(size.width,0) toCoordinateFromView:self.mapView];
    NSLog(@"SPAN lat=%f, lng=%f",coord.latitude*2, coord.longitude*2);
    NSLog(@"");
}


//---------------------------------------------------------------------------------------------------------------------
- (CLLocationCoordinate2D) _calcAllPointsCentre {
    
    
    CLLocationDegrees regMinLat=1000, regMaxLat=-1000, regMinLng=1000, regMaxLng=-1000;
    CLLocationCoordinate2D regCenter = CLLocationCoordinate2DMake(0, 0);
    
    if(self.mapView.annotations.count==0) {
        
        MKUserLocation *uloc=self.mapView.userLocation;
        regCenter.latitude = uloc.coordinate.latitude;
        regCenter.longitude = uloc.coordinate.longitude;
        
    } else if(self.mapView.annotations.count==1) {
        
        id<MKAnnotation> pin = self.mapView.annotations[0];
        regCenter.latitude = pin.coordinate.latitude;
        regCenter.longitude = pin.coordinate.longitude;
        
    } else {
        
        // Calcula los extremos
        for(id<MKAnnotation> pin in self.mapView.annotations) {
            
            // Se salta la posicion del usuario y se centra en los puntos
            if([pin isKindOfClass:MKUserLocation.class]) continue;
            
            regMinLat = MIN(regMinLat, pin.coordinate.latitude);
            regMaxLat = MAX(regMaxLat, pin.coordinate.latitude);
            regMinLng = MIN(regMinLng, pin.coordinate.longitude);
            regMaxLng = MAX(regMaxLng, pin.coordinate.longitude);
        }
        
        // Establece el centro
        regCenter.latitude = regMinLat+(regMaxLat-regMinLat)/2;
        regCenter.longitude = regMinLng+(regMaxLng-regMinLng)/2;
    }

    return regCenter;
}


//---------------------------------------------------------------------------------------------------------------------
- (void) centerMap:(MKMapView *)map centre:(CLLocationCoordinate2D)centreCoord withZoom:(int)zoom animated:(BOOL)animated {
    
    MKMapPoint centrePoint = MKMapPointForCoordinate(centreCoord);
    
    CGFloat rectWidth = 2 * map.bounds.size.width * pow(2, 20-zoom);
    CGFloat rectHeight = 2 * map.bounds.size.height * pow(2, 20-zoom);
    
    MKMapRect visibleRect = MKMapRectMake(centrePoint.x-rectWidth/2, centrePoint.y-rectHeight/2, rectWidth, rectHeight);
    NSLog(@"zoom = %d, visibleRect = %0.2f, %0.2f - %0.2f, %0.2f", zoom, visibleRect.origin.x, visibleRect.origin.y, visibleRect.size.width, visibleRect.size.height);
    
    [map setVisibleMapRect:visibleRect animated:animated];

    
    CLLocationCoordinate2D coord;
    MKMapPoint point;
    
    coord = [self.mapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:self.mapView];
    point = MKMapPointForCoordinate(coord);
    NSLog(@"%0.2f, %0.2f", point.x,point.y);

    coord = [self.mapView convertPoint:CGPointMake(self.mapView.bounds.size.width, self.mapView.bounds.size.height) toCoordinateFromView:self.mapView];
    point = MKMapPointForCoordinate(coord);
    NSLog(@"%0.2f, %0.2f", point.x,point.y);

}

//---------------------------------------------------------------------------------------------------------------------
// Specifically, most spherical mercator maps use an extent of the world from -180 to 180 longitude, and
// from -85.0511 to 85.0511 latitude. Because the mercator projection stretches to infinity as you approach the poles,
// a cutoff in the north-south direction is required, and this particular cutoff results in a perfect square of projected meters.


// Se usa un ZOOM de 20 para MAPA completo con un numero de puntos = 256*2^20 = 268.435.456 (134.217.728 centro)
//#define MERCATOR_RADIUS 20037508.34
#define MERCATOR_RADIUS 134217728

- (void) mercatorTest {
    
    MKMapPoint point;
    CLLocationCoordinate2D coord;

    NSLog(@"---------------------------------------------------");

    NSLog(@"MKMapRectWorld = %f,%f - %f,%f",MKMapRectWorld.origin.x,MKMapRectWorld.origin.y,MKMapRectWorld.size.width,MKMapRectWorld.size.height);
    
    
    coord = CLLocationCoordinate2DMake(85, -180);
    point = [self toMercatorCoord:coord];
    NSLog(@"lat=%f, lng=%f --> x=%f, y=%f",coord.latitude, coord.longitude, point.x, point.y);
    
    
    coord = CLLocationCoordinate2DMake(-85, 180);
    point = [self toMercatorCoord:coord];
    NSLog(@"lat=%f, lng=%f --> x=%f, y=%f",coord.latitude, coord.longitude, point.x, point.y);

    coord = CLLocationCoordinate2DMake(0, 0);
    point = [self toMercatorCoord:coord];
    NSLog(@"lat=%f, lng=%f --> x=%f, y=%f",coord.latitude, coord.longitude, point.x, point.y);

    

    point = MKMapPointMake(100139008, 108003327);
    coord = [self fromMercatorPoint:point];
    NSLog(@"lat=%f, lng=%f --> x=%f, y=%f",coord.latitude, coord.longitude, point.x, point.y);

    point = MKMapPointMake(100139008+68157439, 108003327+52428801);
    coord = [self fromMercatorPoint:point];
    NSLog(@"lat=%f, lng=%f --> x=%f, y=%f",coord.latitude, coord.longitude, point.x, point.y);

    point = MKMapPointMake(134217728, 134217728);
    coord = [self fromMercatorPoint:point];
    NSLog(@"lat=%f, lng=%f --> x=%f, y=%f",coord.latitude, coord.longitude, point.x, point.y);

    NSLog(@"---------------------------------------------------");
    
}

- (MKMapPoint) toMercatorCoord:(CLLocationCoordinate2D) coord {

    MKMapPoint point;
    
    point.x = coord.longitude * MERCATOR_RADIUS / 180;
    point.y = log(tan((90 + coord.latitude) * M_PI / 360)) / (M_PI / 180);
    point.y = point.y * MERCATOR_RADIUS / 180;

    // [0..Max]
    point.x = point.x + MERCATOR_RADIUS;
    point.y = -(point.y - MERCATOR_RADIUS);

    return point;
}

- (CLLocationCoordinate2D) fromMercatorPoint:(MKMapPoint)point {
   
    CLLocationCoordinate2D coord;

    // [-Max/2..Max/2]
    point.x = point.x - MERCATOR_RADIUS;
    point.y = -point.y + MERCATOR_RADIUS;

    coord.longitude = (point.x / MERCATOR_RADIUS) * 180;
    coord.latitude = (point.y / MERCATOR_RADIUS) * 180;
    coord.latitude = 180/M_PI * (2 * atan(exp(coord.latitude * M_PI / 180)) - M_PI_2);
    return coord;
}



@end
