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

#import "MMapThumbnail.h"
#import "NSManagedObjectContext+Utils.h"

#import "OpenInActionSheetViewController.h"
#import "IconEditorViewController.h"
#import "LatLngEditorViewController.h"
#import "CategorySelectorViewController.h"
#import "VisualMapEditorViewController.h"
#import "MPointMapAnnotation.h"

#import "ScrollableToolbar.h"

#import "UIView+FirstResponder.h"
#import "ImageManager.h"
#import "NSString+JavaStr.h"
#import "UIPlaceHolderTextView.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define BTN_ID_OPEN_IN             4001
#define BTN_ID_VIEW_IN_MAP         4002

#define BTN_ID_KEYBOARD            5001
#define BTN_ID_GPS                 5002
#define BTN_ID_IN_MAP              5003




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface PointEditorViewController() <CLLocationManagerDelegate,
                                        IconEditorDelegate, LatLngEditorDelegate>


@property (nonatomic, assign) IBOutlet UIImageView              *fIconImage;
@property (nonatomic, assign) IBOutlet UITextField              *fName;
@property (nonatomic, assign) IBOutlet UIImageView              *fMapThumbnail;
@property (nonatomic, assign) IBOutlet UILabel                  *fPointLatLng;
@property (nonatomic, assign) IBOutlet UILabel                  *fGpsAccuracy;
@property (nonatomic, assign) IBOutlet UIImageView              *fPositionDot;
@property (nonatomic, assign) IBOutlet UIActivityIndicatorView  *fThumbnailSpinner;
@property (nonatomic, assign) IBOutlet UIPlaceHolderTextView    *fDescription;
@property (nonatomic, assign) IBOutlet UILabel                  *fExtraInfo;
@property (nonatomic, assign) IBOutlet UIView                   *vOtherThings;
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
+ (PointEditorViewController *) editorWithNewPointInContext:(NSManagedObjectContext *)moContext
                                              associatedMap:(MMap *)map
                                         associatedCategory:(MCategory *)category {
    
    
    // Crea un contexto hijo en el que crea una entidad vacia que empezara a editar
    NSManagedObjectContext *childContext = moContext.childContext;
    MMap *copiedMap = (MMap *)[childContext objectWithID:map.objectID];
    MPoint *newPoint = [MPoint emptyPointWithName:@"" inMap:copiedMap];
    
    // Si se ha especificado alguna categoria de entrada la asocia al punto
    if(category!=nil) {
        MCategory *copiedCategory = (MCategory *)[childContext objectWithID:category.objectID];
        [newPoint addToCategory:copiedCategory];
    }
    
    // Crea el editor desde el NIB y lo inicializa con la entidad (y contexto) especificada
    PointEditorViewController *me = [PointEditorViewController editorWithPoint:newPoint moContext:childContext];
    me.wasNewAdded = YES;
    
    // Retorna el editor sobre la entidad recien creada comenzando en modo de edicion
    return me;
}


//---------------------------------------------------------------------------------------------------------------------
+ (PointEditorViewController *) editorWithPoint:(MPoint *)point moContext:(NSManagedObjectContext *)moContext {


    // Crea el editor desde el NIB y lo inicializa con la entidad (y contexto) especificada
   PointEditorViewController *me = [[PointEditorViewController alloc] initWithNibName:@"PointEditorViewController" bundle:nil];
    [me initWithEntity:point moContext:point.managedObjectContext];
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

    [super viewDidLoad];

    
    // Inicializa la geolocalizacion
    self.locMgr = [[CLLocationManager alloc] init];
    self.locMgr.delegate = self;
    self.locMgr.desiredAccuracy = kCLLocationAccuracyBestForNavigation; // En metros
    self.locMgr.distanceFilter = 5; // En metros
    
    
    // Establece el color de fondo del editor de texto para la descripcion
    UIImage *bgEditorImg = [[UIImage imageNamed:@"shadowedBox"] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6) resizingMode:UIImageResizingModeStretch];
    UIImageView *bgImgView3 = [[UIImageView alloc] initWithFrame:self.fDescription.frame];
    bgImgView3.image = bgEditorImg;
    [self.fDescription.superview insertSubview:bgImgView3 belowSubview:self.fDescription];
    self.fDescription.backgroundColor = [UIColor clearColor];
    self.fDescription.placeholder = @"Descripion goes here";

    
    // Carga la imagen de fondo de las diferentes secciones
    UIImage *bgSectionViewImg = [[UIImage imageNamed:@"shadowedBoxPico"] resizableImageWithCapInsets:UIEdgeInsetsMake(52, 6, 6, 6) resizingMode:UIImageResizingModeStretch];

    // Establece el fondo para datos de LOCALIZACION
    CGSize viewSize2 = self.vLocationSection.frame.size;
    UIImageView *bgImgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, viewSize2.width, viewSize2.height)];
    bgImgView2.image = bgSectionViewImg;
    [self.vLocationSection insertSubview:bgImgView2 atIndex:0];
    self.vLocationSection.backgroundColor = [UIColor clearColor];

    [self.fThumbnailSpinner setHidden:TRUE];
    [self.fThumbnailSpinner stopAnimating];
    [self.fPositionDot  setHidden:FALSE];

}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    
    // Para el uso del GPS
    [self.locMgr stopUpdatingLocation];
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
#pragma mark <IconEditorDelegate, LatLngEditorDelegate> protocol methods
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




