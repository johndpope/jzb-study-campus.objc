//
//  DelegateMapCompare.h
//  iTravelPOI
//
//  Created by JZarzuela on 06/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEComparer.h"


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface DelegateMapCompare : NSObject <MEComparerDelegate>

@property (nonatomic, retain) NSMutableArray * compItems;

- (void) processTuple:(MECompareTuple *) tuple;

@end
