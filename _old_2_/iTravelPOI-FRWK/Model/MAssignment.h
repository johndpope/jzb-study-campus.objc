//
//  MAssignment.h
//  iTravelPOI-Mac
//
//  Created by Jose Zarzuela on 30/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MBase.h"

@class MGroup, MPoint;

@interface MAssignment : MBase

@property (nonatomic, retain) MGroup *group;
@property (nonatomic, retain) MPoint *point;

@end
