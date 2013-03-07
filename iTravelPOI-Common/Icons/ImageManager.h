//
//  ImageManager.h
//  iTravelPOI-Mac
//
//  Created by Jose Zarzuela on 27/01/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************



//*********************************************************************************************************************
#pragma mark -
#pragma mark Public IconData interface definition
//*********************************************************************************************************************
@interface IconData : NSObject

@property (nonatomic, strong, readonly) NSString *HREF;
@property (nonatomic, strong, readonly) NSString *shortName;
@property (nonatomic, strong, readonly) NSString *imagePath;
@property (nonatomic, strong, readonly) NSImage *image;
@property (nonatomic, strong, readonly) NSImage *shadowImage;


#ifndef __ImageManager__IMPL__
- (id) init __attribute__ ((unavailable ("init not available")));
#endif


@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Public ImageManager Interface definition
//*********************************************************************************************************************
@interface ImageManager : NSObject




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
#ifndef __ImageManager__IMPL__
- (id) init __attribute__ ((unavailable ("init not available")));
#endif


+ (IconData *) iconDataForHREF:(NSString *)HREF;
+ (NSImage *) imageForName:(NSString *)name;


@end
