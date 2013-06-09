//
//  PointEditorViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __PointEditorViewController__IMPL__
#define __EntityEditorViewController__SUBCLASSES__PROTECTED__

#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import "PointEditorViewController.h"

#import "MPoint.h"
#import "MMap.h"
#import "MCategory.h"
#import "MMapThumbnail.h"

#import "IconEditorViewController.h"
#import "LatLngEditorViewController.h"
#import "CategorySelectorViewController.h"
#import "VisualMapEditorViewController.h"
#import "MyMKPointAnnotation.h"

#import "UIView+FirstResponder.h"
#import "ImageManager.h"
#import "NSString+JavaStr.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface PointEditorViewController() <UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate,
                                        IconEditorDelegate, LatLngEditorDelegate, VisualMapEditorDelegate, CategorySelectorDelegate>


@property (nonatomic, assign) IBOutlet UIImageView *iconImageField;
@property (nonatomic, assign) IBOutlet UITextField *nameField;
@property (nonatomic, assign) IBOutlet UILabel *pointLatLng;
@property (nonatomic, assign) IBOutlet UILabel *gpsAccuracy;
@property (nonatomic, assign) IBOutlet UIImageView *mapThumbnail;
@property (nonatomic, assign) IBOutlet UIImageView *positionDot;
@property (nonatomic, assign) IBOutlet UIActivityIndicatorView *thumbnailSpinner;
@property (nonatomic, assign) IBOutlet UITextView *descrField;
@property (nonatomic, assign) IBOutlet UILabel *extraInfo;

@property (nonatomic, assign) double thumbnail_latitude;
@property (nonatomic, assign) double thumbnail_longitude;
@property (nonatomic, strong) NSData *thumbnail_imgData;
@property (nonatomic, strong) MMapThumbnailTicket *ticket;

@property (nonatomic, strong) CLLocationManager *locMgr;
@property (nonatomic, assign) BOOL usingGPSLocation;

@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation PointEditorViewController




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (PointEditorViewController *) editor {
   PointEditorViewController *me = [[PointEditorViewController alloc] initWithNibName:@"PointEditorViewController" bundle:nil];
    return me;
}






//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    
    [super viewDidLoad];

    // Inicializa la geolocalizacion
    self.locMgr = [[CLLocationManager alloc] init];
    self.locMgr.delegate = self;
    self.locMgr.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; // En metros
    self.locMgr.distanceFilter = kCLDistanceFilterNone; // En metros
    self.usingGPSLocation = FALSE;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    // Rota la imagen con el icono para indicar que esditable
    [self _rotateImageField:self.iconImageField];
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return TRUE;
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (MPoint *) point {
    return (MPoint *)self.entity;
}




//=====================================================================================================================
#pragma mark -
#pragma mark <IconEditorDelegate, LatLngEditorDelegate, VisualMapEditorDelegate, CategorySelectorDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (BOOL) closeIconEditor:(IconEditorViewController *)senderEditor {

    self.point.iconHREF = senderEditor.iconBaseHREF;
    [self _setImageFieldFromPoint];
    return true;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) closeLatLngEditor:(LatLngEditorViewController *)senderEditor Lat:(CGFloat)latitude Lng:(CGFloat)longitude {
    
    [self _showAndStoreLatitude:latitude longitude:longitude];
    return TRUE;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) closeVisualMapEditor:(VisualMapEditorViewController *)senderEditor annotations:(NSArray *)annotations {
    
    // El array de anotaciones deberia tener solo un elemento. En el que solo se deberia haber modificado la posicion
    MyMKPointAnnotation *theAnnotation = (MyMKPointAnnotation *)[annotations objectAtIndex:0];
    if(theAnnotation!=nil) {
        [self _showAndStoreLatitude:theAnnotation.coordinate.latitude longitude:theAnnotation.coordinate.longitude];
    }
    
    return TRUE;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) closeCategorySelector:(CategorySelectorViewController *)senderEditor selectedCategories:(NSArray *)selectedCategories {

    [self.point replaceCategories:selectedCategories];
    return TRUE;
}