// =====================================================================================================================
#pragma mark -
#pragma mark <CoreLocationControllerDelegate> protocol methods
// ---------------------------------------------------------------------------------------------------------------------
// Our location updates are sent here
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

    if(newLocation!=nil) {
        
        // Actualiza la información
        [self _showGPSAccuracyForLocation:newLocation];
        [self _showAndStoreLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
        
        // Si ya tenemos una posición con suficiente precisión, para el GPS
        if(newLocation!=nil && newLocation.horizontalAccuracy<=10) {
            [self.locMgr stopUpdatingLocation];
        }
    }
    
}

// ---------------------------------------------------------------------------------------------------------------------
// Any errors are sent here
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    self.fGpsAccuracy.text = @"GPS accuracy: UNKNOWN";
}



//=====================================================================================================================
#pragma mark -
#pragma mark BIAction methods
//---------------------------------------------------------------------------------------------------------------------
- (IBAction)iconImageTapAction:(UITapGestureRecognizer *)sender {
    
    if(sender.state == UIGestureRecognizerStateEnded) {
        
        // Retira, si estaba, el teclado
        [self.view findFirstResponderAndResign];
        
        // Muestra el editor de iconos
        [IconEditorViewController startEditingIcon:self.iconHREF delegate:self];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)vCategoriesTapAction:(UITapGestureRecognizer *)sender {
    
    if(sender.state == UIGestureRecognizerStateEnded) {

        // Retira, si estaba, el teclado
        [self.view findFirstResponderAndResign];
        
        // Muestra el editor de categorias
        CategorySelectorViewController *editor = [CategorySelectorViewController categoriesSelectorInContext:self.moContext
                                                                                                 selectedMap:self.point.map
                                                                                         currentSelectedCats:self.point.categories.allObjects
                                                                                              multiSelection:YES];
        [editor showModalWithController:self closeCallback:^(NSArray *selectedCategories) {
            [self.point replaceCategories:selectedCategories];
            [self _createTagsViewContent:self.vCategoriesSection categories:self.point.categories nextView:self.vOtherThings];
        }];
    }
}


// ---------------------------------------------------------------------------------------------------------------------
- (void) _btnOpenIn:(id)sender {
    [OpenInActionSheetViewController showOpenInActionSheetWithController:self point:self.point];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _btnLocationGPSClicked:(id)sender {
    
    [self.view findFirstResponderAndResign];
    [self.locMgr startUpdatingLocation];
    //[self locationManager:self.locMgr didUpdateToLocation:self.locMgr.location fromLocation:nil];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _btnLocationEditorClicked:(id)sender {
    
    [self.view findFirstResponderAndResign];
    [self.locMgr stopUpdatingLocation];
    [LatLngEditorViewController startEditingLat:self.latitude Lng:self.longitude delegate:self];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _btnLocationMapClicked:(UIButton *)sender {
    
    [self.view findFirstResponderAndResign];
    [self.locMgr stopUpdatingLocation];

    CLLocationCoordinate2D coord = {.latitude = self.latitude, .longitude = self.longitude };
    UIImage *image = [ImageManager iconDataForHREF:self.iconHREF].image;
    NSString *title = self.fName.text;

    [VisualMapEditorViewController editCoordinates:coord title:title image:image controller:self closeCallback:^(CLLocationCoordinate2D coord) {
        [self _showAndStoreLatitude:coord.latitude longitude:coord.longitude];
    }];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _btnShowInMapClicked:(UIButton *)sender {
    
    // Los muestra en el mapa
    [VisualMapEditorViewController showPointsWithNoEditing:[NSArray arrayWithObject:self.point] controller:self];
}



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (UIModalTransitionStyle) _editorTransitionStyle {
    return UIModalTransitionStyleCrossDissolve;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSString *) _editorTitle {
    return @"Point Information";
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _nullifyEditor {
    
    [super _nullifyEditor];
    self.ticket = nil;
    self.thumbnail_imgData = nil;
    self.iconHREF = nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) _validateFields {
    
    self.fName.text = [self.fName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(self.fName.text.length == 0) {
        return @"Name can't be empty";
    }
    return nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _setImageFieldFromHREF:(NSString *)iconHREF {

    self.iconHREF = iconHREF;
    IconData *icon = [ImageManager iconDataForHREF:self.iconHREF];
    self.fIconImage.image = icon.image;
}


//---------------------------------------------------------------------------------------------------------------------
- (void) _setFieldValuesFromEntity {
    
    self.fName.text = self.point.name;
    
    [self _createTagsViewContent:self.vCategoriesSection categories:self.point.categories nextView:self.vOtherThings];
    
    [self _setImageFieldFromHREF:self.point.iconHREF];

    [self _showGPSAccuracyForLocation:self.locMgr.location];
    
    self.thumbnail_latitude = self.point.thumbnail.latitudeValue;
    self.thumbnail_longitude = self.point.thumbnail.longitudeValue;
    self.thumbnail_imgData = self.point.thumbnail.imageData;
    [self _showAndStoreLatitude:self.point.latitudeValue longitude:self.point.longitudeValue];
    
    self.fDescription.text = self.point.descr;
    
    self.fExtraInfo.text = [NSString stringWithFormat:@"Published:\t%@\nUpdated:\t%@\nETAG:\t%@",
                            [MBaseEntity stringFromDate:self.point.creationTime],
                            [MBaseEntity stringFromDate:self.point.updateTime],
                            self.point.etag];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _setEntityFromFieldValues {

    
    if(self.point) {
        
        self.point.name = self.fName.text;
        
        self.point.descr = self.fDescription.text;
        self.point.iconHREF = self.iconHREF;
        [self.point setLatitude:self.latitude longitude:self.longitude];
        
        
        self.point.thumbnail.latitudeValue = self.thumbnail_latitude;
        self.point.thumbnail.longitudeValue = self.thumbnail_longitude;
        self.point.thumbnail.imageData = self.thumbnail_imgData;

        [self.point markAsModified];
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
                                                      moContext:self.moContext
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
- (NSArray *) _tbItemsDefaultOthers {
    NSArray *items = [NSArray arrayWithObjects:
                      [STBItem itemWithTitle:@"Open In" image:[UIImage imageNamed:@"btn-open-in"] tagID:BTN_ID_OPEN_IN target:self action:@selector(_btnOpenIn:)],
                      [STBItem itemWithTitle:@"In Map" image:[UIImage imageNamed:@"btn-map"] tagID:BTN_ID_VIEW_IN_MAP target:self action:@selector(_btnShowInMapClicked:)],
                      nil];
    
    return items;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) _tbItemsForEditingOthers {
    NSArray *items = [NSArray arrayWithObjects:
                      [STBItem itemWithTitle:@"GPS" image:[UIImage imageNamed:@"btn-GPSLocation"] tagID:BTN_ID_GPS target:self action:@selector(_btnLocationGPSClicked:)],
                      [STBItem itemWithTitle:@"In Map" image:[UIImage imageNamed:@"btn-map2"] tagID:BTN_ID_IN_MAP target:self action:@selector(_btnLocationMapClicked:)],
                      [STBItem itemWithTitle:@"Manual" image:[UIImage imageNamed:@"btn-keyboard"] tagID:BTN_ID_KEYBOARD target:self action:@selector(_btnLocationEditorClicked:)],
                      nil];

    return items;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _enableFieldsForEditing {
    
    self.fName.enabled = YES;
    self.fDescription.editable = YES;
    ((UIGestureRecognizer *)self.fIconImage.gestureRecognizers[0]).enabled = YES;
    ((UIGestureRecognizer *)self.vCategoriesSection.gestureRecognizers[0]).enabled = YES;
    
    // Rota la imagen con el icono para indicar que esditable
    [self _rotateView:self.fIconImage];
    [self _rotateView:self.vCategoriesSection];

}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _disableFieldsFromEditing {
    
    self.fName.enabled = NO;
    self.fDescription.editable = NO;
    ((UIGestureRecognizer *)self.fIconImage.gestureRecognizers[0]).enabled = NO;
    ((UIGestureRecognizer *)self.vCategoriesSection.gestureRecognizers[0]).enabled = NO;
}






@end

