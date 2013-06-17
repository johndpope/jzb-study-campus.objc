//
//  PointEditorViewController.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EntityEditorViewController.h"

#import "MPoint.h"
#import "MMap.h"
#import "MCategory.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface PointEditorViewController : EntityEditorViewController



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (PointEditorViewController *) editorWithNewPointInContext:(NSManagedObjectContext *)moContext
                                              associatedMap:(MMap *)map
                                         associatedCategory:(MCategory *)category;

+ (PointEditorViewController *) editorWithPoint:(MPoint *)point moContext:(NSManagedObjectContext *)moContext;




@end
