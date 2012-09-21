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
#pragma mark MEBaseEntity interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface GMapIcon : NSObject {
@private
    UIImage *_image;
    UIImage *_shadowImage;
}


@property (nonatomic, retain, readonly) NSString *url;
@property (nonatomic, retain, readonly) NSString *shortName;
@property (nonatomic, retain, readonly) UIImage  *image;
@property (nonatomic, retain, readonly) UIImage  *shadowImage;



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark GMapIcon CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (GMapIcon *) iconForURL:(NSString *)url;


@end
