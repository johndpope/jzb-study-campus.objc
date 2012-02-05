//
//  TPoint.h
//  CDTest
//
//  Created by Snow Leopard User on 04/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TBaseEntity.h"

@class TCategory, TCoordinates, TMap;

@interface TPoint : TBaseEntity {
@private
}
@property (nonatomic, retain) NSString * kmlBlob;
@property (nonatomic, retain) TMap * map;
@property (nonatomic, retain) NSSet* categories;
@property (nonatomic, retain) TCoordinates * coordinates;

@end
