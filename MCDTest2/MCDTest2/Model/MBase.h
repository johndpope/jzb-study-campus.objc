//
//  MBase.h
//  MCDTest2
//
//  Created by Jose Zarzuela on 19/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MBase : NSManagedObject

@property (nonatomic, retain) NSString * etag;
@property (nonatomic) BOOL markedAsDeleted;
@property (nonatomic) BOOL modifiedSinceLastSync;
@property (nonatomic, retain) NSString * gID;

@end
