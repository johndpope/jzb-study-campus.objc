//
//  MapEditorController.h
//  iTravelPOI
//
//  Created by jzarzuela on 18/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MapEditorController;


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@protocol MapEditorDelegate 

- (void) mapEditorSave:(MapEditorController *)sender name:(NSString *)name desc:(NSString *) desc;
- (void) mapEditorCancel:(MapEditorController *)sender;

@end


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface MapEditorController : UIViewController {
}

@property (nonatomic, retain) IBOutlet UIButton *saveButton;
@property (nonatomic, retain) IBOutlet UITextField *mapName;
@property (nonatomic, retain) IBOutlet UITextView *mapDescription;
@property (nonatomic, assign) id <MapEditorDelegate> delegate;

@end
