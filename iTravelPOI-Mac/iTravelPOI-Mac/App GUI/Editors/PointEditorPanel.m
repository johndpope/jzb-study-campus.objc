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
#import "MMapThumbnail.h"
#import "ImageManager.h"
#import "IconEditorPanel.h"
#import "GMapPointEditorPanel.h"
#import "NSString+JavaStr.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
// *********************************************************************************************************************


// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface PointEditorPanel () <IconEditorPanelDelegate, GMapPointEditorPanelDelegate, NSTextFieldDelegate, NSTextViewDelegate, CLLocationManagerDelegate>


@property (nonatomic, assign) IBOutlet NSButton *iconImageBtnField;
@property (nonatomic, assign) IBOutlet NSTextField *pointNameField;
@property (nonatomic, assign) IBOutlet NSTextField *pointCategoryField;
@property (nonatomic, assign) IBOutlet NSTextView *pointDescrField;
@property (nonatomic, assign) IBOutlet NSTextField *pointExtraInfo;

@property (nonatomic, assign) IBOutlet NSTextField *pointLatLng;
@property (nonatomic, assign) IBOutlet NSTextField *gpsAccuracy;
@property (nonatomic, assign) IBOutlet NSImageView *pointMapThumbnail;
@property (nonatomic, assign) IBOutlet NSProgressIndicator *thumbnailSpinner;

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double thumbnail_latitude;
@property (nonatomic, assign) double thumbnail_longitude;
@property (nonatomic, strong) NSData *thumbnail_imgData;
@property (nonatomic, strong) MMapThumbnailTicket *ticket;
@property (nonatomic, strong) IBOutlet NSImageView *positionDot;


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
    
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    self.locMgr = [[CLLocationManager alloc] init];
    self.locMgr.delegate = self;
    self.locMgr.purpose = @"To establish POI lat/lng at current position";
    self.locMgr.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; // En metros
    self.locMgr.distanceFilter = kCLDistanceFilterNone; // En metros
    
    self.latitude = HUGE_VAL;
    self.longitude =HUGE_VAL;
    self.thumbnail_latitude = HUGE_VAL;
    self.thumbnail_longitude = HUGE_VAL;
    self.UseGPSLocation = FALSE;
    
    [super windowDidLoad];

}

// ---------------------------------------------------------------------------------------------------------------------
- (void)dealloc {
    [self.locMgr stopUpdatingLocation];
    self.thumbnail_imgData = nil;
    self.ticket = nil;
}



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
- (IBAction) btnLocationGPSClicked:(id)sender {
    self.UseGPSLocation = TRUE;
    [self.locMgr startUpdatingLocation];
    [self locationManager:self.locMgr didUpdateToLocation:self.locMgr.location fromLocation:nil];
}

// ---------------------------------------------------------------------------------------------------------------------
- (IBAction) btnLocationMapClicked:(id)sender {
    
    CLLocationCoordinate2D pinCoordinates = {.latitude = self.latitude, .longitude = self.longitude};
    MyMKPointAnnotation2 *pin = [[MyMKPointAnnotation2 alloc] init];
    pin.title = self.pointNameField.stringValue;
    pin.subtitle = @"pepe";
    pin.coordinate = pinCoordinates;
    pin.iconHREF = self.iconBaseHREF;
    NSArray *annotations = [NSArray arrayWithObject:pin];
    [GMapPointEditorPanel startGMapPointEditor:annotations delegate:self];
}

// ---------------------------------------------------------------------------------------------------------------------
- (IBAction) btnLocationEditorClicked:(id)sender {
}

