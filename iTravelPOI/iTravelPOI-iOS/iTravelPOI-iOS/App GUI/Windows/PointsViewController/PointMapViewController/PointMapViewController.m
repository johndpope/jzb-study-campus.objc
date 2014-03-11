//
//  PointMapViewController.m
//  iTravelPoint-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __PointMapViewController__IMPL__
#import <MapKit/MapKit.h>
#import "PointMapViewController.h"
#import "MPoint.h"
#import "MIcon.h"
#import "UIImage+Tint.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define ACCESSORY_BTN_EDIT      10001
#define ACCESSORY_BTN_OPEN_IN   10002



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface PointMapViewController () <MKMapViewDelegate, UIGestureRecognizerDelegate>


@property (weak, nonatomic) IBOutlet MKMapView          *pointsMapView;


@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation PointMapViewController


@synthesize dataSource = _dataSource;



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) pointsHaveChanged {
    
    // Sets new points
    [self _setPointsAsAnnotationsInMap];
    
    // Centers map
    [self _centerMapToShowAllPoints];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) startMultiplePointSelection {
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) doneMultiplePointSelection {
    
}

- (IBAction)kkButton:(UIButton *)sender {
    
    // 134217728

    //CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(42.35788,-71.0513);
    //[self.pointsMapView setCenterCoordinate:coordinate zoomLevel:6 animated:FALSE];

    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(0,0); 
    MKCoordinateSpan span = MKCoordinateSpanMake(15,30); // latDelta, LngDelta

    MKCoordinateRegion region1 = MKCoordinateRegionMake(center, span);
    NSLog(@"lat=%f, lng=%f, latDelta=%f, lngDelta=%f",region1.center.latitude,region1.center.longitude,region1.span.latitudeDelta,region1.span.longitudeDelta);
    
    MKCoordinateRegion region2 = [self.pointsMapView regionThatFits:region1];
    NSLog(@"lat=%f, lng=%f, latDelta=%f, lngDelta=%f",region2.center.latitude,region2.center.longitude,region2.span.latitudeDelta,region2.span.longitudeDelta);
    
    self.pointsMapView.region = region2;
    
    MKMapRect vrect = self.pointsMapView.visibleMapRect;
    NSLog(@"vrect  => x=%f, y=%f, w=%f, h=%f",vrect.origin.x,vrect.origin.y,vrect.size.width,vrect.size.height);
    
    MKCoordinateRegion region = self.pointsMapView.region;
    NSLog(@"lat=%f, lng=%f, latDelta=%f, lngDelta=%f",region.center.latitude,region.center.longitude,region.span.latitudeDelta,region.span.longitudeDelta);
}


