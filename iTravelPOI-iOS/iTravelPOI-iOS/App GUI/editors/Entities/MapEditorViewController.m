//
//  MapEditorViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __MapEditorViewController__IMPL__
#define __EntityEditorViewController__SUBCLASSES__PROTECTED__

#import <QuartzCore/QuartzCore.h>
#import "MapEditorViewController.h"

#import "MMap.h"

#import "UIView+FirstResponder.h"
#import "UIPlaceHolderTextView.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface MapEditorViewController() <UITextFieldDelegate, UITextViewDelegate>


@property (nonatomic, assign) IBOutlet UITextField *fName;
@property (nonatomic, assign) IBOutlet UIPlaceHolderTextView *fSummary;
@property (nonatomic, assign) IBOutlet UILabel *fExtraInfo;


@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation MapEditorViewController




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (MapEditorViewController *) editor {
    
    MapEditorViewController *me = [[MapEditorViewController alloc] initWithNibName:@"MapEditorViewController" bundle:nil];
    return me;
}




//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Establece el valor del placeholder del editor del sumario
    self.fSummary.placeholder = @"Summary goes here";
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return TRUE;
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (NSString *) _editorTitle {
        return @"Map Editor";
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _setFieldValuesFromEntity:(MBaseEntity *)entity {
    
    MMap *map = (MMap *)entity;
    
    self.fName.text = map.name;
    self.fSummary.text = map.summary;
    self.fExtraInfo.text = [NSString stringWithFormat:@"Published:\t%@\nUpdated:\t%@\nETAG:\t%@",
                            [MBaseEntity stringFromDate:map.creationTime],
                            [MBaseEntity stringFromDate:map.updateTime],
                            map.etag];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _setEntityFromFieldValues:(MBaseEntity *)entity {

    MMap *map = (MMap *)entity;

    
    // *** CONTROL DE SEGURIDAD (@name) PARA NO TOCAR MAPAS BUENOS ***
    NSString *name = self.fName.text;
    if([name hasPrefix:@"@"]) {
        map.name = name;
    } else {
        map.name = [NSString stringWithFormat:@"@%@", name];
    }
    map.summary = self.fSummary.text;
    [map markAsModified];
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) _tbItemsForEditingOthers {
    return nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _enableFieldsForEditing {

    self.fName.enabled = YES;
    self.fSummary.editable = YES;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _disableFieldsFromEditing {

    self.fName.enabled = NO;
    self.fSummary.editable = NO;
}


@end

