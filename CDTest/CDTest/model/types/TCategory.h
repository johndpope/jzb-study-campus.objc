//
//  TCategory.h
//  CDTest
//
//  Created by Snow Leopard User on 04/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TBaseEntity.h"

@class TCategory, TMap, TPoint;

@interface TCategory : TBaseEntity {
@private
}
@property (nonatomic, retain) NSSet* points;
@property (nonatomic, retain) NSSet* subcategories;
@property (nonatomic, retain) NSSet* categories;
@property (nonatomic, retain) TMap * map;

@end
