//
//  PointMapViewController.m
//  iTravelPoint-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __PointMapViewController__IMPL__
#import <MapKit/MapKit.h>
#import "PointMapViewController.h"
#import "MPoint.h"
#import "MIcon.h"
#import "UIImage+Tint.h"
#import "Util_Macros.h"
#import "MKMapView+ZoomLevel.h"


#import "MMap.h"
#import "BaseCoreDataService.h"
#import "CustomOfflineTileOverlays.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define ACCESSORY_BTN_EDIT      10001
#define ACCESSORY_BTN_OPEN_IN   10002
#define SELECTED_TAG_NUMBER     98765



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface PointMapViewController () <MKMapViewDelegate>


@property (weak, nonatomic)     IBOutlet    UIButton                    *decrementZoomButton;
@property (weak, nonatomic)     IBOutlet    UIButton                    *incrementZoomButton;
@property (weak, nonatomic)     IBOutlet    MKMapView                   *pointsMapView;


@property (assign, nonatomic)               BOOL                        isEditing;
@property (assign, nonatomic)               NSUInteger                  zoomLevel;
@property (strong, nonatomic)               CustomOfflineTileOverlay    *overlay;


@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation PointMapViewController


@synthesize dataSource = _dataSource;



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (id) pointListWillChange {

    // No hace nada
    return nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) pointListDidChange:(id)prevInfo {

    // Remenber previous selected point
    MPoint *selPoint = self.dataSource.selectedPoint;

    // Sets new points
    [self _setPointsAsAnnotationsInMap: self.dataSource.pointList];
    
    // Restores previous selected point
    [self.pointsMapView selectAnnotation:selPoint animated:FALSE];
    
    // Centers map
    [self _centerAndZoomMap];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) startMultiplePointSelection {
    
    // Recuerda que esta en edicion
    self.isEditing = TRUE;
    
    // Elimina el punto seleccionado anteriormente
    self.dataSource.selectedPoint = nil;
    
    // Pone a cero los puntos previamente marcados
    [self.dataSource.checkedPoints removeAllObjects];
    
    // Hace que las anotaciones no puedan mostrar el dialogo y las deselecciona
    [self.pointsMapView.annotations enumerateObjectsUsingBlock:^(id<MKAnnotation> annotation, NSUInteger idx, BOOL *stop) {
        [self.pointsMapView deselectAnnotation:annotation animated:FALSE];
        MKAnnotationView *anView = [self.pointsMapView viewForAnnotation: annotation];
        if (anView){
            anView.canShowCallout = FALSE;
        }
    }];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) doneMultiplePointSelection {

    // Borra la marca de que esta en edicion
    self.isEditing = FALSE;
    
    // Vuelve a hacer que las anotaciones muestren el dialogo y las deja deseleccionadas
    // Elimina la imagen de seleccion de las anotaciones
    [self.pointsMapView.annotations enumerateObjectsUsingBlock:^(id<MKAnnotation> annotation, NSUInteger idx, BOOL *stop) {
        [self.pointsMapView deselectAnnotation:annotation animated:FALSE];
        MKAnnotationView *anView = [self.pointsMapView viewForAnnotation: annotation];
        if (anView){
            anView.canShowCallout = TRUE;
            [[anView viewWithTag:SELECTED_TAG_NUMBER] removeFromSuperview];
        }
    }];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) refreshSelectedPoint {
    
    [self _centerAndZoomMap];
}

