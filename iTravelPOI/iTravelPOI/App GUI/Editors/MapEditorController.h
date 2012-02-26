//
//  MapEditorController.h
//  iTravelPOI
//
//  Created by jzarzuela on 18/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MEMap.h"



@class MapEditorController;


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@protocol MapEditorDelegate 

- (MEMap *) createNewInstance;
- (void) mapEditorCancel:(MapEditorController *)sender;
- (void) mapEditorSave:(MapEditorController *)sender map:(MEMap *)map;

@end



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface MapEditorController : UIViewController {
}

@property (nonatomic, assign) id <MapEditorDelegate> delegate;
@property (nonatomic, assign) MEMap *map;

@end
