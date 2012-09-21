//
//  MBaseNamed.h
//  MCDTest2
//
//  Created by Jose Zarzuela on 19/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MBase.h"


@interface MBaseNamed : MBase

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * desc;

@end
