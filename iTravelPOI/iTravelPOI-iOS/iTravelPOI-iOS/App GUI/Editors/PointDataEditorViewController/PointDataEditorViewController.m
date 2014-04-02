//
//  PointDataEditorViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __PointDataEditorViewController__IMPL__
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import "PointDataEditorViewController.h"
#import "UIImage+Tint.h"
#import "BaseCoreDataService.h"
#import "IconEditorViewController.h"
#import "LocationEditorViewController.h"
#import "TagListEditorViewController.h"
#import "UIPlaceHolderTextView.h"
#import "MPoint.h"
#import "MMap.h"
#import "MTag.h"
#import "MIcon.h"
#import "Util_Macros.h"
#import "UIImage+Tint.h"





//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define MIN_PRECISION_TO_STOP_GPS   +5
#define GPS_UNKNOWN                 -1.0
#define GPS_ERROR                   -2.0

typedef NS_ENUM(NSUInteger, LocationEditingState) {
    LocationEditingStateNone, LocationEditingStateLat, LocationEditingStateLng
};



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface PointDataEditorViewController () <TagListEditorViewControllerDelegate, IconEditorViewControllerDelegate,
                                         LocationEditorViewControllerDelegate,
                                         UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint     *constraintContentWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint     *constraintContentHeight;
@property (assign, nonatomic)        CGSize                 minContentSize;

@property (weak, nonatomic) IBOutlet UIButton               *fbtnIcon;
@property (weak, nonatomic) IBOutlet UITextField            *ftxtName;
@property (weak, nonatomic) IBOutlet UILabel                *flblLocationLabel;
@property (weak, nonatomic) IBOutlet UIImageView            *fimgLocationImage;
@property (weak, nonatomic) IBOutlet UILabel                *flblGpsAccuracyLabel;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView  *ftxtDescription;
@property (weak, nonatomic) IBOutlet UIView                 *fvTagsView;
@property (weak, nonatomic) IBOutlet UILabel                *flblExtraInfo;

@property (weak, nonatomic) IBOutlet UIScrollView           *scrollView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem        *navBarSaveButton;

@property (weak, nonatomic)   UIView                        *editedFieldToScroll;

@property (strong, nonatomic) IBOutlet UIView               *iavView;
@property (weak, nonatomic)   IBOutlet UILabel              *iavLabel;
@property (strong, nonatomic) IBOutlet UITextField          *iavTextField;

@property (assign, nonatomic) LocationEditingState          locationEditingState;
@property (assign, nonatomic) CLLocationAccuracy            gpsAccuracyValue;
@property (strong, nonatomic) CLLocationManager             *locationManager;

@property (strong, nonatomic) NSManagedObjectContext        *moContext;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation PointDataEditorViewController


@synthesize point = _point;



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) setPoint:(MPoint *)point {

    _point = point;
    
    // Por algun motivo necesita referenciar directamente al moContext
    self.moContext = point.managedObjectContext;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) setTintColor:(UIColor *)tintColor {
    
    // Lo establece en la ventana padre
    self.view.tintColor = tintColor;
    
    // Propaga el tintColor a la barra del teclado
    for(UIView *childView in self.iavView.subviews) {
        childView.tintColor = tintColor;
        if([childView isKindOfClass:[UILabel class]]){
            ((UILabel *)childView).textColor = self.view.tintColor;
        } else if([childView isKindOfClass:[UIButton class]]) {
            UIImage *img = [((UIButton *)childView) imageForState:UIControlStateNormal];
            [((UIButton *)childView) setImage:[img burnTint:self.view.tintColor] forState:UIControlStateNormal];
        }
    }

}


//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
    
    }
    return self;
}



