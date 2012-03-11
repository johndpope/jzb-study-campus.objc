//
//  GMapIconEditor.h
//  iTravelPOI
//
//  Created by JZarzuela on 10/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GMapIcon.h"
#import <UIKit/UIKit.h>



@class GMapIconEditor;



//*********************************************************************************************************************
#pragma mark -
#pragma mark GMapIconEditorDelegate protocol definition
//---------------------------------------------------------------------------------------------------------------------
@protocol GMapIconEditorDelegate <NSObject>

- (void) saveNewIcon:(GMapIconEditor *)sender iconToSave:(GMapIcon *)icon;

@end


//*********************************************************************************************************************
#pragma mark -
#pragma mark GMapIconEditor interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface GMapIconEditor : UIViewController


@property (nonatomic, retain) GMapIcon *gmapIcon;
@property (nonatomic, assign) id<GMapIconEditorDelegate> delegate;

@end
