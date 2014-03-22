//
// JavaStringCat.m
// JZBTest
//
// Created by Snow Leopard User on 16/10/11.
// Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MKMapView+ZoomLevel.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation MKMapView (ZoomLevel)



// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
//---------------------------------------------------------------------------------------------------------------------
- (void) centerAndZoomToShowAnnotations:(CGFloat)iconPaddingSize animated:(BOOL)animated {
    
    
    CLLocationDegrees regMinLat=100000, regMaxLat=-100000, regMinLng=100000, regMaxLng=-100000;
    CLLocationCoordinate2D regCenter = CLLocationCoordinate2DMake(0, 0);
    MKCoordinateSpan regSpan = MKCoordinateSpanMake(0, 0);
    
    
    if(self.annotations.count==0) {
        
        // Si no hay anotaciones ni hay UserLocation utiliza un punto en que se vea europa
        CLLocationCoordinate2D worldCentre = CLLocationCoordinate2DMake(39.620224519822756, 6.8606111116944657);
        [self setCenterCoordinate:worldCentre zoomLevel:4 animated:animated];
        
    } else if(self.annotations.count==1 && [self.annotations[0] isKindOfClass:MKUserLocation.class]) {
        
        // Si no hay anotaciones utiliza la UserLocation
        MKUserLocation *uloc=self.userLocation;
        [self setCenterCoordinate:uloc.coordinate zoomLevel:17 animated:animated];
        
    } else {
        
        // Calcula los extremos
        for(MKPointAnnotation *pin in self.annotations) {
            
            // Se salta la posicion del usuario y se centra en los puntos
            if([pin isKindOfClass:MKUserLocation.class]) continue;
            
            regMinLat = MIN(regMinLat, pin.coordinate.latitude);
            regMaxLat = MAX(regMaxLat, pin.coordinate.latitude);
            regMinLng = MIN(regMinLng, pin.coordinate.longitude);
            regMaxLng = MAX(regMaxLng, pin.coordinate.longitude);
        }
        
        // Establece el span
        regSpan.latitudeDelta = regMaxLat-regMinLat;
        regSpan.longitudeDelta = regMaxLng-regMinLng;
        
        // Establece el centro
        regCenter.latitude = regMinLat+regSpan.latitudeDelta/2;
        regCenter.longitude = regMinLng+regSpan.longitudeDelta/2;
        
        // Ajusta por si nos hemos pasado
        regSpan.latitudeDelta = MIN(180, regSpan.latitudeDelta);
        regSpan.longitudeDelta = MIN(360, regSpan.longitudeDelta);

    
        // Ajusta el rectangulo visible para que no se recorte los iconos que esten en los bordes
        MKMapRect rect = MKMapRectForCoordinateRegion(MKCoordinateRegionMake(regCenter, regSpan));
        
        CGFloat iconPointsWidth = iconPaddingSize * (CGFloat)rect.size.width / (CGFloat)self.bounds.size.width;
        CGFloat iconPointsHeight = iconPaddingSize * (CGFloat)rect.size.height / (CGFloat)self.bounds.size.height;
        
        rect.origin.x -= iconPointsWidth/2;
        rect.size.width += iconPointsWidth;
        rect.origin.y -= iconPointsHeight;
        rect.size.height += iconPointsHeight;
        
        
        // Ajusta la vista del mapa a la region, centrandolo
        [self setVisibleMapRect:rect animated:animated];
    }
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
    zoomLevel:(NSUInteger)zoomLevel
    animated:(BOOL)animated
{
    // clamp zoom numbers between 3 and 19
    zoomLevel = MAX(zoomLevel, 3);
    zoomLevel = MIN(zoomLevel, 19);

    // 21 = 20 + 1 to avoid multiplying by point-pixel scale factor of 2.0
    CGFloat rectWidth = self.bounds.size.width * pow(2, 21-zoomLevel);
    CGFloat rectHeight = self.bounds.size.height * pow(2, 21-zoomLevel);

    MKMapPoint originPoint = MKMapPointForCoordinate(centerCoordinate);
    originPoint.x -= rectWidth/2.0;
    originPoint.y -= rectHeight/2.0;

    MKMapRect visibleRect = MKMapRectMake(originPoint.x, originPoint.y, rectWidth, rectHeight);
    
    [self setVisibleMapRect:visibleRect animated:animated];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setZoomLevel:(NSUInteger)zoomLevel animated:(BOOL)animated {
    [self setCenterCoordinate:self.centerCoordinate zoomLevel:zoomLevel animated:animated];
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSUInteger) zoomLevel {
    
    NSUInteger zoom = round(21.0 - log2((CGFloat)self.visibleMapRect.size.width / (CGFloat)self.bounds.size.width));
    return zoom;
}



// =====================================================================================================================
#pragma mark -
#pragma mark General PRIVATE methods
//---------------------------------------------------------------------------------------------------------------------
MKMapRect MKMapRectForCoordinateRegion(MKCoordinateRegion region)
{
    MKMapPoint a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
                                                                      region.center.latitude + region.span.latitudeDelta / 2,
                                                                      region.center.longitude - region.span.longitudeDelta / 2));
    MKMapPoint b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
                                                                      region.center.latitude - region.span.latitudeDelta / 2,
                                                                      region.center.longitude + region.span.longitudeDelta / 2));
    return MKMapRectMake(MIN(a.x,b.x), MIN(a.y,b.y), ABS(a.x-b.x), ABS(a.y-b.y));
}

@end
