//
//  VisualMapEditorViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __VisualMapEditorViewController__IMPL__
#import "VisualMapEditorViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "Util_Macros.h"
#import "NSManagedObjectContext+Utils.h"

#import "MPointMapAnnotation.h"
#import "OpenInActionSheetViewController.h"
#import "PointEditorViewController.h"

#import "ScrollableToolbar.h"
#import "MPointMapAnnotation.h"

#import "ImageManager.h"
#import "MPoint.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define BTN_ID_EDIT_OK        1001
#define BTN_ID_EDIT_CANCEL    1002
#define BTN_ID_OPEN_IN        4001
#define BTN_ID_SHOW_MY_LOC    4002
#define BTN_ID_EDIT_LOC       4003
#define BTN_ID_EDIT_ALL       4004

#define ITEMSETID_DEFAULT     1001
#define ITEMSETID_EDIT        1002

#define SEL_CIRCLE_TAG        9876





//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface VisualMapEditorViewController() <MKMapViewDelegate>


@property (nonatomic, assign) IBOutlet MKMapView *mapView;
@property (nonatomic, assign) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, assign) IBOutlet ScrollableToolbar *scrollableToolbar;

@property (nonatomic, strong) VMapCloseCallback closeCallback;
@property (nonatomic, strong) VMapModifiedCallback modifiedCallback;
@property (nonatomic, strong) NSManagedObjectContext *moContext;

@property (nonatomic, assign) BOOL anitateEdit;
@property (nonatomic, assign) MPointMapAnnotation *editingAnnotation;
@property (nonatomic, strong) UIImage *editingImage;
@property (nonatomic, strong) NSMutableArray *annotations;
@property (nonatomic, assign) BOOL wasSaved;

@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation VisualMapEditorViewController




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (VisualMapEditorViewController *) editCoordinates:(CLLocationCoordinate2D)coord title:(NSString *)title image:(UIImage *)image controller:(UIViewController *)controller closeCallback:(VMapCloseCallback)closeCallback {

    VisualMapEditorViewController *me = [[VisualMapEditorViewController alloc] initWithNibName:@"VisualMapEditorViewController" bundle:nil];
    
    me.editing = YES;
    
    me.closeCallback = closeCallback;

    MPointMapAnnotation *pin = [MPointMapAnnotation annotationWithTitle:title image:image lat:coord.latitude lng:coord.longitude];
    me.editingAnnotation = pin;
    me.annotations = [NSMutableArray arrayWithObject:pin];
    
    me.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [controller presentViewController:me animated:YES completion:nil];
    
    return me;
}

//---------------------------------------------------------------------------------------------------------------------
+ (VisualMapEditorViewController *) showPointsWithNoEditing:(NSArray *)points controller:(UIViewController *)controller {

    VisualMapEditorViewController *me = [[VisualMapEditorViewController alloc] initWithNibName:@"VisualMapEditorViewController" bundle:nil];
    
    me.modifiedCallback = nil;
    me.moContext = nil;
    
    me.annotations = [NSMutableArray array];
    for(MPoint *point in points) {
        MPointMapAnnotation *pin = [MPointMapAnnotation annotationWithPoint:point];
        [me.annotations addObject:pin];
    }
    
    me.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [controller presentViewController:me animated:YES completion:nil];
    return me;
}

