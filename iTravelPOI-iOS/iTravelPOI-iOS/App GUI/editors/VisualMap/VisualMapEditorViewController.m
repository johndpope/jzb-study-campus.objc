//
//  VisualMapEditorViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __VisualMapEditorViewController__IMPL__

#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>

#import "VisualMapEditorViewController.h"
#import "MyMKPointAnnotation.h"
#import "DPAnnotationView.h"
#import "ImageManager.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define LAT_SPAN_VERT 0.006469
#define LNG_SPAN_VERT 0.006824




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface VisualMapEditorViewController() <MKMapViewDelegate>


@property (nonatomic, assign) IBOutlet MKMapView *mapView;
@property (nonatomic, assign) IBOutlet UINavigationBar *navigationBar;


@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation VisualMapEditorViewController




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (VisualMapEditorViewController *) startEditingAnnotations:(NSArray *)annotations delegate:(UIViewController<VisualMapEditorDelegate> *)delegate {

    if(delegate!=nil) {
        VisualMapEditorViewController *me = [[VisualMapEditorViewController alloc] initWithNibName:@"VisualMapEditorViewController" bundle:nil];
        me.delegate = delegate;
        me.annotations = [NSMutableArray arrayWithArray:annotations];

        me.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [delegate presentViewController:me animated:YES completion:nil];
        return me;
    } else {
        DDLogVerbose(@"Warning: VisualMapEditorViewController-startEditingMap called with nil Delegate");
        return nil;
    }
}






//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Botones de Save & Cancel
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                         target:self
                                                                                         action:@selector(_btnCloseCancel:)];

    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                         target:self
                                                                                         action:@selector(_btnCloseSave:)];

    self.navigationBar.topItem.leftBarButtonItem = cancelBarButtonItem;
    self.navigationBar.topItem.rightBarButtonItem = saveBarButtonItem;
    
    // Actualiza los campos desde la entidad a editar
    [self _setFieldValuesFromEntity];
}


//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return TRUE;
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
#pragma mark <MKMapViewDelegate> methods
// ---------------------------------------------------------------------------------------------------------------------
// mapView:viewForAnnotation: provides the view for each annotation.
// This method may be called for all or some of the added annotations.
// For MapKit provided annotations (eg. MKUserLocation) return nil to use the MapKit provided annotation view.
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)t_annotation {

    NSLog(@"===================================================================================================");
    NSLog(@"- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)t_annotation");

    if([t_annotation isKindOfClass:[MyMKPointAnnotation class]]) {
        
        MyMKPointAnnotation *annotation = t_annotation;
        
        DPAnnotationView *view = (DPAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"MyMKPointAnnotation"];
        if(!view) {
            view = [[DPAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MyMKPointAnnotation"];
            view.draggable = YES;
            view.canShowCallout = YES;
            view.selected = TRUE;
        }
        
        IconData *icon = [ImageManager iconDataForHREF:annotation.iconHREF];
        view.image = icon.image;
        view.centerOffset = CGPointMake(0, -32/2);
        
        return view;
    } else {
        return nil;
    }
}




// ---------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    NSLog(@"===================================================================================================");
    NSLog(@"- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated");
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    NSLog(@"===================================================================================================");
    NSLog(@"- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated");
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
    NSLog(@"===================================================================================================");
    NSLog(@"- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView");
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    NSLog(@"===================================================================================================");
    NSLog(@"- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView");
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    NSLog(@"===================================================================================================");
    NSLog(@"- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error -> %@", error);
}


// ---------------------------------------------------------------------------------------------------------------------
// mapView:didAddAnnotationViews: is called after the annotation views have been added and positioned in the map.
// The delegate can implement this method to animate the adding of the annotations views.
// Use the current positions of the annotation views as the destinations of the animation.
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    NSLog(@"===================================================================================================");
    NSLog(@"- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views ");
}

// ---------------------------------------------------------------------------------------------------------------------
// mapView:annotationView:calloutAccessoryControlTapped: is called when the user taps on left & right callout accessory UIControls.
//- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;

