//
// JavaStringCat.h
// JZBTest
//
// Created by Snow Leopard User on 16/10/11.
// Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>


//---------------------------------------------------------------------------------------------------------------------
// Specifically, most spherical mercator maps use an extent of the world from -180 to 180 longitude, and
// from -85.0511 to 85.0511 latitude. Because the mercator projection stretches to infinity as you approach the poles,
// a cutoff in the north-south direction is required, and this particular cutoff results in a perfect square of projected meters.



// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// *********************************************************************************************************************
@interface MKMapView (ZoomLevel)

- (void) centerAndZoomToShowAnnotations:(CGFloat) iconPaddingSize animated:(BOOL)annimated;

- (void) setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                   zoomLevel:(NSUInteger)zoomLevel
                    animated:(BOOL)animated;

- (void) setZoomLevel:(NSUInteger)zoomLevel animated:(BOOL)animated;

- (NSUInteger) zoomLevel;


@end