//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
    }
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(handleTap:)];
    tapGesture.delegate = self;
    
    [self.pointsMapView addGestureRecognizer:tapGesture];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if(self.pointsMapView.annotations.count==0) {
        // Sets points
        [self _setPointsAsAnnotationsInMap];
        // Centers map
        [self _centerMapToShowAllPoints];
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewWillAppear:(BOOL)animated {
    
    
    [super viewWillAppear:animated];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    return TRUE;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint touchPoint = [sender locationInView:self.pointsMapView];
        UIView *subview = [self.pointsMapView hitTest:touchPoint withEvent:nil];
        if([subview isKindOfClass:[MKAnnotationView class]]) {
            
            MKAnnotationView *view = (MKAnnotationView *)subview;
            MPoint *point = (MPoint *)view.annotation;
            
            if([self.dataSource.selectedPoints containsObject:point]) {
                [self.dataSource.selectedPoints removeObject:point];
                view.image = point.icon.image;
            } else {
                [self.dataSource.selectedPoints addObject:point];
                view.image = [point.icon.image burnTint:[UIColor redColor]];
            }
            
            [view setSelected:FALSE];
        }
    }
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
    if(![annotation isKindOfClass:[MPoint class]]) {
        // Parece que es el UserLocation
        return nil;
    }
    
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:myMapAnnotationID];
    if(!view) {
        view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:myMapAnnotationID];
        view.draggable = YES;
        view.canShowCallout = YES;
        
        UIImage *editImg = [UIImage imageNamed:@"tbar-edit"];
        UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [editBtn setImage:editImg  forState:UIControlStateNormal];
        editBtn.frame = CGRectMake(0, 0, editImg.size.width+10, editImg.size.height);
        editBtn.tag = ACCESSORY_BTN_EDIT;
        view.leftCalloutAccessoryView = editBtn;
        
        

        UIImage *openInImg = [UIImage imageNamed:@"tbar-share"];
        UIButton *openInBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [openInBtn setImage:openInImg  forState:UIControlStateNormal];
        openInBtn.frame = CGRectMake(0, 0, openInImg.size.width+10, openInImg.size.height);
        openInBtn.tag = ACCESSORY_BTN_OPEN_IN;
        view.rightCalloutAccessoryView = openInBtn;
        
    }

    MPoint *point = (MPoint *)annotation;

    view.canShowCallout = FALSE;
    view.annotation = annotation;
    if([self.dataSource.selectedPoints containsObject:point]) {
        view.image = [point.icon.image burnTint:[UIColor redColor]];
    } else {
        view.image = point.icon.image;
    }
    view.enabled = YES;
    view.centerOffset = CGPointMake(0, -point.icon.image.size.height/2);
    //view.enabled = !self.scrollableToolbar.isEditModeActive;
    
    return view;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    if(control.tag == ACCESSORY_BTN_EDIT) {
        [self.dataSource editPoint:(MPoint *)view.annotation];
    } else if(control.tag == ACCESSORY_BTN_OPEN_IN) {
        [self.dataSource openInExternalApp:(MPoint *)view.annotation];
    }    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {

    MKCoordinateRegion region = self.pointsMapView.region;
    CGRect bounds = self.pointsMapView.bounds;
    MKMapRect vrect = self.pointsMapView.visibleMapRect;

    NSLog(@"------------------");
    NSLog(@"bounds => x=%f, y=%f, w=%f, h=%f",bounds.origin.x,bounds.origin.y,bounds.size.width,bounds.size.height);
    NSLog(@"vrect  => x=%f, y=%f, w=%f, h=%f",vrect.origin.x,vrect.origin.y,vrect.size.width,vrect.size.height);
    NSLog(@"region => lat=%f, lng=%f, latDelta=%f, lngDelta=%f",region.center.latitude,region.center.longitude,region.span.latitudeDelta,region.span.longitudeDelta);
    NSLog(@"------------------");

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
//---------------------------------------------------------------------------------------------------------------------
- (void) _setPointsAsAnnotationsInMap {
    
    id userLocation = self.pointsMapView.userLocation;

    // Avoid removing user location off the map
    if ( userLocation != nil ) {
        
        NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[self.pointsMapView annotations]];
        [pins removeObject:userLocation];
        [self.pointsMapView removeAnnotations:pins];
        
    } else {
        
        [self.pointsMapView removeAnnotations:self.pointsMapView.annotations];
    }
    
    // Add new annotations from points
    [self.pointsMapView addAnnotations:self.dataSource.pointList];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _centerMapToShowAllPoints {
    
    
    CLLocationDegrees regMinLat=1000, regMaxLat=-1000, regMinLng=1000, regMaxLng=-1000;
    CLLocationCoordinate2D regCenter = CLLocationCoordinate2DMake(0, 0);
    MKCoordinateSpan regSpan = MKCoordinateSpanMake(0, 0);
    
    if(self.pointsMapView.annotations.count==0) {
        
        MKUserLocation *uloc=self.pointsMapView.userLocation;
        regCenter.latitude = uloc.coordinate.latitude;
        regCenter.longitude = uloc.coordinate.longitude;
        regSpan.latitudeDelta = 0.05;
        regSpan.longitudeDelta = 0.05;
        
    } else if(self.pointsMapView.annotations.count==1) {
        
        MKPointAnnotation *pin = self.pointsMapView.annotations[0];
        regCenter.latitude = pin.coordinate.latitude;
        regCenter.longitude = pin.coordinate.longitude;
        regSpan.latitudeDelta = 0.05;
        regSpan.longitudeDelta = 0.05;
        
    } else {
        
        // Calcula los extremos
        for(MKPointAnnotation *pin in self.pointsMapView.annotations) {
            
            // Se salta la posicion del usuario y se centra en los puntos
            if([pin isKindOfClass:MKUserLocation.class]) continue;
            
            regMinLat = regMinLat <= pin.coordinate.latitude  ? regMinLat : pin.coordinate.latitude;
            regMaxLat = regMaxLat >  pin.coordinate.latitude  ? regMaxLat : pin.coordinate.latitude;
            regMinLng = regMinLng <= pin.coordinate.longitude ? regMinLng : pin.coordinate.longitude;
            regMaxLng = regMaxLng >  pin.coordinate.longitude ? regMaxLng : pin.coordinate.longitude;
        }
        
        // Establece el centro
        regCenter.latitude = regMinLat+(regMaxLat-regMinLat)/2;
        regCenter.longitude = regMinLng+(regMaxLng-regMinLng)/2;
        
        // Establece el span
        regSpan.latitudeDelta = regMaxLat-regMinLat;
        regSpan.longitudeDelta = regMaxLng-regMinLng;
        
        // Deja espacio para que se vean los iconos
        double degreesByPoint1 = regSpan.longitudeDelta / self.pointsMapView.frame.size.height;
        double iconSizeInDegrees1 = 64.0 * degreesByPoint1;
        regSpan.longitudeDelta  += iconSizeInDegrees1;
        
        double degreesByPoint2 = regSpan.latitudeDelta / self.pointsMapView.frame.size.width;
        double iconSizeInDegrees2 = 64.0 * degreesByPoint2;
        regSpan.latitudeDelta  += iconSizeInDegrees2;
        
        // Ajusta por si nos hemos pasado
        regSpan.latitudeDelta = MIN(90, regSpan.latitudeDelta);
        regSpan.longitudeDelta = MIN(180, regSpan.longitudeDelta);
    }
    
    // Ajusta la vista del mapa a la region, centrandolo
    MKCoordinateRegion region1 = MKCoordinateRegionMake(regCenter, regSpan);
    MKCoordinateRegion region2 =[self.pointsMapView regionThatFits:region1];
    //self.pointsMapView.centerCoordinate = region2.center;
    [self.pointsMapView setRegion:region2 animated:TRUE];
    
}



@end
