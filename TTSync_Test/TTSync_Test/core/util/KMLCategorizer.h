//
//  KMLCategorizer.h
//  TTSync_Test
//
//  Created by jzarzuela on 03/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


//----------------------------------------------------------------------------
// Internal data structures
//----------------------------------------------------------------------------
@interface TNameCleaner : NSObject {
@private
    NSString *reMatch;
    NSString *strReplace;
}

@property (nonatomic, copy) NSString *reMatch;
@property (nonatomic, copy) NSString *strReplace;

+ (TNameCleaner *) initWithMatch: (NSString *)reMatch strReplace:(NSString *) strReplace; 

@end




typedef struct {
    NSString *reMatch;
    NSString *strReplace;
} TNameCleaner; 

typedef struct {
    NSString *name;
    NSString *icon;
    NSString *reStyle;
    NSString *reName;
    TNameCleaner cleaners[];
} TCatSelector; 


@interface KMLCategorizer : NSObject {
@private
    TCatSelector allCat;
    TCatSelector defCat;
    TCatSelector cats[];
}

@property (nonatomic, assign) TCatSelector *allCat;
@property (nonatomic, assign) TCatSelector *defCat;
@property (nonatomic, copy) NSArray *cats;

+ (KMLCategorizer *) createFromXMLInfo: (NSString *)xmlDafa;


@end
