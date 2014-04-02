//
//  MPointMapAnnotation.h
//  iTravelPOI-Mac
//
//  Created by Jose Zarzuela on 16/02/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MPoint.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface MPointMapAnnotation : MKPointAnnotation


@property (strong, readonly, nonatomic) MPoint *point;
@property (strong, readonly, nonatomic) UIImage *image;


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (MPointMapAnnotation *) annotationWithPoint:(MPoint *)point;
+ (MPointMapAnnotation *) annotationWithTitle:(NSString *)title image:(UIImage *)image lat:(CGFloat)lat lng:(CGFloat)lng;


//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------


@end
