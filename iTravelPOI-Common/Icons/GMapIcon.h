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
#pragma mark interface definition
//*********************************************************************************************************************
@interface GMapIcon : NSObject {
@private
    NSString *_HREF;
    NSString *_shortName;
    NSImage *_image;
    NSImage *_shadowImage;
}


@property (nonatomic, retain, readonly) NSString *HREF;
@property (nonatomic, retain, readonly) NSString *shortName;
@property (nonatomic, retain, readonly) NSImage  *image;
@property (nonatomic, retain, readonly) NSImage  *shadowImage;



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
#ifndef __PointEditorPanel__IMPL__
- (id) init __attribute__ ((unavailable ("init not available")));
#endif

+ (GMapIcon *) iconForHREF:(NSString *)HREF;


@end
