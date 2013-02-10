//
// PointEditorPanel.m
// iTravelPOI-Mac
//
// Created by Jose Zarzuela on 13/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __EntityEditorPanel__IMPL__
#define __PointEditorPanel__IMPL__
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import "PointEditorPanel.h"
#import "MCategory.h"
#import "IconManager.h"
#import "IconEditorPanel.h"
#import "NSString+JavaStr.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
// *********************************************************************************************************************


// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface PointEditorPanel () <IconEditorPanelDelegate, NSTextFieldDelegate, NSTextViewDelegate, CLLocationManagerDelegate>


@property (nonatomic, assign) IBOutlet NSButton *iconImageBtnField;
@property (nonatomic, assign) IBOutlet NSTextField *pointNameField;
@property (nonatomic, assign) IBOutlet NSTextField *pointCategoryField;
@property (nonatomic, assign) IBOutlet NSTextView *pointDescrField;
@property (nonatomic, assign) IBOutlet NSTextField *pointExtraInfo;

@property (nonatomic, assign) IBOutlet NSTextField *pointLatitude;
@property (nonatomic, assign) IBOutlet NSTextField *pointLongitude;
@property (nonatomic, assign) IBOutlet NSTextField *gpsAccuracy;
@property (nonatomic, assign) IBOutlet NSImageView *pointMapThumbnail;


@property (nonatomic, strong) NSString *iconBaseHREF;

@property (nonatomic, strong) CLLocationManager *locMgr;
@property (nonatomic, assign) BOOL UseGPSLocation;

@end


// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation PointEditorPanel



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (PointEditorPanel *) startEditPoint:(MPoint *)point delegate:(id<EntityEditorPanelDelegate>)delegate {

    PointEditorPanel *me = [[PointEditorPanel alloc] initWithWindowNibName:@"PointEditorPanel"];
    return (PointEditorPanel *)[EntityEditorPanel panel:me startEditingEntity:point delegate:delegate];
}

// =====================================================================================================================
#pragma mark -
#pragma mark Initialization & finalization
// ---------------------------------------------------------------------------------------------------------------------
- (void) windowDidLoad {
    
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.

    self.locMgr = [[CLLocationManager alloc] init];
    self.locMgr.delegate = self;
    self.locMgr.purpose = @"To establish POI lat/lng at current position";
    self.locMgr.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; // En metros
    self.locMgr.distanceFilter = kCLDistanceFilterNone; // En metros
    [self.locMgr startUpdatingLocation];
    
    self.UseGPSLocation = FALSE;
    [self showGPSAccuracyForLocation:self.locMgr.location];

}

// ---------------------------------------------------------------------------------------------------------------------
- (void)dealloc {
    [self.locMgr stopUpdatingLocation];
}
/*
[UIView beginAnimations:nil context:NULL];
[UIView setAnimationDuration:0.7];
[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.imageIcon cache:YES];
self.imageIcon.image = self.tempIcon.image;
[UIView commitAnimations];
*/

// =====================================================================================================================
#pragma mark -
#pragma mark Getter/Setter methods
// ---------------------------------------------------------------------------------------------------------------------
- (MPoint *) point {
    return (MPoint *)self.entity;
}



// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
- (IBAction) useGPSLocationBtnClicked:(id)sender {
    self.UseGPSLocation = TRUE;
    [self locationManager:self.locMgr didUpdateToLocation:self.locMgr.location fromLocation:nil];
}

