//
//  DataListWindowController.h
//  iTravelPOI-Mac
//
//  Created by Jose Zarzuela on 30/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GroupEditWindowController.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public enumerations & definitions
//---------------------------------------------------------------------------------------------------------------------





//*********************************************************************************************************************
#pragma mark -
#pragma mark DataListWindowController interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface DataListWindowController : NSWindowController <NSTableViewDelegate, NSTableViewDataSource, GroupEditorDelegate>


@property (weak) IBOutlet NSTableView *dataTable;
@property (weak) IBOutlet NSButton *goBackButton;
@property (weak) IBOutlet NSTextField *groupLabel;


//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------


@end
