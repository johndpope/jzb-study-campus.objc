//
//  MPointMapAnnotation.m
//  iTravelPOI-Mac
//
//  Created by Jose Zarzuela on 16/02/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __MPointMapAnnotation__IMPL__
#import "MPointMapAnnotation.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface MPointMapAnnotation()

@property (nonatomic, assign) MPoint *point;
@property (nonatomic, assign) NSManagedObjectContext *moContext;
@property (nonatomic, strong) UIImage *image;

@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation MPointMapAnnotation





//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (MPointMapAnnotation *) annotationWithTitle:(NSString *)title image:(UIImage *)image lat:(CGFloat)lat lng:(CGFloat)lng {

    MPointMapAnnotation *me = [[MPointMapAnnotation alloc] init];
    me.point = nil;
    me.title = title;
    me.subtitle = nil;
    me.image = image;
    CLLocationCoordinate2D coord = {.latitude = lat, .longitude = lng};
    me.coordinate = coord;
    return me;
}

//---------------------------------------------------------------------------------------------------------------------
+ (MPointMapAnnotation *) annotationWithPoint:(MPoint *)point {
   
    // No tiene sentido sin un punto
    if(point==nil) return  nil;
    
    // Crea la anotacion y almacena el punto asociado
    MPointMapAnnotation *me = [MPointMapAnnotation annotationWithTitle:point.name image:point.entityImage lat:point.latitudeValue lng:point.longitudeValue];
    me.point = point;
    return me;
}





//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------




//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------

@end

