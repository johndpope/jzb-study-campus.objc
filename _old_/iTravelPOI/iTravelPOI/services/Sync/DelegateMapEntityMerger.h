//
//  DelegateMapEntityMerger.h
//  iTravelPOI
//
//  Created by JZarzuela on 06/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEComparer.h"
#import "MEMap.h"

//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface DelegateMapEntityMerger : NSObject <MEComparerDelegate>

@property (nonatomic, retain) MEMap * localMap;

@property (nonatomic, retain) NSMutableArray * items;



- (void) processTuple:(MECompareTuple *) tuple;



@end
