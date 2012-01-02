//
//  Category.h
//  TTSync_Test
//
//  Created by jzarzuela on 02/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UNKNOWN_CATEGORY @"UNKNOWN";


@interface GCategory : NSObject {
    
@private
    NSString *name;
    NSString *iconName;
    NSMutableArray *pois;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *iconName;
@property (nonatomic, copy) NSArray *pois;


// Calcula el valor a utilizar como "category" a partir de la cadena iconStyle
+ (NSString *) calcCategoryFromIconStyle: (NSString *)iconStyle;

@end
