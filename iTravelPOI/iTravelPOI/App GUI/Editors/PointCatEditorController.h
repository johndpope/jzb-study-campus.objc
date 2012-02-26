//
//  PointCatEditorController.h
//  iTravelPOI
//
//  Created by jzarzuela on 19/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MEBaseEntity.h"
#import "MEMap.h"


@class PointCatEditorController;


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@protocol PointCatEditorDelegate <NSObject>

- (MEBaseEntity *) createNewInstanceForMap:(MEMap *)map isPoint:(BOOL)isPoint;
- (void) pointCatEditCancel:(PointCatEditorController *)sender;
- (void) pointCatEditSave:(PointCatEditorController *)sender entity:(MEBaseEntity *)entity;

@end


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface PointCatEditorController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
}

@property (nonatomic, assign) MEBaseEntity * entity;
@property (nonatomic, assign) MEMap *map;
@property (nonatomic, assign) id <PointCatEditorDelegate> delegate;


@end
