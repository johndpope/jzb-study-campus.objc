//
//  POIEditorViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __POIEditorViewController__IMPL__
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import "POIEditorViewController.h"
#import "BaseCoreDataService.h"
#import "MPoint.h"
#import "MMap.h"
#import "MIcon.h"
#import "Util_Macros.h"





//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
typedef enum LocationEditingStateTypes {
    ST_NONE, ST_LAT, ST_LNG
} LocationEditingState;



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface POIEditorViewController () <UITextFieldDelegate, CLLocationManagerDelegate>


@property (nonatomic, assign) IBOutlet UIBarButtonItem* filterButtonItem;

@property (nonatomic, assign) IBOutlet UITextField *txtFieldHidden;
@property (nonatomic, assign) IBOutlet UIImageView *locationImage;
@property (nonatomic, assign) IBOutlet UILabel *locationLabel;
@property (nonatomic, assign) IBOutlet UILabel *gpsAccuracyLabel;

@property (nonatomic, strong) IBOutlet UIView *locationInputAccesoryView;
@property (nonatomic, assign) IBOutlet UITextField *aivTextField;
@property (nonatomic, assign) IBOutlet UILabel *aivLabel;
@property (nonatomic, assign) LocationEditingState locationEdidingState;

@property (nonatomic, assign) double gpsAccuracyValue;



@property (nonatomic, strong) CLLocationManager *locationManager;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation POIEditorViewController


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------


//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Inicializa la geolocalizacion
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation; // En metros
    self.locationManager.distanceFilter = 5; // En metros

    // Do any additional setup after loading the view from its nib
    if(self.moContext==nil) {
        self.moContext = BaseCoreDataService.moContext;
    }
    if(self.map==nil) {
        self.map = [MMap emptyMapWithName:@"new map" inContext:self.moContext];
    }
    if(self.point==nil) {
        self.point = [MPoint emptyPointWithName:@"" inMap:self.map];
    }
    self.locationEdidingState = ST_NONE;
    

    self.gpsAccuracyValue = -1;
    [self.point setLatitude:50.787134 longitude:-73.950817];
    [self _showLocationAndAccuracy];

    [self _crateTagLabels];
}


