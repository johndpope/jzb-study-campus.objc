//
//  CollectionMerger.h
//  WCDTest
//
//  Created by jzarzuela on 16/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMap.h"

//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface CollectionMerger : NSObject {
@private
    
}

+ (NSArray *) merge:(NSArray *)locals remotes:(NSArray * )remotes inLocalMap:(TMap *)localMap;

@end
