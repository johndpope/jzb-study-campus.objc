//
//  ModelService.h
//  CDTest
//
//  Created by Snow Leopard User on 03/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SrvcTicket.h"
#import "MEBaseEntity.h"
#import "MEMap.h"
#import "MECategory.h"
#import "MEPoint.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark Enumeration & definitions
//---------------------------------------------------------------------------------------------------------------------

#define CD_MODEL_NAME @"iTravelPOI"
#define CD_SLQLITE_FNAME @"iTravelPOI.sqlite"


typedef enum {
    SORT_BY_NAME = 0,
    SORT_BY_CREATING_DATE,
    SORT_BY_UPDATING_DATE
} SORTING_METHOD;


typedef void (^TBlock_saveContextFinished)(SrvcTicket *ticket, NSError *error);
typedef void (^TBlock_getUserMapListFinished)(SrvcTicket *ticket, NSArray *maps, NSError *error);
typedef void (^TBlock_getFlatElemensInMapFinished)(SrvcTicket *ticket, NSArray *elements, NSError *error);
typedef void (^TBlock_getCategorizedElemensInMapFinished)(SrvcTicket *ticket, NSArray *elements, NSError *error);



//*********************************************************************************************************************
#pragma mark -
#pragma mark ModelService interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface ModelService : NSObject 


@property (readonly, nonatomic, retain) NSManagedObjectContext * moContext;



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark ModelService CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (ModelService *)sharedInstance;



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark ModelService INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) initCDStack;
- (void) doneCDStack;

- (SRVC_ASYNCHRONOUS) saveContext:(TBlock_saveContextFinished) callbackBlock;

- (SRVC_ASYNCHRONOUS) getUserMapList:(TBlock_getUserMapListFinished) callbackBlock;

- (SRVC_ASYNCHRONOUS) getFlatElemensInMap:(MEMap *)map forCategories:(NSArray *)categories orderBy:(SORTING_METHOD)orderBy callback:(TBlock_getFlatElemensInMapFinished) callbackBlock;
- (SRVC_ASYNCHRONOUS) getCategorizedElemensInMap:(MEMap *)map forCategories:(NSArray *)categories orderBy:(SORTING_METHOD)orderBy callback:(TBlock_getCategorizedElemensInMapFinished) callbackBlock;



@end
