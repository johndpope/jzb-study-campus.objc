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

- (void) mapEditorCancel:(MapEditorController *)sender;
- (void) mapEditorSave:(MapEditorController *)sender name:(NSString *)name desc:(NSString *) desc;

@end



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface MapEditorController : UIViewController {
}

@property (nonatomic, assign) id <MapEditorDelegate> delegate;
@property (nonatomic, assign) TMap *map;

@end
