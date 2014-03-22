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
#import "MKMapView+ZoomLevel.h"


#import "MMap.h"
#import "BaseCoreDataService.h"


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
- (id) pointListWillChange {

    // No hace nada
    return nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) pointListDidChange:(id)prevInfo {

    // Remenber previous selected point
    MPoint *selPoint = self.dataSource.selectedPoint;

    // Sets new points
    [self _setPointsAsAnnotationsInMap: self.dataSource.pointList];
    
    // Restores previous selected point
    [self.pointsMapView selectAnnotation:selPoint animated:FALSE];
    
    // Centers map
    [self _centerAndZoomMap];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) startMultiplePointSelection {
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) doneMultiplePointSelection {
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) refreshSelectedPoint {
    
    [self _centerAndZoomMap];
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
    
    if(self.pointsMapView.annotations.count==0 || (self.pointsMapView.annotations.count==1 && [self.pointsMapView.annotations[0] isKindOfClass:MKUserLocation.class])) {
        
        // Sets points
        [self _setPointsAsAnnotationsInMap: self.dataSource.pointList];

        // Center and Zoom map adecuately
        [self _centerAndZoomMap];
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
            
            if([self.dataSource.checkedPoints containsObject:point]) {
                [self.dataSource.checkedPoints removeObject:point];
                view.image = point.icon.image;
            } else {
                [self.dataSource.checkedPoints addObject:point];
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

    view.canShowCallout = TRUE;
    view.annotation = annotation;
    if([self.dataSource.checkedPoints containsObject:point]) {
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
- (IBAction)kkButton:(UIButton *)sender {
    [self.pointsMapView centerAndZoomToShowAnnotations:32 animated:FALSE];
    [self mapView:self.pointsMapView regionDidChangeAnimated:TRUE];
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
    
    MPoint *point = (MPoint *)view.annotation;
    self.dataSource.selectedPoint=point;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
    self.dataSource.selectedPoint=nil;
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
- (void) _setPointsAsAnnotationsInMap:(NSArray *) pointList {
    
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
    [self.pointsMapView addAnnotations:pointList];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _centerAndZoomMap {
    
    if(!self.dataSource.selectedPoint) {
        
        // Centers map showing ALL the points
        [self.pointsMapView centerAndZoomToShowAnnotations:32 animated:FALSE];
        
        // Deselect all points
        [self.pointsMapView selectAnnotation:nil animated:FALSE];
        
    } else {
        
        // Centers map showing THAT selected point
        [self.pointsMapView setCenterCoordinate:self.dataSource.selectedPoint.coordinate zoomLevel:17 animated:FALSE];

        // Selects the point
        if([self.pointsMapView.annotations containsObject:self.dataSource.selectedPoint]) {
            [self.pointsMapView selectAnnotation:self.dataSource.selectedPoint animated:FALSE];
        }
        
    }
}

@end
