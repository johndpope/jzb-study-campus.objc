//
//  TBViewController.m
//  TestBed
//
//  Created by Jose Zarzuela on 05/08/14.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

#import "TBViewController.h"
#import "BaseCoreDataService.h"
#import "TBMaestro.h"
#import "TBDetalle.h"


// *********************************************************************************************************************
#pragma mark -
#pragma mark TBViewController private interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface TBViewController ()

@end


// *********************************************************************************************************************
#pragma mark -
#pragma mark TBViewController implementation
// ---------------------------------------------------------------------------------------------------------------------
@implementation TBViewController

// ---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// ---------------------------------------------------------------------------------------------------------------------
- (IBAction)onTestIt:(id)sender {
    
    NSManagedObjectContext *moContext = [BaseCoreDataService moContext];

    //TBMaestro *maestro = [TBMaestro insertInManagedObjectContext:moContext];
    TBMaestro *maestro = [TBMaestro newWithoutContext];
    maestro.nombre = @"Pepe";
    
    TBDetalle *detalle;
    
    detalle = [maestro newDetalle];
    detalle.nombre = @"detalle 1";

    detalle = [maestro newDetalle];
    detalle.nombre = @"detalle 2";

    [maestro dump];

    [TBMaestro dumpAllInfoInContext:moContext];
    
}


@end
