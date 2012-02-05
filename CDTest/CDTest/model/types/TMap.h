//
//  TMap.h
//  CDTest
//
//  Created by Snow Leopard User on 04/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TBaseEntity.h"

@class TCategory, TPoint;

@interface TMap : TBaseEntity {
}

    @property (nonatomic, retain) NSSet* points;
    @property (nonatomic, retain) TPoint * ExtInfo;
    @property (nonatomic, retain) NSSet* categories;

//---------------------------------------------------------------------------------------------------------------------
+ (TMap *) newMapInstance;

@end
