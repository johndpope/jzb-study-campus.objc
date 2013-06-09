//
//  EntityEditorViewController.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBaseEntity.h"
#import "ScrollableToolbar.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************



//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface EntityEditorViewController : UIViewController



//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) modalEditEntity:(MBaseEntity *)entity isNew:(BOOL)isNewEntity controller:(UIViewController *)controller;



//=====================================================================================================================
#pragma mark -
#pragma mark SUBCLASSES PROTECTED methods
//---------------------------------------------------------------------------------------------------------------------
#ifdef __EntityEditorViewController__SUBCLASSES__PROTECTED__

@property (nonatomic, strong) MBaseEntity *entity;
@property (nonatomic, strong) NSManagedObjectContext *moContext;

- (NSString *) _editorTitle;
- (void) _nullifyEditor;

- (void) _rotateImageField:(UIImageView *)imgField;

- (void) _setFieldValuesFromEntity:(MBaseEntity *)entity;
- (void) _setEntityFromFieldValues:(MBaseEntity *)entity;

- (NSArray *) _tbItemsForEditingOthers;
- (void) _disableFieldsFromEditing;
- (void) _enableFieldsForEditing;


#endif




@end
