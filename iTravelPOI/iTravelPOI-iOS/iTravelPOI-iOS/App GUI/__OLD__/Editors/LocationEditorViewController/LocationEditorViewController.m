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
#define MIN_PRECISION_TO_STOP_GPS -1




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface LocationEditorViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;


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
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // Establece el color dependiendo del tinte
    //self.flblLocationLabel.textColor = self.view.tintColor;
    
    // Añade el punto
    [self.mapView addAnnotation:self.point];
    
    // Ajusta la vista del mapa a la region, centrandolo
    CLLocationCoordinate2D  center  = CLLocationCoordinate2DMake(self.point.latitudeValue, self.point.longitudeValue);
    MKCoordinateSpan        span    = MKCoordinateSpanMake(0.001, 0.001);
    MKCoordinateRegion      region  = MKCoordinateRegionMake(center, span);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:FALSE];
    self.mapView.centerCoordinate = self.point.coordinate;

}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
    
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

    [self.mapView setCenterCoordinate:self.point.coordinate animated:TRUE];
}




//=====================================================================================================================
#pragma mark -
#pragma mark <MKMapViewDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    static NSString *myMapAnnotationID = @"myMapAnnotationID";
    
    
    // Solo gestionamos el tipo de anotaciones indicado
    if(![annotation isKindOfClass:[MPoint class]]) {
        // Parece que es el UserLocation
        return nil;
    }
    
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:myMapAnnotationID];
    if(!view) {
        view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:myMapAnnotationID];
        view.draggable = NO;
        view.canShowCallout = NO;
    }
    
    MPoint *point = (MPoint *)annotation;
    view.annotation = annotation;
    view.image = point.icon.image;
    view.centerOffset = CGPointMake(0, -point.icon.image.size.height/2);
    
    return view;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    /*************
     // Si estaba cambiando de region porque estaba centrando un punto en edicion lo muestra
     if(self.anitateEdit) {
     [self _startAnimateAnnotationEdit];
     }
     **************/
}

//---------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    /*************
     // Habilita los botones de edicion
     if([view.annotation isKindOfClass:[MPointMapAnnotation class]] && [(MPointMapAnnotation *)view.annotation point]!=nil) {
     [self.scrollableToolbar enableItemWithTagID:BTN_ID_OPEN_IN enabled:YES];
     [self.scrollableToolbar enableItemWithTagID:BTN_ID_EDIT_LOC enabled:YES];
     [self.scrollableToolbar enableItemWithTagID:BTN_ID_EDIT_ALL enabled:YES];
     }
     **************/
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
    /*************
     // Inhabilita los botones de edicion
     if([view.annotation isKindOfClass:[MPointMapAnnotation class]] && [(MPointMapAnnotation *)view.annotation point]!=nil) {
     [self.scrollableToolbar enableItemWithTagID:BTN_ID_OPEN_IN enabled:NO];
     [self.scrollableToolbar enableItemWithTagID:BTN_ID_EDIT_LOC enabled:NO];
     [self.scrollableToolbar enableItemWithTagID:BTN_ID_EDIT_ALL enabled:NO];
     }
     **************/
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
- (void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews {
    //    NSLog(@"===================================================================================================");
    //    NSLog(@"- (void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews ");
}


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    //    NSLog(@"===================================================================================================");
    //    NSLog(@"- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation ");
}
- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView {
    //    NSLog(@"===================================================================================================");
    //    NSLog(@"- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView ");
}
- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView {
    //    NSLog(@"===================================================================================================");
    //    NSLog(@"- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView ");
}
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    //    NSLog(@"===================================================================================================");
    //    NSLog(@"- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState ");
    
}




//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) _dismissEditor {
    
    [self dismissViewControllerAnimated:YES completion:^{
        self.point = nil;
    }];
}



@end
