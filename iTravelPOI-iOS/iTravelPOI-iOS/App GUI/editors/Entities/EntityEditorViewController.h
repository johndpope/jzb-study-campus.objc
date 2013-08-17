//
//  EntityEditorViewController.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBaseEntity.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************
typedef void (^TCloseSavedCallback)(MBaseEntity *entity);



//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface EntityEditorViewController : UIViewController

@property (nonatomic, strong) MBaseEntity *entity;



//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) showModalWithController:(UIViewController *)controller startEditing:(BOOL)startEditing closeSavedCallback:(TCloseSavedCallback)closeSavedCallback;



//=====================================================================================================================
#pragma mark -
#pragma mark SUBCLASSES PROTECTED methods
//---------------------------------------------------------------------------------------------------------------------
#ifdef __EntityEditorViewController__SUBCLASSES__PROTECTED__

@property (nonatomic, strong) NSManagedObjectContext *moContext;
@property (nonatomic, strong) MBaseEntity *associatedEntity;
@property (nonatomic, assign) BOOL wasNewAdded;



- (void) initWithEntity:(MBaseEntity *)entity moContext:(NSManagedObjectContext *)moContext;

- (UIModalTransitionStyle) _editorTransitionStyle;
- (NSString *) _editorTitle;
- (void) _nullifyEditor;

- (void) _rotateView:(UIView *)view;
- (void) _createTagsViewContent:(UIView *)view categories:(NSSet *)categories nextView:(UIView *)nextView;

- (NSString *) _validateFields;
- (void) _setFieldValuesFromEntity;
- (void) _setEntityFromFieldValues;

- (NSArray *) _tbItemsDefaultOthers;
- (NSArray *) _tbItemsForEditingOthers;
- (void) _disableFieldsFromEditing;
- (void) _enableFieldsForEditing;


#endif




@end