//---------------------------------------------------------------------------------------------------------------------
- (CLLocationCoordinate2D) mapCenter {
    return self.pointsMapView.centerCoordinate;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) zoomOnMyLocation {
    
    if(self.pointsMapView.userLocation) {
        [self.pointsMapView setCenterCoordinate:self.pointsMapView.userLocation.coordinate zoomLevel:17 animated:FALSE];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) zoomAndShowAll {
    
    [self.pointsMapView centerAndZoomToShowAnnotations:32 animated:FALSE];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) zoomOnSelected {
    
    if(self.dataSource.selectedPoint) {
        [self.pointsMapView setCenterCoordinate:self.dataSource.selectedPoint.coordinate zoomLevel:17 animated:FALSE];
    }
}




//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.zoomLevel = 18;
    }
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewWillAppear:(BOOL)animated {
    
    
    [super viewWillAppear:animated];
    
    // Establece un overlay si no tiene conexion
    // TODO: ¿PORQUE NO PUEDE ENTERARSE DE QUE SE PERDIO LA CONEXION?
    self.overlay = [CustomOfflineTileOverlay overlay];
    //[self.pointsMapView addOverlay:self.overlay level:MKOverlayLevelAboveLabels];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if(self.pointsMapView.annotations.count==0 || (self.pointsMapView.annotations.count==1 && [self.pointsMapView.annotations[0] isKindOfClass:MKUserLocation.class])) {
        
        // Sets points
        [self _setPointsAsAnnotationsInMap: self.dataSource.pointList];

        // Center and Zoom map adecuately
        [self _centerAndZoomMap];
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




//=====================================================================================================================
#pragma mark -
#pragma mark <IBAction> outlet methods
//---------------------------------------------------------------------------------------------------------------------
- (IBAction)incrementZoomLevel:(UIButton *)sender {

    NSUInteger zoomLevel = self.pointsMapView.zoomLevel;
    if(zoomLevel<18) {
        zoomLevel++;
        [self.pointsMapView setZoomLevel:zoomLevel animated:TRUE];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)decrementZoomLevel:(UIButton *)sender {

    NSUInteger zoomLevel = self.pointsMapView.zoomLevel;
    if(zoomLevel>3) {
        zoomLevel--;
        [self.pointsMapView setZoomLevel:zoomLevel animated:TRUE];
    }
}



//=====================================================================================================================
#pragma mark -
#pragma mark <MKMapViewDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    static NSString *myMapAnnotationID = @"myMapAnnotationID";

    
    // Solo gestionamos el tipo de anotaciones indicado
    if(![annotation isKindOfClass:[MPoint class]]) {
        // Parece que es el UserLocation
        return nil;
    }

    // Consigue una instacia de la annotationView
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:myMapAnnotationID];
    if(!view) {
        view = [self _createAnnotationViewWithReuseIdentifier:myMapAnnotationID];
    }

    
    // Establece los valores a partir del punto
    MPoint *point = (MPoint *)annotation;

    view.annotation = annotation;
    view.image = point.icon.image;
    view.centerOffset = CGPointMake(0, -point.icon.image.size.height/2);
    [self _setAnnotationCheckedImage:view];
    
    return view;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    if(control.tag == ACCESSORY_BTN_EDIT) {
        [self.dataSource editPoint:(MPoint *)view.annotation];
    } else if(control.tag == ACCESSORY_BTN_OPEN_IN) {
        [self.dataSource openInExternalApp:(MPoint *)view.annotation];
    }    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {

    MKCoordinateRegion region = self.pointsMapView.region;
    CGRect bounds = self.pointsMapView.bounds;
    MKMapRect vrect = self.pointsMapView.visibleMapRect;

    NSLog(@"------------------");
    NSLog(@"bounds => x=%f, y=%f, w=%f, h=%f",bounds.origin.x,bounds.origin.y,bounds.size.width,bounds.size.height);
    NSLog(@"vrect  => x=%f, y=%f, w=%f, h=%f",vrect.origin.x,vrect.origin.y,vrect.size.width,vrect.size.height);
    NSLog(@"region => lat=%f, lng=%f, latDelta=%f, lngDelta=%f",region.center.latitude,region.center.longitude,region.span.latitudeDelta,region.span.longitudeDelta);
    NSLog(@"Zoom L => %d", mapView.zoomLevel);
    NSLog(@"------------------");

    /*************
    // Si estaba cambiando de region porque estaba centrando un punto en edicion lo muestra
    if(self.anitateEdit) {
        [self _startAnimateAnnotationEdit];
    }
     **************/
}

//---------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    // Solo gestionamos el tipo de anotaciones indicado
    if(![view.annotation isKindOfClass:[MPoint class]]) {
        return;
    }

    // Punto asociado a la vista
    MPoint *point = (MPoint *)view.annotation;

    
    // El comportamiento depende de si esta en edicion o no
    if(!self.isEditing) {

        // Establece el punto como el seleccionado por si pasa a la vista de lista de puntos
        self.dataSource.selectedPoint=point;
        
    } else {

        // No la deja seleccionada para que se pueda volver a tocar (ON/OFF)
        [mapView deselectAnnotation:view.annotation animated:FALSE];
        
        // La añade o elimina de la lista de seleccionados
        if([self.dataSource.checkedPoints containsObject:point.objectID]) {
            [self.dataSource.checkedPoints removeObject:point.objectID];
        } else {
            [self.dataSource.checkedPoints addObject:point.objectID];
        }
        
        // Actualiza la marca de seleccion
        [self _setAnnotationCheckedImage:view];
        
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
    // Solo gestionamos el tipo de anotaciones indicado
    if(![view.annotation isKindOfClass:[MPoint class]]) {
        return;
    }

    // El comportamiento depende de si esta en edicion o no
    if(!self.isEditing) {
        
        // Elimina el punto como el seleccionado por si pasa a la vista de lista de puntos
        self.dataSource.selectedPoint=nil;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    NSLog(@"===================================================================================================");
    NSLog(@"- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error -> %@", error);
}

//---------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    NSLog(@"===================================================================================================");
    NSLog(@"- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error -> %@ ",error);
}







//---------------------------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    //    NSLog(@"===================================================================================================");
    //    NSLog(@"- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated");
}


