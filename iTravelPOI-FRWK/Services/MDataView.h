//
//  MDataView.h
//  iTravelPOI-Mac
//
//  Created by Jose Zarzuela on 30/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark MDataView interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface MDataView : NSObject


@property (nonatomic, strong) NSManagedObject *element;
@property (nonatomic) uint count;
@property (nonatomic) BOOL selected;
@property (nonatomic, strong) id data;


//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (MDataView *) dataViewWithID:(NSManagedObjectID *)elemID count:(uint) count;
+ (MDataView *) dataViewWithID:(NSManagedObjectID *)elemID;



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------


@end