//---------------------------------------------------------------------------------------------------------------------
+ (VisualMapEditorViewController *) showPoints:(NSArray *)points withContext:(NSManagedObjectContext *)moContext controller:(UIViewController *)controller modifiedCallback:(VMapModifiedCallback)modifiedCallback {

    VisualMapEditorViewController *me = [[VisualMapEditorViewController alloc] initWithNibName:@"VisualMapEditorViewController" bundle:nil];

    me.modifiedCallback = modifiedCallback;
    
    me.moContext = moContext;

    me.annotations = [NSMutableArray array];
    for(MPoint *point in points) {
        MPointMapAnnotation *pin = [MPointMapAnnotation annotationWithPoint:point];
        [me.annotations addObject:pin];
    }
    
    me.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [controller presentViewController:me animated:YES completion:nil];
    return me;

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
    
    // Crea la barra de titulo, el scrollView y la de herramientas
    UILabel *titleBar = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 42)];
    titleBar.textAlignment = NSTextAlignmentCenter;
    titleBar.textColor = [UIColor whiteColor];
    titleBar.font = [UIFont boldSystemFontOfSize:18];
    titleBar.text = @"Visual Map";
    titleBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"breadcrumb-barBg"]];
    [self.view addSubview:titleBar];
    
    // Crea el boton de back
    UIButton *btnBack = [[UIButton alloc] initWithFrame:CGRectMake(0,5,50,30)];
    [btnBack setImage:[UIImage imageNamed:@"btn-back"] forState:UIControlStateNormal];
    [btnBack addTarget:self action:@selector(_btnCloseBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnBack];

    
    // Actualiza los campos desde la entidad a editar
    [self.mapView addAnnotations:self.annotations];
    [self _centerMapToShowAllPoints];
}


//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if(self.editing) {
        [self.scrollableToolbar setItems:[self _tbrItemsForEditing] itemSetID:ITEMSETID_EDIT animated:YES];
        // Comienza editando
        self.anitateEdit = YES;
        [self _startAnimateAnnotationEdit];
    } else {
        [self.scrollableToolbar setItems:[self _tbrItemsForDefault] itemSetID:ITEMSETID_DEFAULT animated:YES];
    }
    
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





// =====================================================================================================================
#pragma mark -
#pragma mark <MKMapViewDelegate> methods
// ---------------------------------------------------------------------------------------------------------------------
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)t_annotation {

    // Solo gestionamos el tipo de anotaciones indicado
    if(![t_annotation isKindOfClass:[MPointMapAnnotation class]]) {
        // Parece que es el UserLocation
        return nil;
    }
    
    
    MPointMapAnnotation *annotation = t_annotation;
    
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MPointMapAnnotation"];
    if(!view) {
        view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MPointMapAnnotation"];
        view.draggable = YES;
        view.canShowCallout = YES;
    }
    
    view.image = annotation.image;
    view.annotation = annotation;
    view.centerOffset = CGPointMake(0, -annotation.image.size.height/2);
    view.enabled = !self.scrollableToolbar.isEditModeActive;
    
    return view;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    // Si estaba cambiando de region porque estaba centrando un punto en edicion lo muestra
    if(self.anitateEdit) {
        [self _startAnimateAnnotationEdit];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {

    // Habilita los botones de edicion
    if([view.annotation isKindOfClass:[MPointMapAnnotation class]] && [(MPointMapAnnotation *)view.annotation point]!=nil) {
        [self.scrollableToolbar enableItemWithTagID:BTN_ID_OPEN_IN enabled:YES];
        [self.scrollableToolbar enableItemWithTagID:BTN_ID_EDIT_LOC enabled:YES];
        [self.scrollableToolbar enableItemWithTagID:BTN_ID_EDIT_ALL enabled:YES];
    }
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
    // Inhabilita los botones de edicion
    if([view.annotation isKindOfClass:[MPointMapAnnotation class]] && [(MPointMapAnnotation *)view.annotation point]!=nil) {
        [self.scrollableToolbar enableItemWithTagID:BTN_ID_OPEN_IN enabled:NO];
        [self.scrollableToolbar enableItemWithTagID:BTN_ID_EDIT_LOC enabled:NO];
        [self.scrollableToolbar enableItemWithTagID:BTN_ID_EDIT_ALL enabled:NO];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    NSLog(@"===================================================================================================");
    NSLog(@"- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error -> %@", error);
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    NSLog(@"===================================================================================================");
    NSLog(@"- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error -> %@ ",error);
}







// ---------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    //    NSLog(@"===================================================================================================");
    //    NSLog(@"- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated");
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
    //    NSLog(@"===================================================================================================");
    //    NSLog(@"- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView");
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    //    NSLog(@"===================================================================================================");
    //    NSLog(@"- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView");
}



// ---------------------------------------------------------------------------------------------------------------------
// mapView:didAddAnnotationViews: is called after the annotation views have been added and positioned in the map.
// The delegate can implement this method to animate the adding of the annotations views.
// Use the current positions of the annotation views as the destinations of the animation.
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    //    NSLog(@"===================================================================================================");
    //    NSLog(@"- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views ");
}

// ---------------------------------------------------------------------------------------------------------------------
// mapView:annotationView:calloutAccessoryControlTapped: is called when the user taps on left & right callout accessory UIControls.
//- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;

// ---------------------------------------------------------------------------------------------------------------------
// Overlays
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    //    NSLog(@"===================================================================================================");
    //    NSLog(@"- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay ");
    return nil;
}
- (void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews {
    //    NSLog(@"===================================================================================================");
    //    NSLog(@"- (void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews ");
}


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    //    NSLog(@"===================================================================================================");
    //    NSLog(@"- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation ");
}
- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView {
    //    NSLog(@"===================================================================================================");
    //    NSLog(@"- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView ");
}
- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView {
    //    NSLog(@"===================================================================================================");
    //    NSLog(@"- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView ");
}
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    //    NSLog(@"===================================================================================================");
    //    NSLog(@"- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState ");
    
}




