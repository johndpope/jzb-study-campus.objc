//
//  MBase.h
//  iTravelPOI-Mac
//
//  Created by Jose Zarzuela on 30/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MBase : NSManagedObject

@property (nonatomic, retain) NSString * etag;
@property (nonatomic, retain) NSString * gID;
@property (nonatomic) BOOL markedAsDeleted;
@property (nonatomic) BOOL modifiedSinceLastSync;

@end
