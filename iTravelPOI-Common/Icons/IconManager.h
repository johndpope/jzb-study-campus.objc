//
//  IconManager.h
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
@property (nonatomic, strong, readonly) NSImage *image;
@property (nonatomic, strong, readonly) NSImage *shadowImage;


#ifndef __IconManager__IMPL__
- (id) init __attribute__ ((unavailable ("init not available")));
#endif


@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Public IconManager Interface definition
//*********************************************************************************************************************
@interface IconManager : NSObject




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
#ifndef __IconManager__IMPL__
- (id) init __attribute__ ((unavailable ("init not available")));
#endif


+ (IconData *) iconDataForHREF:(NSString *)HREF;
+ (NSImage *) imageForName:(NSString *)name;


@end
