//
//  EntityEditorDelegate.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 04/04/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBaseEntity.h"
#import "EntityEditorViewController2.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark EntityEditorDelegate Public protocol definition
//*********************************************************************************************************************
@protocol EntityEditorDelegate <NSObject>

- (BOOL) editorSaveChanges:(UIViewController<EntityEditorViewController2> *)senderEditor modifiedEntity:(MBaseEntity *)modifiedEntity;
- (BOOL) editorCancelChanges:(UIViewController<EntityEditorViewController2> *)senderEditor;

@end


