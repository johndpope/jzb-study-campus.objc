//
// GMSimpleItemFactory.h
//
// Created by Jose Zarzuela.
//

#import <Foundation/Foundation.h>
#import "GMItemFactory.h"
#import "GMSimpleModel.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PUBLIC Enumeration & definitions
// ---------------------------------------------------------------------------------------------------------------------





// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface GMSimpleItemFactory : NSObject <GMItemFactory>

+ (GMSimpleItemFactory *) factory;


@end
