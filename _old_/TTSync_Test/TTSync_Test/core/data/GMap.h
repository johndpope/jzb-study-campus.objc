//
//  Map.h
//  TTSync_Test
//
//  Created by jzarzuela on 02/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPOI.h"

@interface GMap : NSObject {
    
@private
    NSString *guid;
    NSString *name;
    NSMutableArray *pois;
    NSString *mapURL;
    NSString *lastUpdate;
}

@property (nonatomic, copy) NSString *guid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray *pois;
@property (nonatomic, copy) NSString *mapURL;
@property (nonatomic, copy) NSString *lastUpdate;


// Añade un nuevo GPOI al mapa. A partir de ese punto el mapa es el dueño del POI
- (void) addPOI: (GPOI *)apoi;

@end
