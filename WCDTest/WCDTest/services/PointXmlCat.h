//
//  PointXmlUtil.h
//  CDTest
//
//  Created by jzarzuela on 06/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMap.h"
#import "TCategory.h"
#import "TPoint.h"


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface TPoint (PointXmlCat) {
}

@property (nonatomic, assign) NSString * kmlBlob;

- (void) updateExtInfoFromMap;
- (BOOL) parseExtInfoFromString:(NSString*) value;

@end