// ---------------------------------------------------------------------------------------------------------------------
- (IBAction) iconImageBtnClicked:(id)sender {
    [IconEditorPanel startEditIconBaseHREF:self.iconBaseHREF delegate:self];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) willCloseWithSave:(BOOL)saving {
    [self.ticket cancelNotificationSaving:saving];
    self.ticket = nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setImageFieldFromHREF:(NSString *)iconHREF {
    
    IconData *icon = [ImageManager iconDataForHREF:iconHREF];
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

    if(self.point) {
        [self showGPSAccuracyForLocation:self.locMgr.location];
        
        [self setImageFieldFromHREF:self.point.iconHREF];

        self.iconBaseHREF = self.point.iconHREF;
        self.pointCategoryField.stringValue = @"xxxx";

        self.pointNameField.stringValue = self.point.name;

        self.thumbnail_latitude = self.point.thumbnail.latitudeValue;
        self.thumbnail_longitude = self.point.thumbnail.longitudeValue;
        self.thumbnail_imgData = self.point.thumbnail.imageData;
        [self showAndStoreLatitude:self.point.latitudeValue longitude:self.point.longitudeValue];

        self.pointDescrField.string = self.point.descr;
        self.pointExtraInfo.stringValue = [NSString stringWithFormat:@"Published:\t%@\nUpdated:\t%@\nETAG:\t%@",
                                           [MBaseEntity stringFromDate:self.point.creationTime],
                                           [MBaseEntity stringFromDate:self.point.updateTime],
                                           self.point.etag];
        
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
        
        [self.point setLatitude:self.latitude longitude:self.longitude];

        self.point.descr = [self.pointDescrField string];


        [self.point markAsModified];
    }
}

// =====================================================================================================================
#pragma mark -
#pragma mark <IconEditorPanelDelegate> protocol methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) iconPanelClose:(IconEditorPanel *)sender {
    [self setImageFieldFromHREF:sender.baseHREF];
    self.iconBaseHREF = sender.baseHREF;
}



// =====================================================================================================================
#pragma mark -
#pragma mark <GMapPointEditorPanelDelegate> protocol methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) editorPanelSaveChanges:(GMapPointEditorPanel *)sender {

    MyMKPointAnnotation2 *pin = sender.annotations[0];
    [self showAndStoreLatitude:pin.coordinate.latitude longitude:pin.coordinate.longitude];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) editorPanelCancelChanges:(GMapPointEditorPanel *)sender {
    
}


// =====================================================================================================================
#pragma mark -
#pragma mark <CoreLocationControllerDelegate> protocol methods
// ---------------------------------------------------------------------------------------------------------------------
// Our location updates are sent here
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self showGPSAccuracyForLocation:newLocation];
    if(self.UseGPSLocation && newLocation!=nil) {
        [self showAndStoreLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
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
        self.gpsAccuracy.stringValue = [NSString stringWithFormat:@"GPS accuracy: %0.0f m", loc.horizontalAccuracy];
    } else {
        self.gpsAccuracy.stringValue = @"GPS accuracy: UNKNOWN";
    }
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) showAndStoreLatitude:(double)lat longitude:(double)lng {
    
    // Solo actua si hay cambios en los valores
    if(self.latitude==lat && self.longitude==lng) {
        return;
    }
    
    
    self.latitude = lat;
    self.longitude = lng;
    self.pointLatLng.stringValue = [NSString stringWithFormat:@"Lat:\t%0.06f\nLng:\t%0.06f", lat, lng];
    
    // Ajusta la imagen del thumbnail segun se cambien la posicion
    if(self.thumbnail_imgData == nil ||
       self.thumbnail_latitude != lat ||
       self.thumbnail_longitude != lng) {
        
        [self.positionDot  setHidden:TRUE];

        //if(!self.thumbnail_imgData)
        {
            self.pointMapThumbnail.image = [NSImage imageNamed:@"staticMapNone2.png"];
        }
        
        [self.thumbnailSpinner setHidden:FALSE];
        [self.thumbnailSpinner startAnimation:self];

        // Cancela el ticket anterior, si lo hubiese, indicando que no salve
        [self.ticket cancelNotificationSaving:FALSE];
        // Abre un nuevo ticket
        self.ticket = [self.point.thumbnail asyncUpdateLatitude:lat
                                                      longitude:lng
                                                       callback:^void (double lat, double lng, NSData *imageData) {
                                                           
                                                           self.thumbnail_latitude = lat;
                                                           self.thumbnail_longitude = lng;
                                                           self.thumbnail_imgData = imageData;
                                                           
                                                           self.point.thumbnail.latitudeValue = lat;
                                                           self.point.thumbnail.longitudeValue = lng;
                                                           self.point.thumbnail.imageData = imageData;
                                                           
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               [self.thumbnailSpinner setHidden:TRUE];
                                                               [self.thumbnailSpinner stopAnimation:self];
                                                               if(self.thumbnail_imgData) {
                                                                   self.pointMapThumbnail.image = [[NSImage alloc] initWithData:self.thumbnail_imgData];
                                                                   [self.positionDot  setHidden:FALSE];
                                                               }
                                                           });
                                                       }];
        
    } else {
        
        self.pointMapThumbnail.image = [[NSImage alloc] initWithData:self.thumbnail_imgData];
        [self.positionDot  setHidden:FALSE];
        
    }

}


@end
