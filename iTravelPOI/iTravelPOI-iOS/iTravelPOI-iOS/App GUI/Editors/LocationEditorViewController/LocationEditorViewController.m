//
//  LocationEditorViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __LocationEditorViewController__IMPL__
#import <MapKit/MapKit.h>
#import "LocationEditorViewController.h"
#import "MIcon.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define MIN_PRECISION_TO_STOP_GPS   +5
#define GPS_UNKNOWN                 -1.0
#define GPS_ERROR                   -2.0




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface LocationEditorViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView      *mapView;
@property (weak, nonatomic) IBOutlet UILabel        *gpsAccuracy;

@property (strong, nonatomic) CLLocationManager     *locationManager;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation LocationEditorViewController


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------






//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        // Inicializa
    }
    return self;
}



//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Inicializa la geolocalizacion
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation; // En metros
    self.locationManager.distanceFilter = MIN_PRECISION_TO_STOP_GPS; // En metros
    [self _showGPSAccuraryValue:GPS_UNKNOWN];

    
    // Añade el punto
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = self.coordinate;
    [self.mapView addAnnotation:annotation];
    
    // Ajusta la vista del mapa: Centrandolo en el punto y dando un radio de 1Km alrededor
    MKCoordinateRegion      region  = MKCoordinateRegionMakeWithDistance(self.coordinate, 500, 500);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:FALSE];
    self.mapView.centerCoordinate = self.coordinate;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.locationManager startUpdatingLocation];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
    [self.locationManager stopUpdatingLocation];
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//---------------------------------------------------------------------------------------------------------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    

}


//=====================================================================================================================
#pragma mark -
#pragma mark <IBAction> outlet methods
// ---------------------------------------------------------------------------------------------------------------------
- (IBAction)cancelAction:(UIBarButtonItem *)sender {
    
    if([self.delegate respondsToSelector:@selector(locationEditorCancel:)]) {
        [self.delegate locationEditorCancel:self];
    }
    [self _dismissEditor];
}

// ---------------------------------------------------------------------------------------------------------------------
- (IBAction)saveAction:(UIBarButtonItem *)sender {
    
    // Indica que hubo a su delegate antes de cerrar
    if([self.delegate respondsToSelector:@selector(locationEditorSave:coord:)]) {
        [self.delegate locationEditorSave:self coord:self.mapView.centerCoordinate];
    }
    [self _dismissEditor];
}

// ---------------------------------------------------------------------------------------------------------------------
- (IBAction)userLocationBtnAction:(UIBarButtonItem *)sender {
    
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:TRUE];
}

// ---------------------------------------------------------------------------------------------------------------------
- (IBAction)prevLocationBtnAction:(UIBarButtonItem *)sender {

    [self.mapView setCenterCoordinate:self.coordinate animated:TRUE];
}




// =====================================================================================================================
#pragma mark -
#pragma mark <CLLocationManagerDelegate> protocol methods
// ---------------------------------------------------------------------------------------------------------------------
// Our location updates are sent here
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    if(newLocation!=nil) {
        [self _showGPSAccuraryValue:newLocation.horizontalAccuracy];
    }
    
}

// ---------------------------------------------------------------------------------------------------------------------
// Any errors are sent here
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self _showGPSAccuraryValue:GPS_ERROR];
}


//=====================================================================================================================
#pragma mark -
#pragma mark <MKMapViewDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    static NSString *myMapAnnotationID = @"myMapAnnotationID";
    
    // Comprobamos que no sea el UserLocation
    if([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:myMapAnnotationID];
    if(!view) {
        view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:myMapAnnotationID];
        view.draggable = NO;
        view.canShowCallout = NO;
    }
    
    view.annotation = annotation;
    view.image = self.image;
    view.centerOffset = CGPointMake(0, -self.image.size.height/2);
    
    return view;
}



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) _dismissEditor {
    
    [self dismissViewControllerAnimated:YES completion:^{
        self.image = nil;
    }];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _showGPSAccuraryValue:(CLLocationAccuracy)accuracy {
    
    if(accuracy>=0) {
        self.gpsAccuracy.text = [NSString stringWithFormat:@"GPS accuracy: %0.0f m", accuracy];
    } else {
        if(accuracy == GPS_UNKNOWN)
            self.gpsAccuracy.text = @"GPS accuracy: UNKNOWN";
        else
            self.gpsAccuracy.text = @"GPS accuracy: ERROR";
    }
}





@end
