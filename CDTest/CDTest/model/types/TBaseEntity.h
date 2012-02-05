//
//  TBaseEntity.h
//  CDTest
//
//  Created by Snow Leopard User on 04/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TIcon;

@interface TBaseEntity : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSNumber * changed;
@property (nonatomic, retain) NSNumber * ts_created;
@property (nonatomic, retain) NSString * syncETag;
@property (nonatomic, retain) NSString * GID;
@property (nonatomic, retain) NSNumber * ts_updated;
@property (nonatomic, retain) NSString * NoSe;
@property (nonatomic, retain) TIcon * icon;

@end