// =====================================================================================================================
#pragma mark -
#pragma mark <CoreLocationControllerDelegate> protocol methods
// ---------------------------------------------------------------------------------------------------------------------
// Our location updates are sent here
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self _showGPSAccuracyForLocation:newLocation];
    if(self.usingGPSLocation && newLocation!=nil) {
        [self _showAndStoreLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
// Any errors are sent here
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    self.gpsAccuracy.text = @"GPS accuracy: UNKNOWN";
}



//=====================================================================================================================
#pragma mark -
#pragma mark BIAction methods
//---------------------------------------------------------------------------------------------------------------------
- (IBAction)iconImageTapAction:(UITapGestureRecognizer *)sender {
    
    if(sender.state == UIGestureRecognizerStateEnded) {
        [self.view findFirstResponderAndResign];
        [IconEditorViewController startEditingIcon:self.point.iconHREF delegate:self];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction) btnLocationGPSClicked:(id)sender {
    
    [self.view findFirstResponderAndResign];
    self.usingGPSLocation = TRUE;
    [self.locMgr startUpdatingLocation];
    //[self locationManager:self.locMgr didUpdateToLocation:self.locMgr.location fromLocation:nil];
}

// ---------------------------------------------------------------------------------------------------------------------
- (IBAction) btnLocationEditorClicked:(id)sender {
    
    [self.view findFirstResponderAndResign];
    self.usingGPSLocation = FALSE;
    [self.locMgr stopUpdatingLocation];
    [LatLngEditorViewController startEditingLat:self.point.latitudeValue Lng:self.point.longitudeValue delegate:self];
}

// ---------------------------------------------------------------------------------------------------------------------
- (IBAction)btnLocationMapClicked:(UIButton *)sender {
    
    [self.view findFirstResponderAndResign];
    self.usingGPSLocation = FALSE;
    [self.locMgr stopUpdatingLocation];
    
    
    CLLocationCoordinate2D pinCoordinates = {.latitude = self.point.latitudeValue, .longitude = self.point.longitudeValue};
    MyMKPointAnnotation *pin = [[MyMKPointAnnotation alloc] init];
    pin.title = self.nameField.text;
    pin.subtitle = @"pepe";
    pin.coordinate = pinCoordinates;
    pin.iconHREF = self.point.iconHREF;
    NSArray *annotations = [NSArray arrayWithObject:pin];
    
    [VisualMapEditorViewController startEditingAnnotations:annotations delegate:self];
}

// ---------------------------------------------------------------------------------------------------------------------
- (IBAction)btnEditCategories:(UIButton *)sender {
    
    [CategorySelectorViewController startCategoriesSelectorInContext:self.moContext
                                                         selectedMap:self.point.map
                                                 currentSelectedCats:self.point.categories.allObjects
                                                 excludeFromCategory:nil
                                                      multiSelection:YES
                                                            delegate:self];
}




//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (NSString *) _editorTitle {
    return @"Point Editor";
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _nullifyEditor {
    
    [super _nullifyEditor];
    self.ticket = nil;
    self.thumbnail_imgData = nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _setImageFieldFromPoint {
    
    IconData *icon = [ImageManager iconDataForHREF:self.point.iconHREF];
    self.iconImageField.image = icon.image;
}


//---------------------------------------------------------------------------------------------------------------------
- (void) _setFieldValuesFromEntity {
    
    self.nameField.text = self.point.name;
    
    [self _setImageFieldFromPoint];

    [self _showGPSAccuracyForLocation:self.locMgr.location];

    self.thumbnail_latitude = self.point.thumbnail.latitudeValue;
    self.thumbnail_longitude = self.point.thumbnail.longitudeValue;
    self.thumbnail_imgData = self.point.thumbnail.imageData;
    [self _showAndStoreLatitude:self.point.latitudeValue longitude:self.point.longitudeValue];
    
    self.descrField.text = self.point.descr;
    
    self.extraInfo.text = [NSString stringWithFormat:@"Published:\t%@\nUpdated:\t%@\nETAG:\t%@",
                           [MBaseEntity stringFromDate:self.point.creationTime],
                           [MBaseEntity stringFromDate:self.point.updateTime],
                           self.point.etag];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _setEntityFromFieldValues {

    
    
    if(self.point) {
        // *** CONTROL DE SEGURIDAD (@name) PARA NO TOCAR Points BUENOS ***
        NSString *name = self.nameField.text;
        if([name hasPrefix:@"@"]) {
            self.point.name = name;
        } else {
            self.point.name = [NSString stringWithFormat:@"@%@", name];
        }
        
        self.point.descr = self.descrField.text;
        
        [self.point markAsModified];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _showGPSAccuracyForLocation:(CLLocation *)loc {
    
    if(loc) {
        self.gpsAccuracy.text = [NSString stringWithFormat:@"GPS accuracy: %0.0f m", loc.horizontalAccuracy];
    } else {
        self.gpsAccuracy.text = @"GPS accuracy: UNKNOWN";
    }
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _showAndStoreLatitude:(double)lat longitude:(double)lng {
    
    // Solo actua si hay cambios en los valores
    if(self.point.latitudeValue==lat && self.point.longitudeValue==lng) {
        return;
    }
    
    [self.point setLatitude:lat longitude:lng];
    self.pointLatLng.text = [NSString stringWithFormat:@"Lat:\t%0.06f\nLng:\t%0.06f", lat, lng];
    
    // Ajusta la imagen del thumbnail segun se cambien la posicion
    if(self.thumbnail_imgData == nil ||
       self.thumbnail_latitude != lat ||
       self.thumbnail_longitude != lng) {
        
        [self.positionDot  setHidden:TRUE];
        
        //if(!self.thumbnail_imgData)
        {
            self.mapThumbnail.image = [UIImage imageNamed:@"staticMapNone2.png"];
        }
        
        [self.thumbnailSpinner setHidden:FALSE];
        [self.thumbnailSpinner startAnimating];
        
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
                                                               [self.thumbnailSpinner stopAnimating];
                                                               if(self.thumbnail_imgData) {
                                                                   self.mapThumbnail.image = [[UIImage alloc] initWithData:self.thumbnail_imgData];
                                                                   [self.positionDot  setHidden:FALSE];
                                                               }
                                                           });
                                                       }];
        
    } else {
        
        self.mapThumbnail.image = [[UIImage alloc] initWithData:self.thumbnail_imgData];
        [self.positionDot  setHidden:FALSE];
        
    }
    
}



@end

