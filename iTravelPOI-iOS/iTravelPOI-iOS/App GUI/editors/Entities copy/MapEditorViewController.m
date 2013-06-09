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


@property (nonatomic, assign) IBOutlet UITextField *nameField;
@property (nonatomic, assign) IBOutlet UIPlaceHolderTextView *summaryField;
@property (nonatomic, assign) IBOutlet UILabel *extraInfo;


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
    self.summaryField.placeholder = @"Summary goes here";
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
- (MMap *) map {
    return (MMap *)self.entity;
}



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (NSString *) _editorTitle {
        return @"Map Editor";
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _setFieldValuesFromEntity {
    
    self.nameField.text = self.map.name;
    self.summaryField.text = self.map.summary;
    self.extraInfo.text = [NSString stringWithFormat:@"Published:\t%@\nUpdated:\t%@\nETAG:\t%@",
                                       [MBaseEntity stringFromDate:self.map.creationTime],
                                       [MBaseEntity stringFromDate:self.map.updateTime],
                                       self.map.etag];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _setEntityFromFieldValues {

    // *** CONTROL DE SEGURIDAD (@name) PARA NO TOCAR MAPAS BUENOS ***
    NSString *name = self.nameField.text;
    if([name hasPrefix:@"@"]) {
        self.map.name = name;
    } else {
        self.map.name = [NSString stringWithFormat:@"@%@", name];
    }
    self.map.summary = self.summaryField.text;
    [self.map markAsModified];
}



@end

