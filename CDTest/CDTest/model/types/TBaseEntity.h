//
//  TBaseEntity.h
//  CDTest
//
//  Created by Snow Leopard User on 04/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TBaseEntity : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * GID;
@property (nonatomic, retain) NSString * name;

@end
