//
//  PointEditorViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __PointEditorViewController__IMPL__

#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

#import "PointEditorViewController.h"
#import "IconEditorViewController.h"
#import "VisualMapEditorViewController.h"
#import "LatLngEditorViewController.h"
#import "UIView+FirstResponder.h"
#import "ImageManager.h"
#import "NSString+JavaStr.h"
#import "MMap.h"
#import "MCategory.h"
#import "MMapThumbnail.h"
#import "MyMKPointAnnotation.h"


#import "GMTItem.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface PointEditorViewController() <UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate,
                                        IconEditorDelegate, LatLngEditorDelegate, VisualMapEditorDelegate>


@property (nonatomic, assign) IBOutlet UIImageView *iconImageField;
@property (nonatomic, assign) IBOutlet UITextField *nameField;
@property (nonatomic, assign) IBOutlet UITextField *pathField;
@property (nonatomic, assign) IBOutlet UILabel *pointLatLng;
@property (nonatomic, assign) IBOutlet UILabel *gpsAccuracy;
@property (nonatomic, assign) IBOutlet UIImageView *mapThumbnail;
@property (nonatomic, assign) IBOutlet UIImageView *positionDot;
@property (nonatomic, assign) IBOutlet UIActivityIndicatorView *thumbnailSpinner;
@property (nonatomic, assign) IBOutlet UITextView *descrField;
@property (nonatomic, assign) IBOutlet UILabel *extraInfo;

@property (nonatomic, assign) IBOutlet UIScrollView *contentScrollView;
@property (nonatomic, assign) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, strong) IBOutlet UIView *kbToolView;

