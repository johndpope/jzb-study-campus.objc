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
- (void) modalEditEntity:(MBaseEntity *)entity target:(UIViewController *)target confirm:(SEL)confirm;



//=====================================================================================================================
#pragma mark -
#pragma mark SUBCLASSES PROTECTED methods
//---------------------------------------------------------------------------------------------------------------------
#ifdef __EntityEditorViewController__SUBCLASSES__PROTECTED__

@property (nonatomic, strong) NSManagedObjectContext *moContext;

- (NSString *) _editorTitle;
- (void) _nullifyEditor;
- (void) _rotateImageField:(UIImageView *)imgField;


#endif




@end
