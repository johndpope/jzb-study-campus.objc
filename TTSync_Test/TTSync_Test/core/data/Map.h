//
//  Map.h
//  TTSync_Test
//
//  Created by jzarzuela on 02/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Icon.h"

@interface Map : NSObject {
    
@private
    NSString *guid;
    NSString *name;
    NSString *desc;
    Icon     *icon;
    NSArray *pois;
    NSString *catPrefix;
    NSString *mapURL;
    NSString *lastUpdate;
}

@property (nonatomic, copy) NSString *guid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) Icon     *icon;
@property (nonatomic, copy) NSArray *pois;
@property (nonatomic, copy) NSString *catPrefix;
@property (nonatomic, copy) NSString *mapURL;
@property (nonatomic, copy) NSString *lastUpdate;

@end
