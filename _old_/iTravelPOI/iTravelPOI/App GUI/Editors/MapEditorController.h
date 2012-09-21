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
#pragma mark -
#pragma mark MapEditorDelegate protocol definition
//---------------------------------------------------------------------------------------------------------------------
@protocol MapEditorDelegate 

- (MEMap *) mapEditorCreateMapInstance;
- (void)    mapEditorSave:(MapEditorController *)sender map:(MEMap *)map;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark MapEditorController interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface MapEditorController : UIViewController {
}

@property (nonatomic, assign) id <MapEditorDelegate> delegate;
@property (nonatomic, retain) MEMap *map;

@end
