//
//  MBaseNamed.h
//  iTravelPOI-Mac
//
//  Created by Jose Zarzuela on 30/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MBase.h"


@interface MBaseNamed : MBase

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * name;

@end