//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.ftxtName.placeholder = @"Name goes here";
    self.ftxtDescription.placeholderText = @"Description goes here";
    self.navBarSaveButton.enabled = FALSE;
    
    // Inicializa la geolocalizacion
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation; // En metros
    self.locationManager.distanceFilter = MIN_PRECISION_TO_STOP_GPS; // En metros
    self.gpsAccuracyValue = GPS_UNKNOWN;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // Apunta las dimensiones minimas
    self.minContentSize = CGSizeMake(self.constraintContentWidth.constant, self.constraintContentHeight.constant);
    
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
- (void) viewDidLayoutSubviews {

    [super viewDidLayoutSubviews];
    [self _updateContentViewConstraints];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//---------------------------------------------------------------------------------------------------------------------
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {

    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self _updateContentViewConstraints];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _updateContentViewConstraints {
    
    CGRect frame = self.scrollView.frame;
    CGFloat with = MAX(self.minContentSize.width, frame.size.width);
    CGFloat height = MAX(self.minContentSize.height, frame.size.height);

    if(with!=self.constraintContentWidth.constant || height!=self.constraintContentHeight.constant) {
        
        self.minContentSize = CGSizeMake(MIN(self.minContentSize.width, with), MAX(self.minContentSize.height, height));
        self.constraintContentWidth.constant = with;
        self.constraintContentHeight.constant = height;
        
        [self.view layoutIfNeeded];
    }
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
        [editor setContext:self.point.managedObjectContext assignedTags:self.point.directNoAutoTags availableTags:allAvailableTags];
        
    } else if([[segue identifier] isEqualToString:@"PointEditor_to_IconEditor"]) {
        
        IconEditorViewController *iconEditor = (IconEditorViewController *)segue.destinationViewController;
        [iconEditor setIcon:self.point.icon];
        iconEditor.delegate = self;
        [self.view endEditing:TRUE];

        // Propaga el color del tinte
        iconEditor.view.tintColor = self.view.tintColor;

        
    } else if([[segue identifier] isEqualToString:@"PointEditor_to_LocationEditor"]) {
    
        LocationEditorViewController *locationEditor = (LocationEditorViewController *)segue.destinationViewController;
        locationEditor.coordinate = self.point.coordinate;
        locationEditor.image = self.point.icon.image;
        locationEditor.delegate = self;
        [self.view endEditing:TRUE];
        
        // Propaga el color del tinte
        locationEditor.view.tintColor = self.view.tintColor;

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

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)locationIconTapped:(UITapGestureRecognizer *)sender {
    [self locationLabelTapped:sender];
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)locationLabelTapped:(UITapGestureRecognizer *)sender {

    // Si estaba geolocalizando para, sino edita la posicion
    if([self _isLocationActive]) {
        [self _stopLocationActivity];
    } else {
        // Simula haber tocado el campo de texto
        [self.iavTextField becomeFirstResponder];

        // Establece la etiqueta como elemento "editado"
        self.editedFieldToScroll = self.fimgLocationImage;
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
- (void) tagListEditor:(TagListEditorViewController *)sender assignedTags:(NSArray *)assignedTags tagsRemoved:(NSSet *)tagsRemoved tagsAdded:(NSSet *)tagsAdded {
    
    for(MTag *tag in tagsRemoved) {
        [tag untagPoint:self.point];
    }

    for(MTag *tag in tagsAdded) {
        [tag tagPoint:self.point];
    }

    if(tagsAdded.count>0 || tagsRemoved.count>0) {
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
#pragma mark <LocationEditorViewController> protocol methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) locationEditorCancel:(LocationEditorViewController *)sender {
    
}


// ---------------------------------------------------------------------------------------------------------------------
- (void) locationEditorSave:(LocationEditorViewController *)sender coord:(CLLocationCoordinate2D)coord {
    
    // Actualiza la información
    self.gpsAccuracyValue = GPS_UNKNOWN;
    self.navBarSaveButton.enabled |= [self.point updateLatitude:coord.latitude longitude:coord.longitude];
    [self _setLocationAndAccuracyField];
}





// =====================================================================================================================
#pragma mark -
#pragma mark <CLLocationManagerDelegate> protocol methods
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
    
    self.gpsAccuracyValue = GPS_ERROR;
    [self _setLocationAndAccuracyField];
}


//=====================================================================================================================
#pragma mark -
#pragma mark <UITextViewDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {

    self.editedFieldToScroll = textView;
    
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

    self.editedFieldToScroll = textField;

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

    } else {
        [self.view endEditing:TRUE];
    }
    
    return TRUE;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)textFieldDidEndEditing:(UITextField *) textField{
    
    if(textField==self.ftxtName) {
        self.navBarSaveButton.enabled |= [self.point updateName:self.ftxtName.text];
        [self.view endEditing:TRUE];
    }
}


//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _scrollToMakeEditedFieldVisible {
    
    if(!self.editedFieldToScroll) return;
    
    // Comprueba si hace falta realizar un scroll para dejar el campo de texto a la vista
    CGRect svBounds = self.scrollView.bounds;
    svBounds.size.height -= self.scrollView.contentInset.bottom;
    BOOL isFullyVisible = CGRectContainsRect(svBounds, self.editedFieldToScroll.frame);
    if(!isFullyVisible) {
        [self.scrollView setContentOffset:CGPointMake(0, self.editedFieldToScroll.frame.origin.y) animated:YES];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) keyboardDidShow {
    
    [super keyboardDidShow];
    
    if(self.locationEditingState!=LocationEditingStateNone) {
        [self _showInputAccesoryView];
    }
    
    [self _scrollToMakeEditedFieldVisible];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) keyboardDidHide {
    [self _hideInputAccesoryView];
    self.editedFieldToScroll = nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _updateInputAccesoryViewConstraints:(CGFloat)value {
    
    for(NSLayoutConstraint *constraint in self.iavView.superview.constraints) {
        if(constraint.firstItem==self.iavView && constraint.firstAttribute==NSLayoutAttributeTop) {
            constraint.constant = value;
        }
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _showInputAccesoryView {
    
    if(self.isKeyboardVisible) {
        
        CGFloat newTop = self.keyboardRect.origin.y - self.iavView.bounds.size.height;
        [self _updateInputAccesoryViewConstraints:newTop];
        self.iavView.hidden = FALSE;
        
        // Le quita un poco mas al ScrollView
        self.kbContentVTrailing.constant += self.iavView.bounds.size.height;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _hideInputAccesoryView {
    
    if(self.isKeyboardVisible) {
        
        [self _updateInputAccesoryViewConstraints:1000];
        self.iavView.hidden = TRUE;
        
        // Le pone un poco mas al ScrollView
        self.kbContentVTrailing.constant -= self.iavView.bounds.size.height;
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _dismissEditor {
    
    [self _stopLocationActivity];
    
    [self dismissViewControllerAnimated:YES completion:^{
        self.navBarSaveButton.enabled = FALSE;
        self.point = nil;
    }];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _stopImgLocationImageGlowing {
    [self.fimgLocationImage stopAnimating];
    self.fimgLocationImage.image = [UIImage imageNamed:@"tbar-mapMarker" burnTint:self.view.tintColor];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _startImgLocationImageGlowing {
    
    UIImage *baseImg = [UIImage imageNamed:@"tbar-mapMarker" burnTint:self.view.tintColor];
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

    // Ajusta valores raros al haber quitado los ceros
    if([strLat hasPrefix:@"."]) strLat = [NSString stringWithFormat:@"0%@",strLat];
    if([strLat hasSuffix:@"."]) strLat = [NSString stringWithFormat:@"%@0",strLat];
    if([strLng hasPrefix:@"."]) strLng = [NSString stringWithFormat:@"0%@",strLng];
    if([strLng hasSuffix:@"."]) strLng = [NSString stringWithFormat:@"%@0",strLng];
    
    self.flblLocationLabel.text = [NSString stringWithFormat:@"%@, %@",strLat,strLng];

    if(self.gpsAccuracyValue>=0) {
        self.flblGpsAccuracyLabel.text = [NSString stringWithFormat:@"GPS accuracy: %0.0f m", self.gpsAccuracyValue];
    } else {
        if(self.gpsAccuracyValue == GPS_UNKNOWN)
            self.flblGpsAccuracyLabel.text = @"GPS accuracy: UNKNOWN";
        else
            self.flblGpsAccuracyLabel.text = @"GPS accuracy: ERROR";
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