// ---------------------------------------------------------------------------------------------------------------------
// Overlays
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    NSLog(@"===================================================================================================");
    NSLog(@"- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay ");
    return nil;
}
- (void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews {
    NSLog(@"===================================================================================================");
    NSLog(@"- (void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews ");
}


// ---------------------------------------------------------------------------------------------------------------------
// iOS 4.0 additions:
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    NSLog(@"===================================================================================================");
    NSLog(@"- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view ");

    if([view.annotation isKindOfClass:[MyMKPointAnnotation class]]) {

        //UIImage *selectionCircle = [UIImage imageNamed:@"selectionCircle.png"];
        //view.centerOffset = CGPointMake(0, 0);
        //view.image = selectionCircle;

        
        /*
         IconData *icon = [ImageManager iconDataForHREF:@"http://maps.gstatic.com/mapfiles/ms2/micons/lodging.png"];
         view.image = icon.image;
         view.centerOffset = CGPointMake(0, -icon.image.size.height/2);
        // create a new bitmap image context at the device resolution (retina/non-retina)
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), YES, 0.0);
        
        // get context
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // push context to make it current
        // (need to do this manually because we are not drawing in a UIView)
        UIGraphicsPushContext(context);
        
        // drawing code comes here- look at CGContext reference
        // for available operations
        // this example draws the inputImage into the context
        [inputImage drawInRect:CGRectMake(0, 0, width, height)];
        
        // pop context
        UIGraphicsPopContext();
        
        // get a UIImage from the image context- enjoy!!!
        UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
        
        // clean up drawing environment
        UIGraphicsEndImageContext();
        */
    }
}
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    NSLog(@"===================================================================================================");
    NSLog(@"- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view ");
    
    /*
    if([view.annotation isKindOfClass:[MyMKPointAnnotation class]]) {
        MyMKPointAnnotation *annotation = view.annotation;
        IconData *icon = [ImageManager iconDataForHREF:annotation.iconHREF];
        view.image = icon.image;
        view.centerOffset = CGPointMake(0, -32/2);
        [view setNeedsDisplay];
    }
     */
}
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    NSLog(@"===================================================================================================");
    NSLog(@"- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation ");
}
- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    NSLog(@"===================================================================================================");
    NSLog(@"- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error -> %@ ",error);
}
- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView {
    NSLog(@"===================================================================================================");
    NSLog(@"- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView ");
}
- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView {
    NSLog(@"===================================================================================================");
    NSLog(@"- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView ");
}
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    NSLog(@"===================================================================================================");
    NSLog(@"- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState ");
    
    /*
    MKAnnotationView __block *view = annotationView;
    
    if([annotationView.annotation isKindOfClass:[MyMKPointAnnotation class]]) {
        
        MyMKPointAnnotation *annotation = annotationView.annotation;
        IconData *icon;
        UIImage *selectionCircle = [UIImage imageNamed:@"selectionCircle2.png"];

        switch (newState) {
                
            case MKAnnotationViewDragStateStarting:
                view.image = selectionCircle;
                view.centerOffset = CGPointMake(0, 0);
                break;
                
            case MKAnnotationViewDragStateDragging:
                break;
                
            case MKAnnotationViewDragStateNone:
            case MKAnnotationViewDragStateCanceling:
            case MKAnnotationViewDragStateEnding:
                icon = [ImageManager iconDataForHREF:annotation.iconHREF];
                annotationView.image = icon.image;
                view.centerOffset = CGPointMake(0, -32/2);
                break;
                
            default:
                NSLog(@"default -> %d", newState);
                break;
        }
    }
     */
}




//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _dismissEditor {

    [self dismissViewControllerAnimated:YES completion:nil];

    // Set properties to nil
    self.delegate = nil;
    self.annotations = nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _btnCloseSave:(id)sender {
    
    [self _setEntityValuesFromFields];
    if([self.delegate closeVisualMapEditor:self annotations:self.annotations]) {
        [self _dismissEditor];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _btnCloseCancel:(id)sender {
    
    [self _dismissEditor];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _setFieldValuesFromEntity {
 
    [self.mapView addAnnotations:self.annotations];
    
    CLLocationCoordinate2D centerCoordinates;
    if(self.annotations.count>0) {
        MKPointAnnotation *pin = self.annotations[0];
        centerCoordinates.latitude = pin.coordinate.latitude;
        centerCoordinates.longitude = pin.coordinate.longitude;
    } else {
        MKUserLocation *uloc=self.mapView.userLocation;
        centerCoordinates.latitude = uloc.coordinate.latitude;
        centerCoordinates.longitude = uloc.coordinate.longitude;
    }
    
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinates, MKCoordinateSpanMake(LAT_SPAN_VERT, LNG_SPAN_VERT));
    [self.mapView setRegion:region animated:TRUE];
    self.mapView.centerCoordinate = centerCoordinates;

}

//---------------------------------------------------------------------------------------------------------------------
- (void) _setEntityValuesFromFields {

}




@end

