//
//  POIData.h
//  JZBTest
//
//  Created by Snow Leopard User on 15/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


#define UNKNOWN_CATEGORY @"UNKNOWN";


@interface POI : NSObject {
    
@private
    NSString *name;
    NSString *desc;
    double lng;
    double lat;
    NSString *iconStyle;
    NSString *category;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic) double lng;
@property (nonatomic) double lat;
@property (nonatomic, copy) NSString *iconStyle;
@property (nonatomic, copy) NSString *category;


// Calcula el valor a utilizar como "category" a partir de la cadena iconStyle
+ (NSString *) calcCategoryFromIconStyle: (NSString *)iconStyle;

// Muestra por consola la informacion del elemento
- (void) dump;


@end
