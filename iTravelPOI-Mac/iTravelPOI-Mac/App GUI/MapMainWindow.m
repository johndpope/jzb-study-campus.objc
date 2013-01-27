//
//  MapMainWindow.m
//  iTravelPOI-Mac
//
//  Created by Jose Zarzuela on 26/01/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __MapMainWindow__IMPL__
#import "MapMainWindow.h"
#import "DDLog.h"

#import "MKMapView.h"
#import "MKPointAnnotation.h"
#import "MKCircle.h"
#import "MKPinAnnotationView.h"

#import "GMapIcon.h"
#import "GMTPoint.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface MapMainWindow() <MKMapViewDelegate>

@property (nonatomic, assign) IBOutlet MKMapView *mapView;

@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation MapMainWindow




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (MapMainWindow *) mapMainWindow {
    
    MapMainWindow *me = [[MapMainWindow alloc] initWithWindowNibName:@"MapMainWindow"];
    if(me) {
        [me.window makeKeyAndOrderFront:me];
        return me;
    } else {
        return nil;
    }
    
}



// =====================================================================================================================
#pragma mark -
#pragma mark Initialization & finalization
// ---------------------------------------------------------------------------------------------------------------------
- (void) windowDidLoad {
    
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

// ------------------------------------------------------------------------------------------------------------------
- (void) awakeFromNib {
    self.mapView.delegate = self;
}




//=====================================================================================================================
#pragma mark -
#pragma mark Getter & Setter methods
//---------------------------------------------------------------------------------------------------------------------




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------


// =====================================================================================================================
#pragma mark -
#pragma mark <IBAction> methods
// ---------------------------------------------------------------------------------------------------------------------
- (IBAction)doIt:(NSButton *)sender {
    
    MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
    pin.coordinate = [self.mapView centerCoordinate];
    pin.title = @"pinTitle";
    pin.subtitle = @"pepe";
    
    NSMutableArray *pins = [NSMutableArray array];
    for(NSUInteger count=0;count<80;count++) {
        MKPointAnnotation *nPin = [self createNewPin:count total:80];
        [pins addObject:nPin];
    }
    [self.mapView addAnnotation:pin];
    [self.mapView addAnnotations:pins];
}


// ---------------------------------------------------------------------------------------------------------------------
- (MKPointAnnotation *) createNewPin:(NSUInteger)index total:(NSUInteger) total {
    
    CLLocationCoordinate2D centerCoordinate = [self.mapView centerCoordinate];
    double maxLatOffset = 0.01;
    double maxLngOffset = 0.02;
    NSString *name = [NSString stringWithFormat:@"pin-%ld", index];
    
    MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
    CLLocationCoordinate2D pinCoord = centerCoordinate;
    double latOffset = maxLatOffset * cosf(2*M_PI * ((double)index/(double)total));
    double lngOffset = maxLngOffset * sinf(2*M_PI * ((double)index/(double)total));
    pinCoord.latitude += latOffset;
    pinCoord.longitude += lngOffset;
    pin.coordinate = pinCoord;
    pin.title = name;
    return pin;
}




// ---------------------------------------------------------------------------------------------------------------------
- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    //NSLog(@"mapView: %@ viewForAnnotation: %@", aMapView, annotation);
    

    
    MKAnnotationView *view1 = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"blah"];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MarkerTest" ofType:@"png"];
    path = [[NSBundle mainBundle] pathForResource:@"GMapIcons.bundle/GMI_blue-dot" ofType:@"png"];
    NSURL *url = [NSURL fileURLWithPath:path];
    view1.imageUrl = [url absoluteString];
    
    
    MKPinAnnotationView *view2 = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"blah"];

    MKAnnotationView *view = view2;
    view.draggable = YES;
    view.canShowCallout = YES;
    
    return view;
}



// =====================================================================================================================
#pragma mark -
#pragma mark <NSToolbarItemValidation> methods
// ---------------------------------------------------------------------------------------------------------------------




// =====================================================================================================================
#pragma mark -
#pragma mark Private methods
// ---------------------------------------------------------------------------------------------------------------------




@end

