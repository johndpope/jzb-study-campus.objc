//
//  EntityEditorDelegate.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 04/04/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBaseEntity.h"
#import "EntityEditorViewController.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark EntityEditorDelegate Public protocol definition
//*********************************************************************************************************************
@protocol EntityEditorDelegate <NSObject>

- (BOOL) editorSaveChanges:(UIViewController<EntityEditorViewController> *)senderEditor modifiedEntity:(MBaseEntity *)modifiedEntity;
- (BOOL) editorCancelChanges:(UIViewController<EntityEditorViewController> *)senderEditor;

@end


