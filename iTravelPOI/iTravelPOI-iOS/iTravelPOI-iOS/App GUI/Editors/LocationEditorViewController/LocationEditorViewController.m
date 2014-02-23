//
//  LocationEditorViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __LocationEditorViewController__IMPL__
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import "LocationEditorViewController.h"
#import "UIImage+Tint.h"
#import "BaseCoreDataService.h"
#import "TagListEditorViewController.h"
#import "IconEditorViewController.h"
#import "UIPlaceHolderTextView.h"
#import "MPoint.h"
#import "MMap.h"
#import "MTag.h"
#import "MIcon.h"
#import "Util_Macros.h"





//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define MIN_PRECISION_TO_STOP_GPS -1

typedef NS_ENUM(NSUInteger, LocationEditingState) {
    LocationEditingStateNone, LocationEditingStateLat, LocationEditingStateLng
};



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface LocationEditorViewController () <TagListEditorViewControllerDelegate, IconEditorViewControllerDelegate,
                                       UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate>


@property (nonatomic, weak) IBOutlet UIButton               *fbtnIcon;
@property (nonatomic, weak) IBOutlet UITextField            *ftxtName;
@property (nonatomic, weak) IBOutlet UILabel                *flblLocationLabel;
@property (nonatomic, weak) IBOutlet UIImageView            *fimgLocationImage;
@property (nonatomic, weak) IBOutlet UILabel                *flblGpsAccuracyLabel;
@property (nonatomic, weak) IBOutlet UIPlaceHolderTextView  *ftxtDescription;
@property (nonatomic, weak) IBOutlet UIView                 *fvTagsView;
@property (nonatomic, weak) IBOutlet UILabel                *flblExtraInfo;

@property (nonatomic, weak) IBOutlet UIBarButtonItem        *navBarSaveButton;

@property (nonatomic, weak)   UIView                        *fieldToScroll;

@property (nonatomic, strong) IBOutlet UIView               *iavView;
@property (nonatomic, weak)   IBOutlet UILabel              *iavLabel;
@property (nonatomic, strong) IBOutlet UITextField          *iavTextField;

@property (nonatomic, assign) LocationEditingState          locationEditingState;
@property (nonatomic, assign) double                        gpsAccuracyValue;
@property (nonatomic, strong) CLLocationManager             *locationManager;


@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation LocationEditorViewController


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) keyboardWillShow {

    [super keyboardWillShow];
    
    if(self.locationEditingState!=LocationEditingStateNone) {
        [self _showInputAccesoryView];
    }
    
    UIScrollView *sv = (UIScrollView *)self.kbContentView.superview;
    [sv scrollRectToVisible:self.fieldToScroll.frame animated:TRUE];

}