// ---------------------------------------------------------------------------------------------------------------------
- (IBAction) iconImageBtnClicked:(id)sender {
    [IconEditorPanel startEditIconBaseHREF:self.iconBaseHREF delegate:self];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setImageFieldFromHREF:(NSString *)iconHREF {
    
    IconData *icon = [IconManager iconDataForHREF:iconHREF];
    self.iconImageBtnField.image = icon.image;
    [self.iconImageBtnField setImagePosition:NSImageOnly];
    
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    rotate.fromValue = [NSNumber numberWithFloat:0];
    rotate.toValue = [NSNumber numberWithFloat:-2*M_PI];
    rotate.duration = 1.0;
    rotate.repeatCount = 1;
    [self.iconImageBtnField.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
    [self.iconImageBtnField.layer addAnimation:rotate forKey:@"trans_rotation"];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setFieldValuesFromEntity {

    NSString *imagePath = @"/Users/jzarzuela/Downloads/staticmapx1.png";
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];
    self.pointMapThumbnail.image = image;
    

    
    if(self.point) {
        [self setImageFieldFromHREF:self.point.category.iconBaseHREF];

        self.iconBaseHREF = self.point.category.iconBaseHREF;
        self.pointCategoryField.stringValue = self.point.category.iconExtraInfo;

        self.pointNameField.stringValue = self.point.name;

        self.pointLatitude.stringValue = [NSString stringWithFormat:@"%0.06f", self.point.latitudeValue];
        self.pointLongitude.stringValue = [NSString stringWithFormat:@"%0.06f", self.point.longitudeValue];

        self.pointDescrField.string = self.point.descr;
        self.pointExtraInfo.stringValue = [NSString stringWithFormat:@"Published: %@\tUpdated: %@\nETAG: %@",
                                           [MBaseEntity stringFromDate:self.point.published_date],
                                           [MBaseEntity stringFromDate:self.point.updated_date],
                                           self.point.etag];

        self.point.modifiedSinceLastSyncValue = true;
        self.point.map.modifiedSinceLastSyncValue = true;
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setEntityFromFieldValues {

    
    if(self.point) {
        // *** CONTROL DE SEGURIDAD (@name) PARA NO TOCAR Points BUENOS ***
        NSString *name = self.pointNameField.stringValue;
        if([name hasPrefix:@"@"]) {
            self.point.name = name;
        } else {
            self.point.name = [NSString stringWithFormat:@"@%@", name];
        }
        
        self.point.latitudeValue = self.pointLatitude.doubleValue;
        self.point.longitudeValue = self.pointLongitude.doubleValue;

        self.point.descr = [self.pointDescrField string];
        self.point.updated_date = [NSDate date];

        NSString *cleanCatName = [self.pointCategoryField.stringValue replaceStr:@"&" with:@"%"];
        MCategory *destCat = [MCategory categoryForIconBaseHREF:self.iconBaseHREF
                                                      extraInfo:cleanCatName
                                                      inContext:self.point.managedObjectContext];
        
        [self.point moveToCategory:destCat];
    }
}

// =====================================================================================================================
#pragma mark -
#pragma mark <IconEditorPanelDelegate> protocol methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) iconPanelSaveChanges:(IconEditorPanel *)sender {
    [self setImageFieldFromHREF:sender.baseHREF];
    self.iconBaseHREF = sender.baseHREF;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) iconPanelCancelChanges:(IconEditorPanel *)sender {
    // nothing
}


// =====================================================================================================================
#pragma mark -
#pragma mark <CoreLocationControllerDelegate> protocol methods
// ---------------------------------------------------------------------------------------------------------------------
// Our location updates are sent here
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self showGPSAccuracyForLocation:newLocation];
    if(self.UseGPSLocation && newLocation!=nil) {
        self.pointLatitude.stringValue = [NSString stringWithFormat:@"%0.6f", newLocation.coordinate.latitude];
        self.pointLongitude.stringValue = [NSString stringWithFormat:@"%0.6f", newLocation.coordinate.longitude];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
// Any errors are sent here
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    //NSLog(@"error = %@", error);
    [self showGPSAccuracyForLocation:manager.location];
}




// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) showGPSAccuracyForLocation:(CLLocation *)loc {
    
    if(loc) {
        self.gpsAccuracy.stringValue = [NSString stringWithFormat:@"GPS accuracy: %0.2f meters", loc.horizontalAccuracy];
    } else {
        self.gpsAccuracy.stringValue = @"GPS accuracy: UNKNOWN";
    }
    
}

@end