//---------------------------------------------------------------------------------------------------------------------
- (void) _crateTagLabels {
    
    //    NSArray *texts = @[@"Zona Norte / Z.N Oporto / Oporto",@"Tutorial",@"Tutorial 3",@"Tutor 4",@"Tutorial 5"];
    NSArray *texts = @[@"Oporto",@"Tutorial",@"Tutorial 3",@"Tutor 4",@"Tutorial 5",@"otro mas",@"kaka",@"adios"];
    
    CGPoint origin = (CGPoint){10.0, 329.0};
    CGPoint offset = (CGPoint){0.0, 0.0};
    for(NSString *text in texts) {
        UILabel *lbl = [self _createTagLabelWithText:text origin:origin offset:&offset isActive:TRUE];
        if(!lbl)  {
            lbl = [self _createTagLabelMoreAtOrigin:origin offset:offset];
            [self.view addSubview:lbl];
            break;
        } else {
            [self.view addSubview:lbl];
        }
    }
    //UILabel *lbl = [self _createTagLabelWithText:@"Tag" origin:origin offset:&offset isActive:FALSE];
    //[self.view addSubview:lbl];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (UILabel *) _createTagLabelWithText:(NSString *)text origin:(CGPoint)origin offset:(CGPoint *)offset isActive:(BOOL)isActive {
    
    UIFont *font = [UIFont boldSystemFontOfSize:12.0f];
    UIColor *activeTagColor = [UIColor colorWithRed:93.0/255.0 green:126.0/255.0 blue:152.0/255.0 alpha:1.0];
    UIColor *inactiveTagcolor = [UIColor colorWithRed:218.0/255.0 green:222.0/255.0 blue:226.0/255.0 alpha:1.0];
    
    NSAttributedString *attributedText =[[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: font}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){CGFLOAT_MAX, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGFloat width  = 28+ceilf(rect.size.width);
    width = MAX(48, width);
    width = MIN(268, width);

    if(offset->y>=1*(26.0 + 6.0) && origin.x+offset->x+width>=320-10-32-36) {
        return nil;
    }
    
    if(origin.x+offset->x+width>=320-10-32) {
        offset->x = 0.0;
        offset->y += 26.0 + 6.0;
    }
    CGRect lblRect = (CGRect){origin.x+offset->x, origin.y+offset->y, width, 26};


    offset->x += 6 + width;

    
    UILabel *lbl = [[UILabel alloc] initWithFrame:lblRect];
    lbl.text = text;
    lbl.font = font;
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.numberOfLines = 0;
    //lbl.textColor = [UIColor whiteColor];
    //lbl.backgroundColor = isActive?activeTagColor:inactiveTagcolor;
    
    lbl.textColor = isActive?activeTagColor:inactiveTagcolor;
    lbl.layer.borderColor = (isActive?activeTagColor:inactiveTagcolor).CGColor;
    lbl.layer.borderWidth = 1.0;
    
    lbl.layer.cornerRadius = 26.0 / 2;
    return  lbl;
}

//---------------------------------------------------------------------------------------------------------------------
- (UILabel *) _createTagLabelMoreAtOrigin:(CGPoint)origin offset:(CGPoint)offset {
    
    UIFont *font = [UIFont boldSystemFontOfSize:16.0f];
    UIColor *tagColor = [UIColor colorWithRed:254.0/255.0 green:92.0/255.0 blue:92.0/255.0 alpha:1.0];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:(CGRect){origin.x+offset.x, origin.y+offset.y+5, 30, 16}];
    lbl.text = @"···";
    lbl.font = font;
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.numberOfLines = 0;
    lbl.textColor = [UIColor whiteColor];
    lbl.backgroundColor = tagColor;
    lbl.layer.cornerRadius = 16.0 / 2;
    return  lbl;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    
    // Para el uso del GPS
    [self _stopLocationActivity];
}


//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//---------------------------------------------------------------------------------------------------------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"pepe");
}


//=====================================================================================================================
#pragma mark -
#pragma mark <IBAction> outlet methods
//---------------------------------------------------------------------------------------------------------------------
- (UIImage *)image:(UIImage *)img withBurnTint:(UIColor *)color
{
    // lets tint the icon - assumes your icons are black
    UIGraphicsBeginImageContextWithOptions(img.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    
    // draw alpha-mask
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, rect, img.CGImage);
    
    // draw tint color, preserving alpha values of original image
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    [color setFill];
    CGContextFillRect(context, rect);
    
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return coloredImage;
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _imageGlow {

    UIImage *baseImg = [UIImage imageNamed:@"BlueMapMarker.png"];
    NSMutableArray *imgs = [NSMutableArray array];
    
    double alphaInc = 1.0/10.0;
    for(double alpha=1.0;alpha>=0.2;alpha-=alphaInc) {
        [imgs addObject:[self image:baseImg withBurnTint:[UIColor colorWithRed:1.000 green:0.000 blue:0.000 alpha:alpha]]];
    }
    for(double alpha=0.2;alpha<=1.0;alpha+=alphaInc) {
        [imgs addObject:[self image:baseImg withBurnTint:[UIColor colorWithRed:1.000 green:0.000 blue:0.000 alpha:alpha]]];
    }

    self.locationImage.animationImages = imgs;
    self.locationImage.animationDuration = 1.6;
    self.locationImage.animationRepeatCount = 0;
    [self.locationImage startAnimating];
}


// ---------------------------------------------------------------------------------------------------------------------
- (IBAction)iavGpsAction:(UIButton *)sender {
    [self _startLocationActivity];
}

// ---------------------------------------------------------------------------------------------------------------------
- (IBAction)iavMapAction:(UIButton *)sender {
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)locationLabelTapped:(UITapGestureRecognizer *)sender {
    

    if(self.locationImage.isAnimating) {
        [self _stopLocationActivity];
        return;
    }
    
    if(self.locationEdidingState == ST_NONE) {
        
        self.locationEdidingState = ST_LAT;
        self.aivLabel.text=@"Lat:";
        if(self.point.latitudeValue==0) {
            self.aivTextField.text =@"0";
        } else {
            self.aivTextField.text = [NSString stringWithFormat:@"%1.6f",self.point.latitudeValue];
        }
        [self.txtFieldHidden setInputAccessoryView:self.locationInputAccesoryView];
        [self.txtFieldHidden becomeFirstResponder];
        [self.aivTextField setReturnKeyType:UIReturnKeyNext];
        [self.aivTextField becomeFirstResponder];
    }
    
}


// =====================================================================================================================
#pragma mark -
#pragma mark <CoreLocationControllerDelegate> protocol methods
// ---------------------------------------------------------------------------------------------------------------------
// Our location updates are sent here
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    if(newLocation!=nil) {
        
        // Actualiza la información
        self.gpsAccuracyValue = newLocation.horizontalAccuracy;
        [self.point setLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
        [self _showLocationAndAccuracy];
        
        // Si ya tenemos una posición con suficiente precisión, para el GPS
        if(newLocation.horizontalAccuracy<=5) {
            [self _stopLocationActivity];
        }
    }
    
}

// ---------------------------------------------------------------------------------------------------------------------
// Any errors are sent here
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    self.gpsAccuracyValue = -1.0;
    [self _showLocationAndAccuracy];
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UITextFieldDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    return TRUE;
}

