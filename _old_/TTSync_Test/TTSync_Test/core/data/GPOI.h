//
//  POIData.h
//  JZBTest
//
//  Created by Snow Leopard User on 15/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GPOI : NSObject {
    
@private
    NSString *name;
    NSString *desc;
    double lng;
    double lat;
    NSString *iconStyle;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic) double lng;
@property (nonatomic) double lat;
@property (nonatomic, copy) NSString *iconStyle;


// Muestra por consola la informacion del elemento
- (void) dump;


@end
