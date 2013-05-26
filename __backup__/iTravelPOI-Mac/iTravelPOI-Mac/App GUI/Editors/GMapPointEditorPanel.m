//
// GMapPointEditorPanel.m
// iTravelPOI-Mac
//
// Created by Jose Zarzuela on 13/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __GMapPointEditorPanel__IMPL__
#import "GMapPointEditorPanel.h"
#import "ImageManager.h"
#import "MKMapView.h"
#import "MyMKPointAnnotation2.h"
#import "MKMapView+ZoomLevel.h"
#import "MKUserLocation.h"

/*
#import "MKCircle.h"
#import "MKPinAnnotationView.h"
*/



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
// *********************************************************************************************************************
#define LAT_SPAN_VERT 0.006469
#define LNG_SPAN_VERT 0.006824


// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface GMapPointEditorPanel () <MKMapViewDelegate, NSTextFieldDelegate>

@property (nonatomic, assign) IBOutlet MKMapView *mapView;
@property (nonatomic, assign) IBOutlet NSSearchField *searchField;

@property (nonatomic, strong) GMapPointEditorPanel *myself;


@end


// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation GMapPointEditorPanel



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (GMapPointEditorPanel *) startGMapPointEditor:(NSArray *)annotations delegate:(id<GMapPointEditorPanelDelegate>)delegate {

    if(annotations == nil || delegate == nil) {
        return nil;
    }

    GMapPointEditorPanel *panel = [[GMapPointEditorPanel alloc] initWithWindowNibName:@"GMapPointEditorPanel"];
    if(panel) {
        panel.myself = panel;
        panel.delegate = delegate;
        panel.annotations = annotations;
        
        [NSApp beginSheet:panel.window
           modalForWindow:[delegate window]
            modalDelegate:nil
           didEndSelector:nil
              contextInfo:nil];


        return panel;
        
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
    self.searchField.delegate = self;
    self.mapView.delegate = self;
    self.mapView.showsUserLocation=TRUE;
    [self setFieldValuesFromEntity];
}



// =====================================================================================================================
#pragma mark -
#pragma mark Getter/Setter methods
// ---------------------------------------------------------------------------------------------------------------------


// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
- (IBAction) btnCloseSave:(id)sender {

    if(self.delegate && [self.delegate respondsToSelector:@selector(editorPanelSaveChanges:)]) {
        [self setEntityFromFieldValues];
        [self.delegate editorPanelSaveChanges:self];
    }
    [self closePanel];
}

// ---------------------------------------------------------------------------------------------------------------------
- (IBAction) btnCloseCancel:(id)sender {
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(editorPanelCancelChanges:)]) {
        [self.delegate editorPanelCancelChanges:self];
    }
    [self closePanel];
}

// ---------------------------------------------------------------------------------------------------------------------
- (IBAction) btnShowUserLocation:(id)sender {
    
    MKUserLocation *uloc=self.mapView.userLocation;
    CLLocationCoordinate2D centerCoordinates = {.latitude = uloc.coordinate.latitude, .longitude = uloc.coordinate.longitude};
    [self.mapView setCenterCoordinate:centerCoordinates animated:TRUE];
}

// ---------------------------------------------------------------------------------------------------------------------
- (IBAction) btnShowPinLocation:(id)sender {
    
    MyMKPointAnnotation2 *pin = self.annotations[0];
    CLLocationCoordinate2D centerCoordinates = {.latitude = pin.coordinate.latitude, .longitude = pin.coordinate.longitude};
    [self.mapView setCenterCoordinate:centerCoordinates animated:TRUE];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) closePanel {

    [NSApp endSheet:self.window];
    [self.window close];
    self.window = nil;
    self.annotations = nil;
    self.delegate = nil;
    self.myself = nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setFieldValuesFromEntity {
    
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setEntityFromFieldValues {

}



// =====================================================================================================================
#pragma mark -
#pragma mark <NSTextFieldDelegate> methods
// ---------------------------------------------------------------------------------------------------------------------
- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    NSLog(@"===================================================================================================");
    NSLog(@"- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector");
    NSLog(@"selector: %s", sel_getName(commandSelector));
    SEL mySel = @selector(insertNewline:);
    if(mySel==commandSelector) {
    }
    return NO;
}




// =====================================================================================================================
#pragma mark -
#pragma mark <MKMapViewDelegate> methods
// ---------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    //NSLog(@"===================================================================================================");
    //NSLog(@"- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated");
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    //NSLog(@"===================================================================================================");
    //NSLog(@"- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated");
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
    NSLog(@"===================================================================================================");
    NSLog(@"- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView");
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    NSLog(@"===================================================================================================");
    NSLog(@"");
}


// mapView:didAddAnnotationViews: is called after the annotation views have been added and positioned in the map.
// The delegate can implement this method to animate the adding of the annotations views.
// Use the current positions of the annotation views as the destinations of the animation.
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    NSLog(@"===================================================================================================");
    NSLog(@"- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views");
}

// mapView:annotationView:calloutAccessoryControlTapped: is called when the user taps on left & right callout accessory UIControls.
//- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;

// Overlays
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    NSLog(@"===================================================================================================");
    NSLog(@"- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay");
    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews {
    NSLog(@"===================================================================================================");
    NSLog(@"- (void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews");
}


// iOS 4.0 additions:
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    NSLog(@"===================================================================================================");
    NSLog(@"- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view");
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    NSLog(@"===================================================================================================");
    NSLog(@"- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view");
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    //NSLog(@"===================================================================================================");
    //NSLog(@"- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation");
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    NSLog(@"===================================================================================================");
    NSLog(@"- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error");
}

- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView {
    NSLog(@"===================================================================================================");
    NSLog(@"- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView");
}

- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView {
    NSLog(@"===================================================================================================");
    NSLog(@"- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView");
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    NSLog(@"===================================================================================================");
    NSLog(@"- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState");
}

// MacMapKit additions
- (void)mapView:(MKMapView *)mapView userDidClickAndHoldAtCoordinate:(CLLocationCoordinate2D)coordinate {
    NSLog(@"===================================================================================================");
    NSLog(@"- (void)mapView:(MKMapView *)mapView userDidClickAndHoldAtCoordinate:(CLLocationCoordinate2D)coordinate");
}

- (NSArray *)mapView:(MKMapView *)mapView contextMenuItemsForAnnotationView:(MKAnnotationView *)view {
    NSLog(@"===================================================================================================");
    NSLog(@"- (NSArray *)mapView:(MKMapView *)mapView contextMenuItemsForAnnotationView:(MKAnnotationView *)view");
    return nil;
}



// ---------------------------------------------------------------------------------------------------------------------
// mapView:viewForAnnotation: provides the view for each annotation.
// This method may be called for all or some of the added annotations.
// For MapKit provided annotations (eg. MKUserLocation) return nil to use the MapKit provided annotation view.
- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>)t_annotation {
    
    MyMKPointAnnotation2 *annotation = t_annotation;
    MKAnnotationView *view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MyGPointView"];

    IconData *icon = [ImageManager iconDataForHREF:annotation.iconHREF];
    NSURL *url = [NSURL fileURLWithPath:icon.imagePath];
    view.imageUrl = [url absoluteString];
    view.draggable = YES;
    view.canShowCallout = YES;
    
    return view;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    
    [self.mapView addAnnotations:self.annotations];
    
    CLLocationCoordinate2D centerCoordinates;
    if(self.annotations.count>0) {
        MyMKPointAnnotation2 *pin = self.annotations[0];
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




// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------

@end