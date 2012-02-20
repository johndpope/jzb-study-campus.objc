//
//  PointCatEditorController.h
//  iTravelPOI
//
//  Created by jzarzuela on 19/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBaseEntity.h"
#import "TMap.h"


@class PointCatEditorController;


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@protocol PointCatEditorDelegate <NSObject>

- (TBaseEntity *) createNewInstanceForMap:(TMap *)map isPoint:(BOOL)isPoint;
- (void) pointCatEditCancel:(PointCatEditorController *)sender;
- (void) pointCatEditSave:(PointCatEditorController *)sender entity:(TBaseEntity *)entity;

@end


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface PointCatEditorController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
}

@property (nonatomic, assign) TBaseEntity * entity;
@property (nonatomic, assign) TMap *map;
@property (nonatomic, assign) id <PointCatEditorDelegate> delegate;


@end
