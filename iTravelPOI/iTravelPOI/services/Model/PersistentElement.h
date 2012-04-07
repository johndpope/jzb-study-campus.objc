//
//  PersistentElement.h
//  iTravelPOI
//
//  Created by JZarzuela on 07/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


//*********************************************************************************************************************
#pragma mark -
#pragma mark Protocol definition
//---------------------------------------------------------------------------------------------------------------------
@protocol PersistentElement <NSObject>

@required

@property (nonatomic, retain) NSString *persistentID;

- (void) writeHeader:(NSMutableDictionary *)dict;
- (void) writeData:(NSMutableDictionary *)dict;

- (void) readHeader:(NSDictionary *)dict;
- (void) readData:(NSDictionary *)dict;

@end