//---------------------------------------------------------------------------------------------------------------------
- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
    //    NSLog(@"===================================================================================================");
    //    NSLog(@"- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView");
}

//---------------------------------------------------------------------------------------------------------------------
- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    //    NSLog(@"===================================================================================================");
    //    NSLog(@"- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView");
}



//---------------------------------------------------------------------------------------------------------------------
// mapView:didAddAnnotationViews: is called after the annotation views have been added and positioned in the map.
// The delegate can implement this method to animate the adding of the annotations views.
// Use the current positions of the annotation views as the destinations of the animation.
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    //    NSLog(@"===================================================================================================");
    //    NSLog(@"- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views ");
}


//---------------------------------------------------------------------------------------------------------------------
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

//---------------------------------------------------------------------------------------------------------------------
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    
    if ([overlay isKindOfClass:[CustomOfflineTileOverlay class]]) {
        MKTileOverlay *to = overlay;
        NSLog(@"-------------------------------------------------------------------------------------------------");
        NSLog(@"coordinate lat=%f, lng=%f",to.coordinate.latitude, to.coordinate.longitude);
        NSLog(@"boundingMapRect = %f,%f - %f,%f",to.boundingMapRect.origin.x,to.boundingMapRect.origin.y,to.boundingMapRect.size.width,to.boundingMapRect.size.height);
        NSLog(@"tileSize = %f,%f",to.tileSize.width,to.tileSize.height);
        NSLog(@"geometryFlipped = %d",to.geometryFlipped);
        NSLog(@"minimumZ = %d",to.minimumZ);
        NSLog(@"maximumZ = %d",to.maximumZ);
        NSLog(@"canReplaceMapContent = %d",to.canReplaceMapContent);
        NSLog(@"URLTemplate = %@",to.URLTemplate);
        NSLog(@"-------------------------------------------------------------------------------------------------");
        return [[CustomOfflineTileOverlayRenderer alloc] initWithOverlay:overlay];
    }
    return nil;
}



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (MKAnnotationView *) _createAnnotationViewWithReuseIdentifier:(NSString * )reuseIdentifier {
    
    MKAnnotationView *view = [[MKAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:reuseIdentifier];
    
    view.draggable = NO;
    view.enabled = YES;
    view.canShowCallout = YES;
    
    UIImage *editImg = [UIImage imageNamed:@"tbar-edit"];
    UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [editBtn setImage:editImg  forState:UIControlStateNormal];
    editBtn.frame = CGRectMake(0, 0, editImg.size.width+10, editImg.size.height);
    editBtn.tag = ACCESSORY_BTN_EDIT;
    view.leftCalloutAccessoryView = editBtn;
    
    UIImage *openInImg = [UIImage imageNamed:@"tbar-share"];
    UIButton *openInBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [openInBtn setImage:openInImg  forState:UIControlStateNormal];
    openInBtn.frame = CGRectMake(0, 0, openInImg.size.width+10, openInImg.size.height);
    openInBtn.tag = ACCESSORY_BTN_OPEN_IN;
    view.rightCalloutAccessoryView = openInBtn;

    return view;
}


//---------------------------------------------------------------------------------------------------------------------
- (void) _setPointsAsAnnotationsInMap:(NSArray *) pointList {
    
    id userLocation = self.pointsMapView.userLocation;

    // Avoid removing user location off the map
    if ( userLocation != nil ) {
        
        NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[self.pointsMapView annotations]];
        [pins removeObject:userLocation];
        [self.pointsMapView removeAnnotations:pins];
        
    } else {
        
        [self.pointsMapView removeAnnotations:self.pointsMapView.annotations];
    }
    
    // Add new annotations from points
    [self.pointsMapView addAnnotations:pointList];
    
    NSMutableArray *pointPaths = [NSMutableArray array];
    
    for(MPoint *point in pointList) {
        TPointPath *pp = [[TPointPath alloc] init];
        MKMapPoint mp = MKMapPointForCoordinate(point.coordinate);
        
        double sinLatitude = sin(point.coordinate.latitude * M_PI/180.0);
        
        double zoomLevel = 17;
        double pixelX = ((point.coordinate.longitude + 180.0) / 360.0) * pow(2, zoomLevel);
        double pixelY = (0.5 - log((1.0 + sinLatitude) / (1.0 - sinLatitude)) / (4.0 * M_PI)) * pow(2, zoomLevel);
        
        pp.x = mp.x/powl(2, 28-17);
        pp.y = mp.y/powl(2, 28-17);
        
        NSLog(@"%d,%d",  pp.x-(int)pixelX,pp.y-(int)pixelY);
        
        [pointPaths addObject:pp];
    }
    self.overlay.pointPaths = pointPaths;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _centerAndZoomMap {

    if(!self.dataSource.selectedPoint) {
        
        // Centers map showing ALL the points
        [self.pointsMapView centerAndZoomToShowAnnotations:32 animated:FALSE];
        
        // Deselect all points
        [self.pointsMapView selectAnnotation:nil animated:FALSE];
        
    } else {
        
        // Centers map showing THAT selected point
        [self.pointsMapView setCenterCoordinate:self.dataSource.selectedPoint.coordinate zoomLevel:17 animated:FALSE];

        // Selects the point
        if([self.pointsMapView.annotations containsObject:self.dataSource.selectedPoint]) {
            [self.pointsMapView selectAnnotation:self.dataSource.selectedPoint animated:FALSE];
        }
        
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _setAnnotationCheckedImage:(MKAnnotationView *) view {
    
    // Comprueba si ya tenia una marca de seleccion
    UIView *checkImg = [view viewWithTag:SELECTED_TAG_NUMBER];
    
    // Punto asociado a la vista
    MPoint *point = (MPoint *)view.annotation;
    
    // El dejarla o ponerla depende de si esta en el conjunto de marcados y si esta en edicion
    if(self.isEditing && [self.dataSource.checkedPoints containsObject:point.objectID]) {
        if(!checkImg) {
            UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lightCheckedMark" burnTint:self.view.tintColor]];
            imgView.tag = SELECTED_TAG_NUMBER;
            [view addSubview:imgView];
        }
    } else {
        [checkImg removeFromSuperview];
    }
}


@end