//---------------------------------------------------------------------------------------------------------------------
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if(self.locationEdidingState == ST_LAT) {
        self.locationEdidingState = ST_LNG;
        [self.point setLatitude:[self.aivTextField.text doubleValue] longitude:self.point.longitudeValue];
        self.aivLabel.text=@"Lng:";
        if(self.point.longitudeValue==0) {
            self.aivTextField.text =@"0";
        } else {
            self.aivTextField.text = [NSString stringWithFormat:@"%1.6f",self.point.longitudeValue];
        }
        [self.aivTextField setReturnKeyType:UIReturnKeyDone];
        [self.aivTextField reloadInputViews];
    } else {
        self.locationEdidingState = ST_NONE;
        [self.point setLatitude:self.point.latitudeValue longitude:[self.aivTextField.text doubleValue]];
        [self.aivTextField resignFirstResponder];
        [self.txtFieldHidden resignFirstResponder];
    }

    [self _showLocationAndAccuracy];

    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"fopfipo");
    CGFloat fixedWidth = textField.frame.size.width;
    CGSize newSize = [textField sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textField.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, 20), textField.frame.size.height);
    textField.frame = newFrame;
}




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) _startLocationActivity {
    
    [self.locationManager startUpdatingLocation];
    self.locationEdidingState = ST_NONE;
    [self.aivTextField resignFirstResponder];
    [self.txtFieldHidden resignFirstResponder];
    [self _imageGlow];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _stopLocationActivity {
    
    [self.locationManager stopUpdatingLocation];
    [self.locationImage stopAnimating];
    self.locationImage.image = [UIImage imageNamed:@"BlueMapMarker.png"];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _showLocationAndAccuracy {
    

    NSString *strLat = [[NSString stringWithFormat:@"%1.6lf",self.point.latitudeValue] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"0"]];
    NSString *strLng = [[NSString stringWithFormat:@"%1.6lf",self.point.longitudeValue] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"0"]];
    self.locationLabel.text = [NSString stringWithFormat:@"%@, %@",strLat,strLng];

    if(self.gpsAccuracyValue>=0) {
        self.gpsAccuracyLabel.text = [NSString stringWithFormat:@"GPS accuracy: %0.0f m", self.gpsAccuracyValue];
    } else {
        self.gpsAccuracyLabel.text = @"GPS accuracy: UNKNOWN";
    }
    
}



@end
