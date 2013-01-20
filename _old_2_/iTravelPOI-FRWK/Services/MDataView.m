//
//  MDataView.m
//  iTravelPOI-Mac
//
//  Created by Jose Zarzuela on 30/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "MDataView.h"
#import "BaseCoreData.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark MDataView Private interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface MDataView()


@property (nonatomic, strong) NSManagedObjectID *elemID;

@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark MDataView implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation MDataView


@synthesize element = _element;
@synthesize elemID = _elemID;
@synthesize count = _count;
@synthesize selected = _selected;
@synthesize data = _data;




//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (MDataView *) dataViewWithID:(NSManagedObjectID *)elemID count:(uint) count {
    
    MDataView *instance = [[MDataView alloc] init];
    instance.elemID=elemID;
    instance.count=count;
    instance.selected = FALSE;
    return instance;
}

//---------------------------------------------------------------------------------------------------------------------
+ (MDataView *) dataViewWithID:(NSManagedObjectID *)elemID {
    return [MDataView dataViewWithID:elemID count:0];
}



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Getter & Setter methods
//---------------------------------------------------------------------------------------------------------------------
- (void) element:(NSManagedObject *)value {
    _element = value;
    self.elemID = value.objectID;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSManagedObject *) element {
    
    if(_element==nil) {
        _element=  [BaseCoreData.moContext objectWithID:self.elemID];
    }
    
    return _element;
}



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark CLASS private methods
//---------------------------------------------------------------------------------------------------------------------



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------


@end