@property (nonatomic, assign) UIViewController<EntityEditorDelegate> *delegate;
@property (nonatomic, strong) NSManagedObjectContext *moContext;
@property (nonatomic, strong) NSString *iconBaseHREF;

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
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
+ (UIViewController<EntityEditorViewController> *) startEditingPoint:(MPoint *)Point
                                                               delegate:(UIViewController<EntityEditorDelegate> *)delegate {

    if(Point!=nil && delegate!=nil) {
        PointEditorViewController *me = [[PointEditorViewController alloc] initWithNibName:@"PointEditorViewController" bundle:nil];
        me.delegate = delegate;
        me.Point = Point;
        me.moContext = Point.managedObjectContext; // La referencia es weak y se pierde
        me.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [delegate presentViewController:me animated:YES completion:nil];
        return me;
    } else {
        DDLogVerbose(@"Warning: PointEditorViewController-startEditingMap called with nil Point or Delegate");
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

    // Le pone un borde al editor de la descripción
    self.descrField.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
    self.descrField.layer.borderWidth = 2.0;
    self.descrField.layer.cornerRadius = 10.0;
    self.descrField.clipsToBounds = YES;
    
    
    // Se prepara para editar con el teclado adecuadamente
    UIView *lastControl = self.extraInfo;
    self.contentScrollView.contentSize = CGSizeMake(self.contentScrollView.frame.size.width,
                                                    lastControl.frame.origin.y + lastControl.frame.size.height);
    
    
    self.kbToolView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"kbToolBar.png"]];

    // Botones de Save & Cancel
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                         target:self
                                                                                         action:@selector(_btnCloseCancel:)];

    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                         target:self
                                                                                         action:@selector(_btnCloseSave:)];

    self.navigationBar.topItem.leftBarButtonItem = cancelBarButtonItem;
    self.navigationBar.topItem.rightBarButtonItem = saveBarButtonItem;
    
    
    self.locMgr = [[CLLocationManager alloc] init];
    self.locMgr.delegate = self;
    self.locMgr.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; // En metros
    self.locMgr.distanceFilter = kCLDistanceFilterNone; // En metros
    self.usingGPSLocation = FALSE;
    self.longitude = self.latitude = HUGE_VAL;
    
    
    // Actualiza los campos desde la entidad a editar
    [self _setFieldValuesFromEntity];

}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated {
    [self _rotateImageField];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated {
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated {
    
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return TRUE;
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




//=====================================================================================================================
#pragma mark -
#pragma mark <UITextFieldDelegate, UITextViewDelegate> and Keyboard Notification methods
//---------------------------------------------------------------------------------------------------------------------
-(void)keyboardWillShow:(NSNotification*)notification {
    
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    CGFloat maxScrollHeight = self.view.frame.size.height - self.navigationBar.frame.size.height;
    
    self.contentScrollView.frame = CGRectMake(self.contentScrollView.frame.origin.x,
                                              self.contentScrollView.frame.origin.y,
                                              self.contentScrollView.contentSize.width,
                                              maxScrollHeight - keyboardSize.height);
}

//---------------------------------------------------------------------------------------------------------------------
-(void)keyboardWillHide:(NSNotification*)notification {
    
    CGFloat maxScrollHeight = self.view.frame.size.height - self.navigationBar.frame.size.height;

    self.contentScrollView.frame = CGRectMake(self.contentScrollView.frame.origin.x,
                                              self.contentScrollView.frame.origin.y,
                                              self.contentScrollView.contentSize.width,
                                              maxScrollHeight);
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)kbToolBarOKAction:(UIButton *)sender {
    [self.view findFirstResponderAndResign];
}

//---------------------------------------------------------------------------------------------------------------------
-(void)textFieldDidBeginEditing:(UITextField *)sender {
    
    [self.contentScrollView scrollRectToVisible:sender.frame animated:YES];
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)sender {
    
    [sender resignFirstResponder];
    return YES;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) textViewShouldBeginEditing:(UITextView *)sender {
    [sender setInputAccessoryView:self.kbToolView];
    return YES;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)textViewDidBeginEditing:(UITextView *)sender {

    [self.contentScrollView scrollRectToVisible:sender.frame animated:YES];
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UITextFieldDelegate, UITextViewDelegate> and Keyboard Notification methods
//---------------------------------------------------------------------------------------------------------------------
- (BOOL) closeIconEditor:(IconEditorViewController *)senderEditor {
    [self _setImageFieldFromHREF:senderEditor.iconBaseHREF];
    return true;
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
        [IconEditorViewController startEditingIcon:self.iconBaseHREF delegate:self];
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
- (BOOL) closeLatLngEditor:(LatLngEditorViewController *)senderEditor Lat:(CGFloat)latitude Lng:(CGFloat)longitude {
    
    [self _showAndStoreLatitude:latitude longitude:longitude];
    return TRUE;
}

// ---------------------------------------------------------------------------------------------------------------------
- (IBAction)btnLocationMapClicked:(UIButton *)sender {
    
    [self.view findFirstResponderAndResign];
    self.usingGPSLocation = FALSE;
    [self.locMgr stopUpdatingLocation];
    
    
    CLLocationCoordinate2D pinCoordinates = {.latitude = self.latitude, .longitude = self.longitude};
    MyMKPointAnnotation *pin = [[MyMKPointAnnotation alloc] init];
    pin.title = self.nameField.text;
    pin.subtitle = @"pepe";
    pin.coordinate = pinCoordinates;
    pin.iconHREF = self.iconBaseHREF;
    NSArray *annotations = [NSArray arrayWithObject:pin];
    
    [VisualMapEditorViewController startEditingAnnotations:annotations delegate:self];
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


//=====================================================================================================================
#pragma mark -
#pragma mark Getter & Setter methods
//---------------------------------------------------------------------------------------------------------------------




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------




//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _dismissEditor {
    
    [self.view findFirstResponderAndResign];
    [self dismissViewControllerAnimated:YES completion:nil];

    // Set properties to nil
    self.point = nil;
    self.delegate = nil;
    self.moContext = nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _btnCloseSave:(id)sender {

    [self _setEntityFromFieldValues];
    if([self.delegate editorSaveChanges:self modifiedEntity:self.point]) {
        [self _dismissEditor];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _btnCloseCancel:(id)sender {
    
    if([self.delegate editorCancelChanges:self]) {
        [self _dismissEditor];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _rotateImageField {
    
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    rotate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotate.fromValue = [NSNumber numberWithFloat:0];
    rotate.toValue = [NSNumber numberWithFloat:2*M_PI];
    rotate.duration = 0.7f;
    rotate.repeatCount = 1;
    [self.iconImageField.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
    [self.iconImageField.layer addAnimation:rotate forKey:@"trans_rotation"];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _setImageFieldFromHREF:(NSString *)iconHREF {
    
    self.iconBaseHREF = iconHREF;
    IconData *icon = [ImageManager iconDataForHREF:iconHREF];
    self.iconImageField.image = icon.image;
}


//---------------------------------------------------------------------------------------------------------------------
- (void) _setFieldValuesFromEntity {
    
    self.nameField.text = self.point.name;
    self.pathField.text = self.point.category.fullName;
    [self _setImageFieldFromHREF:self.point.category.iconBaseHREF];

    [self _showGPSAccuracyForLocation:self.locMgr.location];

    self.thumbnail_latitude = self.point.thumbnail.latitudeValue;
    self.thumbnail_longitude = self.point.thumbnail.longitudeValue;
    self.thumbnail_imgData = self.point.thumbnail.imageData;
    [self _showAndStoreLatitude:self.point.latitudeValue longitude:self.point.longitudeValue];
    
    self.descrField.text = self.point.descr;
    
    self.extraInfo.text = [NSString stringWithFormat:@"Published:\t%@\nUpdated:\t%@\nETAG:\t%@",
                           [GMTItem stringFromDate:self.point.published_date],
                           [GMTItem stringFromDate:self.point.updated_date],
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
        
        [self.point setLatitude:self.latitude longitude:self.longitude];
        
        self.point.descr = self.descrField.text;
        
        NSString *cleanCatFullName = [self.pathField.text replaceStr:@"&" with:@"%"];
        MCategory *destCat = [MCategory categoryForIconBaseHREF:self.iconBaseHREF
                                                       fullName:cleanCatFullName
                                                      inContext:self.point.managedObjectContext];
        [self.point moveToCategory:destCat];
        
        [self.point updateModifiedMark];
        [self.point.map updateModifiedMark];
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
    if(self.latitude==lat && self.longitude==lng) {
        return;
    }
    
    
    self.latitude = lat;
    self.longitude = lng;
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

