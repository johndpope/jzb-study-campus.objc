//
//  TCoordinates.h
//  CDTest
//
//  Created by Snow Leopard User on 04/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TCoordinates : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * lng;
@property (nonatomic, retain) NSNumber * lat;

@end
