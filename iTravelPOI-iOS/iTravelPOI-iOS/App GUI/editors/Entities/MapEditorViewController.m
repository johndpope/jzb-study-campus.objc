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
#import "NSManagedObjectContext+Utils.h"

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
+ (MapEditorViewController *) editorWithNewMapInContext:(NSManagedObjectContext *)moContext {
    
    // Crea un contexto hijo en el que crea una entidad vacia que empezara a editar
    NSManagedObjectContext *childContext = moContext.childContext;
    MMap *newMap=[MMap emptyMapWithName:@"" inContext:childContext];
    
    // Crea el editor desde el NIB y lo inicializa con la entidad (y contexto) especificada
    MapEditorViewController *me = [MapEditorViewController editorWithMap:newMap moContext:childContext];
    me.wasNewAdded = YES;
    
    // Retorna el editor sobre la entidad recien creada comenzando en modo de edicion
    return me;
}

//---------------------------------------------------------------------------------------------------------------------
+ (MapEditorViewController *) editorWithMap:(MMap *)map moContext:(NSManagedObjectContext *)moContext {

    // Crea el editor desde el NIB y lo inicializa con la entidad (y contexto) especificada
    MapEditorViewController *me = [[MapEditorViewController alloc] initWithNibName:@"MapEditorViewController" bundle:nil];
    [me initWithEntity:map moContext:moContext];
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
- (MMap *) map {
    return (MMap *)self.entity;
}



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (NSString *) _editorTitle {
        return @"Map Information";
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) _validateFields {
    
    self.fName.text = [self.fName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(self.fName.text.length == 0) {
        return @"Name can't be empty";
    }
    return nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _setFieldValuesFromEntity {
    
    self.fName.text = self.map.name;
    self.fSummary.text = self.map.summary;
    self.fExtraInfo.text = [NSString stringWithFormat:@"Published:\t%@\nUpdated:\t%@\nETAG:\t%@",
                            [MBaseEntity stringFromDate:self.map.creationTime],
                            [MBaseEntity stringFromDate:self.map.updateTime],
                            self.map.etag];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _setEntityFromFieldValues {

    // **********************************************************************
    // Proteccion añadiendo una @ al nombre del mapa que se va ha crear
    // **********************************************************************
    if(self.wasNewAdded) {
        self.fName.text = [NSString stringWithFormat:@"@%@",self.fName.text];
    }
    // **********************************************************************

    
    
    self.map.name = self.fName.text;
    self.map.summary = self.fSummary.text;
    [self.map markAsModified];
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) _tbItemsForEditingOthers {
    return nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _enableFieldsForEditing {
    
    self.fName.enabled = YES;
    self.fSummary.editable = YES;
    
    // **********************************************************************
    // Proteccion haciendo que no se pueda editar el nombre
    // **********************************************************************
    if(!self.wasNewAdded && ![self.fName.text hasPrefix:@"@"]) {
        self.fName.enabled = NO;
    }
    // **********************************************************************
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _disableFieldsFromEditing {

    self.fName.enabled = NO;
    self.fSummary.editable = NO;
}


@end

