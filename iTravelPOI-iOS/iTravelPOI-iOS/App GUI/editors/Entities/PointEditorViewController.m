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
#import "UIPlaceHolderTextView.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface PointEditorViewController() <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate,
                                        IconEditorDelegate, LatLngEditorDelegate, VisualMapEditorDelegate, CategorySelectorDelegate>


@property (nonatomic, assign) IBOutlet UIImageView              *fIconImage;
@property (nonatomic, assign) IBOutlet UITextField              *fName;
@property (nonatomic, assign) IBOutlet UITableView              *fCategoriesTable;
@property (nonatomic, assign) IBOutlet UIImageView              *fMapThumbnail;
@property (nonatomic, assign) IBOutlet UILabel                  *fPointLatLng;
@property (nonatomic, assign) IBOutlet UILabel                  *fGpsAccuracy;
@property (nonatomic, assign) IBOutlet UIImageView              *fPositionDot;
@property (nonatomic, assign) IBOutlet UIActivityIndicatorView  *fThumbnailSpinner;
@property (nonatomic, assign) IBOutlet UIPlaceHolderTextView    *fDescription;
@property (nonatomic, assign) IBOutlet UILabel                  *fExtraInfo;
@property (nonatomic, assign) IBOutlet UIView                   *vCategoriesSection;
@property (nonatomic, assign) IBOutlet UIView                   *vLocationSection;


@property (nonatomic, strong) NSString *iconHREF;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double thumbnail_latitude;
@property (nonatomic, assign) double thumbnail_longitude;
@property (nonatomic, strong) NSData *thumbnail_imgData;
@property (nonatomic, strong) MMapThumbnailTicket *ticket;


@property (nonatomic, strong) CLLocationManager *locMgr;
@property (nonatomic, assign) BOOL usingGPSLocation;
@property (nonatomic, strong) NSMutableArray *pointCategories;

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
    
    CGRect myFrame = self.view.frame;
    myFrame.size.height = 460;
    self.view.frame = myFrame;

    // Y del editor de texto
    UIImage *bgEditorImg = [[UIImage imageNamed:@"shadowedBox"] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6) resizingMode:UIImageResizingModeStretch];
    UIImageView *bgImgView3 = [[UIImageView alloc] initWithFrame:self.fDescription.frame];
    bgImgView3.image = bgEditorImg;
    [self.view insertSubview:bgImgView3 belowSubview:self.fDescription];
    self.fDescription.backgroundColor = [UIColor clearColor];
    self.fDescription.placeholder = @"Descripion goes here";
    
    
    [super viewDidLoad];

    // Inicializa la geolocalizacion
    self.locMgr = [[CLLocationManager alloc] init];
    self.locMgr.delegate = self;
    self.locMgr.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; // En metros
    self.locMgr.distanceFilter = kCLDistanceFilterNone; // En metros
    self.usingGPSLocation = FALSE;
    
    // Carga la imagen de fondo de las diferentes secciones
    UIImage *bgSectionViewImg = [[UIImage imageNamed:@"shadowedBoxPico"] resizableImageWithCapInsets:UIEdgeInsetsMake(52, 6, 6, 6) resizingMode:UIImageResizingModeStretch];

    // Establece el fondo de las vistas contenedoras de secciones
    CGSize viewSize1 = self.vCategoriesSection.frame.size;
    UIImageView *bgImgView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, viewSize1.width, viewSize1.height)];
    bgImgView1.image = bgSectionViewImg;
    [self.vCategoriesSection insertSubview:bgImgView1 atIndex:0];
    self.vCategoriesSection.backgroundColor = [UIColor clearColor];

    CGSize viewSize2 = self.vLocationSection.frame.size;
    UIImageView *bgImgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, viewSize2.width, viewSize2.height)];
    bgImgView2.image = bgSectionViewImg;
    [self.vLocationSection insertSubview:bgImgView2 atIndex:0];
    self.vLocationSection.backgroundColor = [UIColor clearColor];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    // Rota la imagen con el icono para indicar que esditable
    [self _rotateImageField:self.fIconImage];
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
- (MPoint *)point {
    return (MPoint *)self.entity;
}