//---------------------------------------------------------------------------------------------------------------------
- (void) keyboardDidHide {
    [self _hideInputAccesoryView];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _showInputAccesoryView {
    
    if(self.isKeyboardVisible) {
        
        CGPoint p = [self.view convertPoint:self.keyboardRect.origin fromView:nil];
        frameSetY(self.iavView,p.y-self.iavView.frame.size.height);

        // Le quita un poco mas al ScrollView
        UIScrollView *sv = (UIScrollView *)self.kbContentView.superview;
        sv.contentInset = (UIEdgeInsets){0, 0, self.keyboardRect.size.height+self.iavView.frame.size.height, 0};
        sv.contentSize = self.kbContentView.frame.size;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _hideInputAccesoryView {
    
    if(self.isKeyboardVisible) {
        
        frameSetY(self.iavView,1000);
        
        // Le pone un poco mas al ScrollView
        UIScrollView *sv = (UIScrollView *)self.kbContentView.superview;
        sv.contentInset = (UIEdgeInsets){0, 0, self.keyboardRect.size.height, 0};
        sv.contentSize = self.kbContentView.frame.size;
    }
}





//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        // Inicializa la geolocalizacion
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation; // En metros
        self.locationManager.distanceFilter = 5; // En metros
        self.gpsAccuracyValue = -1;

    }
    return self;
}



//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.ftxtDescription.placeholderText = @"Description goes here";
    self.navBarSaveButton.enabled = FALSE;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // Resetea el valor del estado de edicion de la informacion de localizacion
    self.locationEditingState = LocationEditingStateNone;
    
    // Establece el color dependiendo del tinte
    self.flblLocationLabel.textColor = self.view.tintColor;
    [self _stopImgLocationImageGlowing];
    
        
    // Muestra la informacion
    [self _setFieldsFromEntity];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
    
    // Cancela el uso del GPS y la animacion del icono
    [self _stopLocationActivity];
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//---------------------------------------------------------------------------------------------------------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"PointEditor_to_TagListEditor"]) {
        
        TagListEditorViewController *editor = (TagListEditorViewController *)segue.destinationViewController;
        
        // Propaga el color del tinte
        editor.view.tintColor = self.view.tintColor;

        // Se establece como el delegate
        editor.delegate = self;

        // Consigue el arrays de tags disponibles para los puntos del mapa activo
        NSArray *allPoints = [MPoint allWithMap:self.point.map sortOrder:@[MBaseOrderNone]];
        NSMutableSet *allAvailableTags = [MPoint allNonAutoTagsFromPoints:allPoints];

        // Asigna la informacion al editor
        [editor setContext:self.moContext assignedTags:self.point.directNoAutoTags availableTags:allAvailableTags];
        
    } else if([[segue identifier] isEqualToString:@"PointEditor_to_IconEditor"]) {
        
        IconEditorViewController *iconEditor = (IconEditorViewController *)segue.destinationViewController;
        [iconEditor setIcon:self.point.icon];
        iconEditor.delegate = self;
        
    }
}


//=====================================================================================================================
#pragma mark -
#pragma mark <IBAction> outlet methods
// ---------------------------------------------------------------------------------------------------------------------
- (IBAction)cancelAction:(UIBarButtonItem *)sender {
    
    if([self.delegate respondsToSelector:@selector(pointEdiorCancelPoint:)]) {
        [self.delegate pointEdiorCancelPoint:self];
    }
    [self _dismissEditor];
}

// ---------------------------------------------------------------------------------------------------------------------
- (IBAction)saveAction:(UIBarButtonItem *)sender {
    
    // Indica que hubo a su delegate antes de cerrar
    if([self.delegate respondsToSelector:@selector(pointEdiorSavePoint:)]) {
        [self.delegate pointEdiorSavePoint:self];
    }
    [self _dismissEditor];
}

// ---------------------------------------------------------------------------------------------------------------------
- (IBAction)iavGpsAction:(UIButton *)sender {
    [self.view endEditing:TRUE];
    [self _startLocationActivity];
}

// ---------------------------------------------------------------------------------------------------------------------
- (IBAction)iavMapAction:(UIButton *)sender {
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)locationLabelTapped:(UITapGestureRecognizer *)sender {

    // Si estaba geolocalizando para, sino edita la posicion
    if([self _isLocationActive]) {
        [self _stopLocationActivity];
    } else {
        // Simula haber tocado el campo de texto
        [self.iavTextField becomeFirstResponder];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)tagsViewTapped:(UITapGestureRecognizer *)sender {

    [self _stopLocationActivity];
    [self.view endEditing:TRUE];
    [self performSegueWithIdentifier: @"PointEditor_to_TagListEditor" sender: self];
}



// =====================================================================================================================
#pragma mark -
#pragma mark <TagListEditorViewControllerDelegate> protocol methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) tagListEditor:(TagListEditorViewController *)sender assignedTags:(NSArray *)assignedTags {
    
    // Comprueba si ambos conjuntos de tags son iguales
    NSSet *currentTags = self.point.directNoAutoTags;
    NSSet *newTags = [NSMutableSet setWithArray:assignedTags];
    
    
    NSMutableSet *tagsToRemove = [NSMutableSet setWithSet:currentTags];
    [tagsToRemove minusSet:newTags];

    NSMutableSet *tagsToAdd = [NSMutableSet setWithSet:newTags];
    [tagsToAdd minusSet:currentTags];
    

    for(MTag *tag in tagsToRemove) {
        [tag untagPoint:self.point];
    }

    for(MTag *tag in tagsToAdd) {
        [tag tagPoint:self.point];
    }

    if(tagsToAdd.count>0 || tagsToRemove.count>0) {
        self.navBarSaveButton.enabled = TRUE;
    }
}

