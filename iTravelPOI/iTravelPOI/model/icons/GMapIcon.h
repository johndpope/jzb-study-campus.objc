//
//  GMapIcon.h
//  iTravelPOI
//
//  Created by jzarzuela on 03/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


//*********************************************************************************************************************
#pragma mark -
#pragma mark Enumerations & definitions
//---------------------------------------------------------------------------------------------------------------------


//*********************************************************************************************************************
#pragma mark -
#pragma mark MEBaseEntity interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface GMapIcon : NSObject 


@property (nonatomic, readonly) NSString *url;
@property (nonatomic, readonly) NSString *shortName;
@property (nonatomic, readonly) UIImage  *image;
@property (nonatomic, readonly) UIImage  *shadowImage;



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark GMapIcon CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (GMapIcon *) iconForURL:(NSString *)url;
+ (GMapIcon *) iconForShortName:(NSString *)shortName;


//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark GMapIcon INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------

@end
