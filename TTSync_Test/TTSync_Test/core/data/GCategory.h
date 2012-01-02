//
//  Category.h
//  TTSync_Test
//
//  Created by jzarzuela on 02/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Icon.h"

@interface Category : NSObject {
    
@private
    NSString *name;
    NSString *desc;
    Icon *icon;
    NSArray *pois;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic) Icon *icon;
@property (nonatomic) NSArray *pois;

@end
