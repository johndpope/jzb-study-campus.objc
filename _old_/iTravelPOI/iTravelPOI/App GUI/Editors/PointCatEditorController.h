//
//  PointCatEditorController.h
//  iTravelPOI
//
//  Created by jzarzuela on 19/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MEMapElement.h"
#import "MEMap.h"


@class PointCatEditorController;


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@protocol PointCatEditorDelegate <NSObject>

- (MEMapElement *) createNewInstanceForMap:(MEMap *)map isPoint:(BOOL)isPoint;
- (void) pointCatEditorSave:(PointCatEditorController *)sender entity:(MEMapElement *)entity;

@end


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface PointCatEditorController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
}

@property (nonatomic, assign) MEMapElement * entity;
@property (nonatomic, assign) MEMap *map;

@property (nonatomic, assign) id <PointCatEditorDelegate> delegate;


@end