//=====================================================================================================================
#pragma mark -
#pragma mark <IconEditorDelegate, LatLngEditorDelegate, VisualMapEditorDelegate, CategorySelectorDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (BOOL) closeIconEditor:(IconEditorViewController *)senderEditor {

    [self _setImageFieldFromHREF:senderEditor.iconBaseHREF];
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

    self.pointCategories = [NSArray arrayWithArray:selectedCategories];
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
    self.fGpsAccuracy.text = @"GPS accuracy: UNKNOWN";
}




// =====================================================================================================================
#pragma mark -
#pragma mark <UITableViewDataSource> protocol methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pointCategories.count==0 ? 1 : self.pointCategories.count;
}

//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *myViewCellID = @"myPointViewCellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myViewCellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myViewCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    if(self.pointCategories.count==0) {
        cell.textLabel.text = @"no categories";
    } else {
        MCategory *catToShow = (MCategory *)[self.pointCategories objectAtIndex:[indexPath indexAtPosition:1]];
        cell.textLabel.text = catToShow.fullName;
        cell.imageView.image = catToShow.entityImage;
    }
    return cell;
}





//=====================================================================================================================
#pragma mark -
#pragma mark BIAction methods
//---------------------------------------------------------------------------------------------------------------------
- (IBAction)iconImageTapAction:(UITapGestureRecognizer *)sender {
    
    if(sender.state == UIGestureRecognizerStateEnded) {
        [self.view findFirstResponderAndResign];
        [IconEditorViewController startEditingIcon:self.iconHREF delegate:self];
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
    [LatLngEditorViewController startEditingLat:self.latitude Lng:self.longitude delegate:self];
}

// ---------------------------------------------------------------------------------------------------------------------
- (IBAction)btnLocationMapClicked:(UIButton *)sender {
    
    [self.view findFirstResponderAndResign];
    self.usingGPSLocation = FALSE;
    [self.locMgr stopUpdatingLocation];
    
    
    CLLocationCoordinate2D pinCoordinates = {.latitude = self.latitude, .longitude = self.longitude};
    MyMKPointAnnotation *pin = [[MyMKPointAnnotation alloc] init];
    pin.title = self.fName.text;
    pin.subtitle = @"pepe";
    pin.coordinate = pinCoordinates;
    pin.iconHREF = self.iconHREF;
    NSArray *annotations = [NSArray arrayWithObject:pin];
    
    [VisualMapEditorViewController startEditingAnnotations:annotations delegate:self];
}

// ---------------------------------------------------------------------------------------------------------------------
- (IBAction)btnEditCategories:(UIButton *)sender {
    
    [CategorySelectorViewController startCategoriesSelectorInContext:self.moContext
                                                         selectedMap:self.point.map
                                                 currentSelectedCats:self.pointCategories
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
    self.pointCategories = nil;
    self.iconHREF = nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _setImageFieldFromHREF:(NSString *)iconHREF {

    self.iconHREF = iconHREF;
    IconData *icon = [ImageManager iconDataForHREF:self.iconHREF];
    self.fIconImage.image = icon.image;
}


//---------------------------------------------------------------------------------------------------------------------
- (void) _setFieldValuesFromEntity:(MBaseEntity *)entity {
    
    MPoint *point = (MPoint *)entity;
    
    
    self.fName.text = point.name;
    
    [self _setImageFieldFromHREF:point.iconHREF];

    [self _showGPSAccuracyForLocation:self.locMgr.location];
    
    self.pointCategories = [NSMutableArray arrayWithArray:point.categories.allObjects];

    self.thumbnail_latitude = point.thumbnail.latitudeValue;
    self.thumbnail_longitude = point.thumbnail.longitudeValue;
    self.thumbnail_imgData = point.thumbnail.imageData;
    [self _showAndStoreLatitude:point.latitudeValue longitude:point.longitudeValue];
    
    self.fDescription.text = point.descr;
    
    self.fExtraInfo.text = [NSString stringWithFormat:@"Published:\t%@\nUpdated:\t%@\nETAG:\t%@",
                            [MBaseEntity stringFromDate:point.creationTime],
                            [MBaseEntity stringFromDate:point.updateTime],
                            point.etag];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _setEntityFromFieldValues:(MBaseEntity *)entity {

    
    MPoint *point = (MPoint *)entity;
    
    if(point) {
        // *** CONTROL DE SEGURIDAD (@name) PARA NO TOCAR Points BUENOS ***
        NSString *name = self.fName.text;
        if([name hasPrefix:@"@"]) {
            point.name = name;
        } else {
            point.name = [NSString stringWithFormat:@"@%@", name];
        }
        
        point.descr = self.fDescription.text;
        point.iconHREF = self.iconHREF;
        [point setLatitude:self.latitude longitude:self.longitude];
        
        
        self.point.thumbnail.latitudeValue = self.thumbnail_latitude;
        self.point.thumbnail.longitudeValue = self.thumbnail_longitude;
        self.point.thumbnail.imageData = self.thumbnail_imgData;

        [point markAsModified];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _showGPSAccuracyForLocation:(CLLocation *)loc {
    
    if(loc) {
        self.fGpsAccuracy.text = [NSString stringWithFormat:@"GPS accuracy: %0.0f m", loc.horizontalAccuracy];
    } else {
        self.fGpsAccuracy.text = @"GPS accuracy: UNKNOWN";
    }
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _showAndStoreLatitude:(double)lat longitude:(double)lng {
    
    // Solo actua si hay cambios en los valores
    if(self.latitude==lat && self.longitude==lng) {
        return;
    }
    
    self.latitude = lat;
    self.longitude = lng;
    self.fPointLatLng.text = [NSString stringWithFormat:@"Lat:\t%0.06f\nLng:\t%0.06f", lat, lng];
    
    // Ajusta la imagen del thumbnail segun se cambien la posicion
    if(self.thumbnail_imgData == nil ||
       self.thumbnail_latitude != lat ||
       self.thumbnail_longitude != lng) {
        
        [self.fPositionDot  setHidden:TRUE];
        
        //if(!self.thumbnail_imgData)
        {
            self.fMapThumbnail.image = [UIImage imageNamed:@"staticMapNone2.png"];
        }
        
        [self.fThumbnailSpinner setHidden:FALSE];
        [self.fThumbnailSpinner startAnimating];
        
        // Cancela el ticket anterior, si lo hubiese
        [self.ticket cancelNotification];
        
        // Abre un nuevo ticket
        self.ticket = [self.point.thumbnail asyncUpdateLatitude:lat
                                                      longitude:lng
                                                       callback:^void (double lat, double lng, NSData *imageData) {
                                                           
                                                           if(imageData!=nil) {
                                                               self.thumbnail_latitude = lat;
                                                               self.thumbnail_longitude = lng;
                                                               self.thumbnail_imgData = imageData;
                                                           }
                                                           
                                                           [self.fThumbnailSpinner setHidden:TRUE];
                                                           [self.fThumbnailSpinner stopAnimating];
                                                           if(self.thumbnail_imgData) {
                                                               self.fMapThumbnail.image = [[UIImage alloc] initWithData:self.thumbnail_imgData];
                                                               [self.fPositionDot  setHidden:FALSE];
                                                           }
                                                       }];
        
    } else {
        
        self.fMapThumbnail.image = [[UIImage alloc] initWithData:self.thumbnail_imgData];
        [self.fPositionDot  setHidden:FALSE];
        
    }
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) _tbItemsForEditingOthers {
    return nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _enableFieldsForEditing {
    
    //self.fName.enabled = YES;
    //self.fSummary.editable = YES;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _disableFieldsFromEditing {
    
    //self.fName.enabled = NO;
    //self.fSummary.editable = NO;
}



@end

