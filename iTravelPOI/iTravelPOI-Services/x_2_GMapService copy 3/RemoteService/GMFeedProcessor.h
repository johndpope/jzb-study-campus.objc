//
// GMFeedProcessor.h
// GMFeedProcessor
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMModel.h"
#import "GMItemFactory.h"




// *********************************************************************************************************************
#pragma mark -
#pragma mark Enumeration & definitions
// ---------------------------------------------------------------------------------------------------------------------



// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface GMFeedProcessor: NSObject



// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Init && CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
// Depending on FEED XML content will create the proper placemark instance
+ (id<GMPlacemark>) emptyPlacemarkFromFeed:(NSDictionary *)feedDict itemFactory:(id<GMItemFactory>)itemFactory inMap:(id<GMMap>)map errRef:(NSErrorRef *)errRef;

// Clears markedAsModified and markedAsDeleted
+ (void) setItemValues:(id<GMItem>)item fromFeed:(NSDictionary *)feedDict;



// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------



@end