// =====================================================================================================================
#pragma mark -
#pragma mark <IconEditorViewControllerDelegate> protocol methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) iconEditorDone:(IconEditorViewController *)sender {

    self.navBarSaveButton.enabled |= [self.point  updateIcon:sender.icon];
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
        self.navBarSaveButton.enabled |= [self.point updateLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
        [self _setLocationAndAccuracyField];
        
        // Si ya tenemos una posición con suficiente precisión, para el GPS
        if(newLocation.horizontalAccuracy<=MIN_PRECISION_TO_STOP_GPS) {
            [self _stopLocationActivity];
        }
    }
    
}

// ---------------------------------------------------------------------------------------------------------------------
// Any errors are sent here
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self _stopLocationActivity];
    self.gpsAccuracyValue = -1.0;
    [self _setLocationAndAccuracyField];
}


//=====================================================================================================================
#pragma mark -
#pragma mark <UITextViewDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {

    self.fieldToScroll = textView;
    
    [self _stopLocationActivity];
    return  TRUE;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    
    self.navBarSaveButton.enabled |= [self.point updateDesc:textView.text];
    return  TRUE;
}




//=====================================================================================================================
#pragma mark -
#pragma mark <UITextFieldDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {

    self.fieldToScroll = textField;

    [self _stopLocationActivity];
    
    if(textField==self.iavTextField) {
        // Establece valores del campo de edicion de la posicion
        self.locationEditingState = LocationEditingStateLat;
        self.iavLabel.text = @"Lat:";
        self.iavTextField.text = (self.point.latitudeValue==0) ? @"0" : [NSString stringWithFormat:@"%1.6f",self.point.latitudeValue];
        [self.iavTextField setReturnKeyType:UIReturnKeyNext];
        [self.iavTextField reloadInputViews];

        // Si el teclado ya estaba visible muestra el campo
        [self _showInputAccesoryView];
        
    }
    
    return TRUE;
}

//---------------------------------------------------------------------------------------------------------------------
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    if(textField == self.iavTextField) {
        self.locationEditingState = LocationEditingStateNone;
        [self _hideInputAccesoryView];
    }
    return TRUE;
}

//---------------------------------------------------------------------------------------------------------------------
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // Si ya estaba editando la localizacion, continua
    if(textField==self.iavTextField) {
        
        if(self.locationEditingState == LocationEditingStateLat) {
            self.navBarSaveButton.enabled |= [self.point updateLatitude:[self.iavTextField.text doubleValue] longitude:self.point.longitudeValue];
            self.locationEditingState = LocationEditingStateLng;
            [self _setLocationAndAccuracyField];
            
            self.iavLabel.text = @"Lng:";
            self.iavTextField.text = (self.point.longitudeValue==0) ? @"0" : [NSString stringWithFormat:@"%1.6f",self.point.longitudeValue];
            [self.iavTextField setReturnKeyType:UIReturnKeyDone];
            [self.iavTextField reloadInputViews];
        } else {
            self.navBarSaveButton.enabled |= [self.point updateLatitude:self.point.latitudeValue longitude:[self.iavTextField.text doubleValue]];
            self.locationEditingState = LocationEditingStateNone;
            [self _setLocationAndAccuracyField];
            [self.view endEditing:TRUE];
        }

    } else if(textField==self.ftxtName) {
        self.navBarSaveButton.enabled |= [self.point updateName:self.ftxtName.text];
        [self.view endEditing:TRUE];
    } else {
        //@TODO: ¿como puede llegar aqui?
    }
    
    return TRUE;
}




