//
//  ModelService.h
//  CDTest
//
//  Created by Snow Leopard User on 03/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMap.h"
#import "TCategory.h"
#import "TPoint.h"



#define CD_MODEL_NAME @"iTravelPOI"
#define CD_SLQLITE_FNAME @"iTravelPOI.sqlite"


typedef enum {
    SORT_BY_NAME = 0,
    SORT_BY_CREATING_DATE,
    SORT_BY_UPDATING_DATE
} SORTING_METHOD;



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface ModelService : NSObject {
}

@property (readonly, nonatomic, retain) NSManagedObjectContext * moContext;


//---------------------------------------------------------------------------------------------------------------------
+ (ModelService *)sharedInstance;


//---------------------------------------------------------------------------------------------------------------------
- (void) initCDStack;
- (void) doneCDStack;
- (NSError *) saveContext;


- (NSArray *)getUserMapList:(NSError **)error;

- (NSArray *)sortCategoriesCategorized:(NSSet *)categories;

- (NSArray *)getAllCategoriesInMap:(TMap *)map error:(NSError **)error;
- (NSArray *)getFlatElemensInMap:(TMap *)map forCategory:(TCategory *)cat orderBy:(SORTING_METHOD)orderBy error:(NSError **)error ;
- (NSArray *)getCategorizedElemensInMap:(TMap *)map forCategories:(NSArray *)categories orderBy:(SORTING_METHOD)orderBy error:(NSError **)error;


@end
