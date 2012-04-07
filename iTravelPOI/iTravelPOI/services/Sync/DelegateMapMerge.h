//
//  DelegateMapMerge.h
//  iTravelPOI
//
//  Created by JZarzuela on 06/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEComparer.h"


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface DelegateMapMerge : NSObject <MEComparerDelegate>

@property (nonatomic, assign) NSError *error;

- (void) processTuple:(MECompareTuple *) tuple;

@end
