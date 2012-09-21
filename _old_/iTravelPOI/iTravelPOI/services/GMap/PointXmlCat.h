//
//  PointXmlUtil.h
//  CDTest
//
//  Created by jzarzuela on 06/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEMap.h"
#import "MECategory.h"
#import "MEPoint.h"


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface MEPoint (PointXmlCat) 

@property (nonatomic, assign) NSString * kmlBlob;

- (void) updateExtInfoFromMap;
- (BOOL) parseExtInfoFromString:(NSString*) value;

@end
