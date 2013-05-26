//
//  LatLngEditorViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __LatLngEditorViewController__IMPL__

#import <QuartzCore/QuartzCore.h>

#import "LatLngEditorViewController.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface LatLngEditorViewController() <UITextFieldDelegate, UITextViewDelegate>


@property (nonatomic, assign) IBOutlet UITextField *latitudeField;
@property (nonatomic, assign) IBOutlet UITextField *longitudeField;
@property (nonatomic, assign) IBOutlet UINavigationBar *navigationBar;

@property (nonatomic, assign) UIViewController<LatLngEditorDelegate> *delegate;
@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, assign) CGFloat longitude;

@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation LatLngEditorViewController




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (LatLngEditorViewController *) startEditingLat:(CGFloat)latitude Lng:(CGFloat)longitude
                                        delegate:(UIViewController<LatLngEditorDelegate> *)delegate {

    if(delegate!=nil) {
        LatLngEditorViewController *me = [[LatLngEditorViewController alloc] initWithNibName:@"LatLngEditorViewController" bundle:nil];
        me.delegate = delegate;
        me.latitude = latitude;
        me.longitude = longitude;
        me.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [delegate presentViewController:me animated:YES completion:nil];
        return me;
    } else {
        DDLogVerbose(@"Warning: LatLngEditorViewController-startEditingMap called with nil Delegate");
        return nil;
    }
}






//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Botones de Save & Cancel
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                         target:self
                                                                                         action:@selector(_btnCloseCancel:)];

    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                         target:self
                                                                                         action:@selector(_btnCloseSave:)];

    self.navigationBar.topItem.leftBarButtonItem = cancelBarButtonItem;
    self.navigationBar.topItem.rightBarButtonItem = saveBarButtonItem;
    
    // Actualiza los campos desde la entidad a editar
    [self _setFieldValuesFromEntity];
}


//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return TRUE;
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
}





//=====================================================================================================================
#pragma mark -
#pragma mark Getter & Setter methods
//---------------------------------------------------------------------------------------------------------------------




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------




//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _dismissEditor {

    [self dismissViewControllerAnimated:YES completion:nil];

    // Set properties to nil
    self.delegate = nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _btnCloseSave:(id)sender {
    
    [self _setEntityValuesFromFields];
    if([self.delegate closeLatLngEditor:self Lat:self.latitude Lng:self.longitude]) {
        [self _dismissEditor];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _btnCloseCancel:(id)sender {
    
    [self _dismissEditor];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _setFieldValuesFromEntity {
    
    self.latitudeField.text = [NSString stringWithFormat:@"%0.06f", self.latitude];
    self.longitudeField.text = [NSString stringWithFormat:@"%0.06f", self.longitude];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _setEntityValuesFromFields {

    self.latitude = [self.latitudeField.text floatValue];
    self.longitude = [self.longitudeField.text floatValue];
}




@end