//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) _dismissEditor {
    
    [self _stopLocationActivity];
    
    [self dismissViewControllerAnimated:YES completion:^{
        self.navBarSaveButton.enabled = FALSE;
        self.moContext = nil;
        self.point = nil;
        self.map = nil;
    }];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _stopImgLocationImageGlowing {
    [self.fimgLocationImage stopAnimating];
    self.fimgLocationImage.image = [UIImage imageNamed:@"BlueMapMarker" burnTint:self.view.tintColor];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _startImgLocationImageGlowing {
    
    UIImage *baseImg = [UIImage imageNamed:@"BlueMapMarker" burnTint:self.view.tintColor];
    NSMutableArray *imgs = [NSMutableArray array];
    
    double alphaInc = 1.0/20.0;
    for(double alpha=1.0;alpha>=0.5;alpha-=alphaInc) {
        [imgs addObject:[[baseImg scaledToSize:(CGSize){32*alpha,32*alpha} centerInSize:(CGSize){32,32}] burnTintRed:255 green:0 blue:0 alpha:alpha]];
    }
    for(double alpha=0.5;alpha<=1.0;alpha+=alphaInc) {
        [imgs addObject:[[baseImg scaledToSize:(CGSize){32*alpha,32*alpha} centerInSize:(CGSize){32,32}] burnTintRed:255 green:0 blue:0 alpha:alpha]];
    }
    
    self.fimgLocationImage.animationImages = imgs;
    self.fimgLocationImage.animationDuration = 1.6;
    self.fimgLocationImage.animationRepeatCount = 0;
    [self.fimgLocationImage startAnimating];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _startLocationActivity {
    
    [self.locationManager startUpdatingLocation];
    [self _startImgLocationImageGlowing];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _stopLocationActivity {
    
    [self.locationManager stopUpdatingLocation];
    [self _stopImgLocationImageGlowing];
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) _isLocationActive {
    return self.fimgLocationImage.isAnimating;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _setLocationAndAccuracyField {

    NSString *strLat = [[NSString stringWithFormat:@"%1.6lf",self.point.latitudeValue] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"0"]];
    NSString *strLng = [[NSString stringWithFormat:@"%1.6lf",self.point.longitudeValue] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"0"]];
    self.flblLocationLabel.text = [NSString stringWithFormat:@"%@, %@",strLat,strLng];

    if(self.gpsAccuracyValue>=0) {
        self.flblGpsAccuracyLabel.text = [NSString stringWithFormat:@"GPS accuracy: %0.0f m", self.gpsAccuracyValue];
    } else {
        self.flblGpsAccuracyLabel.text = @"GPS accuracy: UNKNOWN";
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (UILabel *) _createTagLabelWithText:(NSString *)text origin:(CGPoint)origin offset:(CGPoint *)offset isEmptyTag:(BOOL)isEmptyTag {
    
    static CGFloat MIN_WIDTH = 48.0;
    static CGFloat LABEL_HEIGHT = 26.0;
    static CGFloat ROUNDED_BORDER_WITH = (26.0/2.0);
    static CGFloat H_SPACE = 6.0;
    static CGFloat V_SPACE = 9.0;
    static CGFloat MAX_X_OFFSET1 = 320.0;    // tamaño de pantalla
    static CGFloat MAX_X_OFFSET2 = 320.0-36; // tamaño de pantalla - ancho de etiqueta "..."
    
    
    UIFont *font = [UIFont boldSystemFontOfSize:12.0f];
    //UIColor *activeTagColor = [UIColor colorWithIntRed:0 intGreen:126 intBlue:247 alpha:1.0];
    UIColor *activeTagColor = self.view.tintColor;
    UIColor *inactiveTagcolor = [UIColor colorWithIntRed:200 intGreen:200 intBlue:200 alpha:1.0];

    // Calcula el tamaño de la etiqueta
    NSAttributedString *attributedText =[[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: font}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){CGFLOAT_MAX, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGFloat width  = 2.0+2.0*ROUNDED_BORDER_WITH+ceilf(rect.size.width);
    width = MAX(MIN_WIDTH, width);
    width = MIN(MAX_X_OFFSET1 - 2*origin.x - H_SPACE, width);
    
    // Si ya es la segunda linea y ya no hay espacio para la etiqueta retorna un NIL
    if(offset->y>=(LABEL_HEIGHT + V_SPACE) && origin.x+offset->x+width>=MAX_X_OFFSET2-origin.x) {
        return nil;
    }
    
    // Calcula la nueva posicion y si debe saltar de linea
    if(origin.x+offset->x+width>=MAX_X_OFFSET1-origin.x) {
        offset->x = 0.0;
        offset->y += LABEL_HEIGHT + V_SPACE;
    }
    CGRect lblRect = (CGRect){origin.x+offset->x, origin.y+offset->y, width, 26};
    
    // Prepara el offset para la proximo offset
    offset->x += H_SPACE + width;
    
    // Crea la etiqueta
    UILabel *lbl = [[UILabel alloc] initWithFrame:lblRect];
    lbl.text = text;
    lbl.font = font;
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.numberOfLines = 0;
    //lbl.textColor = [UIColor whiteColor];
    //lbl.backgroundColor = isActive?activeTagColor:inactiveTagcolor;
    lbl.textColor = isEmptyTag?inactiveTagcolor:activeTagColor;
    lbl.layer.borderColor = (isEmptyTag?inactiveTagcolor:activeTagColor).CGColor;
    lbl.layer.borderWidth = 1.0;
    
    lbl.layer.cornerRadius = LABEL_HEIGHT / 2;
    return  lbl;
}

//---------------------------------------------------------------------------------------------------------------------
- (UILabel *) _createTagLabelMoreAtOrigin:(CGPoint)origin offset:(CGPoint)offset {
    
    UIFont *font = [UIFont boldSystemFontOfSize:16.0f];
    UIColor *tagColor = [[UIColor colorWithIntRed:255 intGreen:55 intBlue:55 alpha:1.0] incrementBrightness:0.2];

    
    // Crea la etiqueta
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

// ---------------------------------------------------------------------------------------------------------------------
- (void) _setTagsField {
    
    // Primero retira todas los tags previos que podria haber
    for(UIView *view in [self.fvTagsView.subviews copy]) {
        if([[view class] isSubclassOfClass:[UILabel class]]) {
            [view removeFromSuperview];
        }
    }
    
    // Punto de comienzo de la creacion de las etiquetas
    CGPoint origin = (CGPoint){10.0, 10.0};
    CGPoint offset = (CGPoint){0.0, 0.0};
    
    // Crea las etiquetas del punto
    NSSet *assignedTags = self.point.directNoAutoTags;
    if(assignedTags.count==0) {
        
        UILabel *lbl = [self _createTagLabelWithText:@"Add Tag" origin:origin offset:&offset isEmptyTag:TRUE];
        [self.fvTagsView addSubview:lbl];
        
    } else {
        for(MTag *tag in self.point.directNoAutoTags) {
            NSString *text = tag.name;
            UILabel *lbl = [self _createTagLabelWithText:text origin:origin offset:&offset isEmptyTag:FALSE];
            if(!lbl)  {
                lbl = [self _createTagLabelMoreAtOrigin:origin offset:offset];
                [self.fvTagsView addSubview:lbl];
                break;
            } else {
                [self.fvTagsView addSubview:lbl];
            }
        }
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _setExtraInfoField {
    
    NSMutableString *extraInfo = [NSMutableString string];
    [extraInfo appendFormat:@"%@\n", [MBase stringFromDate:self.point.tCreation]];
    [extraInfo appendFormat:@"%@\n", [MBase stringFromDate:self.point.tUpdate]];
    [extraInfo appendFormat:@"%@", self.point.etag];
    self.flblExtraInfo.text = extraInfo;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _setFieldsFromEntity {
    
    self.ftxtName.text = self.point.name;
    [self.fbtnIcon setImage:self.point.icon.image forState:UIControlStateNormal];
    self.ftxtDescription.text = self.point.descr;
    [self _setExtraInfoField];
    
    [self _setLocationAndAccuracyField];
    [self _setTagsField];
}






@end
