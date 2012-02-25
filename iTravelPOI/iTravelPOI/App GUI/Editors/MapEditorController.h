//
//  MapEditorController.h
//  iTravelPOI
//
//  Created by jzarzuela on 18/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMap.h"



@class MapEditorController;


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@protocol MapEditorDelegate 

- (TMap *) createNewInstance;
- (void) mapEditorCancel:(MapEditorController *)sender;
- (void) mapEditorSave:(MapEditorController *)sender map:(TMap *)map;

@end



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface MapEditorController : UIViewController {
}

@property (nonatomic, assign) id <MapEditorDelegate> delegate;
@property (nonatomic, assign) TMap *map;

@end
