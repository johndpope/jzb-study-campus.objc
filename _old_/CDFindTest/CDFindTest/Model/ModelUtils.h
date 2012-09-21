//
//  ModelUtils.h
//  CDFindTest
//
//  Created by Jose Zarzuela on 28/07/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"

@interface ModelUtils : NSObject

+ (MGroup *) createGroupWithName:(NSString *)name parentGrp:(MGroup *)parent;

+ (MPoint *) createPointWithName:(NSString *)name;

+ (void) updatePoint:(MPoint *)point withGroups:(NSSet *)groups;

@end