//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) _tbrItemsForDefault {

    NSArray *__toolbarItems = nil;
    if(self.moContext==nil) {
        __toolbarItems = [NSArray arrayWithObjects:
                          [STBItem itemWithTitle:@"My Location" image:[UIImage imageNamed:@"btn-GPSLocation"] tagID:BTN_ID_SHOW_MY_LOC target:self action:@selector(_btnShowUserLocation:)],
                          [STBItem itemWithTitle:@"Open In" image:[UIImage imageNamed:@"btn-open-in"]  enabled:NO tagID:BTN_ID_OPEN_IN target:self action:@selector(_btnOpenIn:)],
                          nil];
    } else {
        __toolbarItems = [NSArray arrayWithObjects:
                          [STBItem itemWithTitle:@"My Location" image:[UIImage imageNamed:@"btn-GPSLocation"] tagID:BTN_ID_SHOW_MY_LOC target:self action:@selector(_btnShowUserLocation:)],
                          [STBItem itemWithTitle:@"Open In" image:[UIImage imageNamed:@"btn-open-in"]  enabled:NO tagID:BTN_ID_OPEN_IN target:self action:@selector(_btnOpenIn:)],
                          [STBItem itemWithTitle:@"Edit loc" image:[UIImage imageNamed:@"btn-edit"]  enabled:NO tagID:BTN_ID_EDIT_LOC target:self action:@selector(_btnEditPointLocation:)],
                          [STBItem itemWithTitle:@"Edit all" image:[UIImage imageNamed:@"btn-edit"]  enabled:NO tagID:BTN_ID_EDIT_ALL target:self action:@selector(_btnEditPointAllInfo:)],
                          nil];
    }

    return __toolbarItems;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) _tbrItemsForEditing {
    
    
    NSArray *__toolbarItems = [NSMutableArray arrayWithObjects:
                               [STBItem itemWithTitle:@"Cancel" image:[UIImage imageNamed:@"btn-checkCancel"] tagID:BTN_ID_EDIT_CANCEL target:self action:@selector(_btnEditingCancel:)],
                               [STBItem itemWithTitle:@"Done" image:[UIImage imageNamed:@"btn-checkOK"] tagID:BTN_ID_EDIT_OK target:self action:@selector(_btnEditingSave:)],
                               [STBItem itemWithTitle:@"My Location" image:[UIImage imageNamed:@"btn-GPSLocation"] tagID:BTN_ID_SHOW_MY_LOC target:self action:@selector(_btnShowUserLocation:)],
                               nil];
    
    return __toolbarItems;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _dismissEditor {

    // Avisa al callback si hubo cambios en las anotaciones
    if(self.wasSaved) {
        if(self.modifiedCallback) self.modifiedCallback();
        if(self.closeCallback) self.closeCallback(((MPointMapAnnotation *)self.annotations[0]).coordinate);
    }

    [self dismissViewControllerAnimated:YES completion:nil];

    // Set properties to nil
    self.closeCallback = nil;
    self.modifiedCallback = nil;
    self.moContext = nil;
    self.editingAnnotation = nil;
    self.annotations = nil;
    self.editingImage = nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _centerMapToShowAllPoints {
 
    
    CLLocationDegrees regMinLat=1000, regMaxLat=-1000, regMinLng=1000, regMaxLng=-1000;
    CLLocationCoordinate2D regCenter = CLLocationCoordinate2DMake(0, 0);
    MKCoordinateSpan regSpan = MKCoordinateSpanMake(0, 0);

    if(self.annotations.count==0) {
        
        MKUserLocation *uloc=self.mapView.userLocation;
        regCenter.latitude = uloc.coordinate.latitude;
        regCenter.longitude = uloc.coordinate.longitude;
        regSpan.latitudeDelta = 0.05;
        regSpan.longitudeDelta = 0.05;
        
    } else if(self.annotations.count==1) {
        
        MKPointAnnotation *pin = self.annotations[0];
        regCenter.latitude = pin.coordinate.latitude;
        regCenter.longitude = pin.coordinate.longitude;
        regSpan.latitudeDelta = 0.05;
        regSpan.longitudeDelta = 0.05;
        
    } else {

        // Calcula los extremos
        for(MKPointAnnotation *pin in self.annotations) {
            regMinLat = regMinLat <= pin.coordinate.latitude  ? regMinLat : pin.coordinate.latitude;
            regMaxLat = regMaxLat >  pin.coordinate.latitude  ? regMaxLat : pin.coordinate.latitude;
            regMinLng = regMinLng <= pin.coordinate.longitude ? regMinLng : pin.coordinate.longitude;
            regMaxLng = regMaxLng >  pin.coordinate.longitude ? regMaxLng : pin.coordinate.longitude;
        }
        
        // Establece el centro
        regCenter.latitude = regMinLat+(regMaxLat-regMinLat)/2;
        regCenter.longitude = regMinLng+(regMaxLng-regMinLng)/2;
        
        // Establece el span
        regSpan.latitudeDelta = regMaxLat-regMinLat;
        regSpan.longitudeDelta = regMaxLng-regMinLng;
    }
    
    // Ajusta la vista del mapa a la region
    MKCoordinateRegion region = MKCoordinateRegionMake(regCenter, regSpan);
    [self.mapView setRegion:region animated:TRUE];
    self.mapView.centerCoordinate = regCenter;

}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _btnCloseBack:(id)sender {
    [self _dismissEditor];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _btnOpenIn:(id)sender {
    
    // Comprueba que existe una anotacion seleccionada para editarla
    MPointMapAnnotation *annotation = self.mapView.selectedAnnotations[0];
    if(annotation==nil) return;
    
    [OpenInActionSheetViewController showOpenInActionSheetWithController:self point:annotation.point];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _btnShowUserLocation:(UIButton *)sender {
    
    MKUserLocation *uloc=self.mapView.userLocation;
    [self.mapView setCenterCoordinate:uloc.coordinate animated:YES];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _btnEditPointLocation:(UIButton *)sender {

    // Comprueba que existe una anotacion seleccionada para editarla
    MPointMapAnnotation *annotation = self.mapView.selectedAnnotations[0];
    if(annotation==nil) return;
    
    // Indica que debe animar la edicion de la anotacion y la almacena
    self.anitateEdit = YES;
    self.editingAnnotation = annotation;
    
    // Marca todas las anotaciones como no activas mientras dure la edicion
    [self.mapView.annotations enumerateObjectsUsingBlock:^(MPointMapAnnotation *item, NSUInteger idx, BOOL *stop) {
        MKAnnotationView *view = [self.mapView viewForAnnotation:item];
        view.enabled = NO;
    }];
    
    // Deselecciona la anotacion a editar y centra el mapa sobre su posicion
    [self.mapView deselectAnnotation:annotation animated:YES];
    [self.mapView setCenterCoordinate:annotation.coordinate animated:YES];
    [self.scrollableToolbar setItems:[self _tbrItemsForEditing] itemSetID:ITEMSETID_EDIT animated:YES];
    
    // Si ya estaba centrado no se disparara el panning del mapa
    CGFloat difLat = fabs(self.mapView.centerCoordinate.latitude - annotation.coordinate.latitude);
    CGFloat difLng = fabs(self.mapView.centerCoordinate.longitude - annotation.coordinate.longitude);
    if(difLat<0.000001 || difLng<0.000001) {
        [self _startAnimateAnnotationEdit];
    }

}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _btnEditPointAllInfo:(UIButton *)sender {
    
    // Comprueba que existe una anotacion seleccionada para editarla
    __block MPointMapAnnotation *annotation = self.mapView.selectedAnnotations[0];
    if(annotation==nil) return;
    
    PointEditorViewController *editor = [PointEditorViewController editorWithPoint:annotation.point moContext:self.moContext];
    [editor showModalWithController:self startEditing:YES closeSavedCallback:^(MBaseEntity *entity) {
        
        MPointMapAnnotation *pin = [MPointMapAnnotation annotationWithPoint:(MPoint *)entity];
        [self.mapView removeAnnotation:annotation];
        [self.mapView addAnnotation:pin];
        self.wasSaved = YES;
    }];
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _btnEditingSave:(id)sender {
    
    // Actualiza la posicion del punto
    [self _updateAssociatedMPoint:self.editingAnnotation.point withCoord:self.mapView.centerCoordinate];
    
    // Recuerda que se ha modificado algo
    self.wasSaved = YES;
    
    // Cancela el modo de edicion
    [self _stopAnimateAnnotationEdit:self.mapView.centerCoordinate];
    
    // Si se habia creado el editor directamente en modo de edicion devuelve el control al llamante
    if(self.editing) {
        // Establece de nuevo el valor porque no se habra ejecutado aun la animacion
        self.editingAnnotation.coordinate = self.mapView.centerCoordinate;
        [self _dismissEditor];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _btnEditingCancel:(id)sender {
    
    // Cancela el modo de edicion
    [self _stopAnimateAnnotationEdit:self.editingAnnotation.coordinate];
    
    // Si se habia creado el editor directamente en modo de edicion devuelve el control al llamante
    if(self.editing) {
        [self _dismissEditor];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _startAnimateAnnotationEdit {
    
    if(self.anitateEdit) {
        
        self.anitateEdit = NO;
        
        __block UIImage *selCicleImg = [UIImage imageNamed:@"selectionCircle"];
        __block UIImageView *selCicleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        selCicleView.tag = SEL_CIRCLE_TAG;
        
        CGFloat pw = selCicleImg.size.width/2;
        CGFloat ph = selCicleImg.size.height/2;
        CGFloat px = self.mapView.frame.origin.x + (self.mapView.frame.size.width-pw)/2;
        CGFloat py = self.mapView.frame.origin.y + (self.mapView.frame.size.height-ph)/2;
        selCicleView.frame = CGRectMake(px, py, pw, ph);
        selCicleView.image = selCicleImg;
        
        [self.view addSubview:selCicleView];
        
        [UIView animateWithDuration:0.2 animations:^{
            
            CGFloat pw = selCicleImg.size.width;
            CGFloat ph = selCicleImg.size.height;
            CGFloat px = self.mapView.frame.origin.x + (self.mapView.frame.size.width-pw)/2;
            CGFloat py = self.mapView.frame.origin.y + (self.mapView.frame.size.height-ph)/2;
            selCicleView.frame = CGRectMake(px, py, pw, ph);
            selCicleView.image = selCicleImg;
            
            if(self.editingAnnotation!=nil) {
                MKAnnotationView *aview = [self.mapView viewForAnnotation:self.editingAnnotation];
                self.editingImage = aview.image;
                UIImage *glowImage = [self _imageSemitransparentFromImage:aview.image];
                aview.image = glowImage;
            }
            
        } completion:^(BOOL finished) {
        }];
        
    }
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _stopAnimateAnnotationEdit:(CLLocationCoordinate2D)newCoord {
    
    
    // Indica que no hace falta que se anime mas el modo Edit
    self.anitateEdit = NO;

    // Restaura la toolbar por defecto
    [self.scrollableToolbar setItems:[self _tbrItemsForDefault] itemSetID:ITEMSETID_DEFAULT animated:YES];

    // Anima el que desaparezca la diana y aparezca de nuevo el punto
    [UIView animateWithDuration:0.2 animations:^{
        
        UIImageView *selCicleView = (UIImageView *)[self.view viewWithTag:SEL_CIRCLE_TAG];
        UIImage *selCicleImg = selCicleView.image;
        CGFloat pw = selCicleImg.size.width/2;
        CGFloat ph = selCicleImg.size.height/2;
        CGFloat px = self.mapView.frame.origin.x + (self.mapView.frame.size.width-pw)/2;
        CGFloat py = self.mapView.frame.origin.y + (self.mapView.frame.size.height-ph)/2;
        selCicleView.frame = CGRectMake(px, py, pw, ph);
        selCicleView.image = selCicleImg;

    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            
            UIImageView *selCicleView = (UIImageView *)[self.view viewWithTag:SEL_CIRCLE_TAG];
            [selCicleView removeFromSuperview];
            
            self.editingAnnotation.coordinate = newCoord;
            MKAnnotationView *aview = [self.mapView viewForAnnotation:self.editingAnnotation];
            aview.image = self.editingImage;

            [self.mapView setCenterCoordinate:newCoord animated:YES];
            
            self.editingAnnotation.coordinate = newCoord;
            self.editingAnnotation = nil;
            self.editingImage = nil;
            
        } completion:^(BOOL finished) {
            
            [self.mapView.annotations enumerateObjectsUsingBlock:^(MPointMapAnnotation *item, NSUInteger idx, BOOL *stop) {
                MKAnnotationView *view = [self.mapView viewForAnnotation:item];
                view.enabled = YES;
            }];
            
        }];
    }];
    
    
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _updateAssociatedMPoint:(MPoint *)point withCoord:(CLLocationCoordinate2D)newCoord {
 
    [point setLatitude:newCoord.latitude longitude:newCoord.longitude];
    [self.moContext saveChanges];
}

// ---------------------------------------------------------------------------------------------------------------------
-(UIImage *) _imageSemitransparentFromImage:(UIImage *)imageInput {
    

	CGRect imageRect = CGRectMake(0, 0, imageInput.size.width, imageInput.size.height);
    
    UIGraphicsBeginImageContext(imageRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0.0f, imageInput.size.height);
	CGContextScaleCTM(context, 1.0f, -1.0f);
    CGContextSetAlpha(context,0.3);
    CGContextBeginTransparencyLayer(context, NULL);
    CGContextDrawImage(context, imageRect, imageInput.CGImage);
    CGContextEndTransparencyLayer(context);

    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end

