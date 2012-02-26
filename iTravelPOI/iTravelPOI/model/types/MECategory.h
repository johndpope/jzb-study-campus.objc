//
//  MECategory.h
//  iTravelPOI
//
//  Created by jzarzuela on 26/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MEBaseEntity.h"

@class MECategory, MEMap, MEPoint;

@interface MECategory : MEBaseEntity {
@private
}
@property (nonatomic, retain) NSSet* points;
@property (nonatomic, retain) MEMap * map;
@property (nonatomic, retain) NSSet* categories;
@property (nonatomic, retain) NSSet* subcategories;

@end
