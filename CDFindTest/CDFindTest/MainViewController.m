//
//  MainViewController.m
//  CDFindTest
//
//  Created by Jose Zarzuela on 28/07/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"
#import "Model.h"

@interface MainViewController ()

@end

@implementation MainViewController


//------------------------------------------------------------------------------------------------------------------
- (void) _populateModel {
    
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    
    //-------------------------------------------------------
    MGroup *grp1 = [ModelUtils createGroupWithName:@"cat_1" parentGrp:nil];
    MGroup *grp2 = [ModelUtils createGroupWithName:@"cat_2" parentGrp:grp1];
    MGroup *grp3 = [ModelUtils createGroupWithName:@"cat_3" parentGrp:grp1];
    MGroup *grp4 = [ModelUtils createGroupWithName:@"cat_4" parentGrp:grp2];
    MGroup *grp5 = [ModelUtils createGroupWithName:@"cat_5" parentGrp:grp2];
    MGroup *grp6 = [ModelUtils createGroupWithName:@"cat_6" parentGrp:grp3];
    
    //-------------------------------------------------------
    MGroup *grpA = [ModelUtils createGroupWithName:@"cat_A" parentGrp:nil];
    MGroup *grpB = [ModelUtils createGroupWithName:@"cat_B" parentGrp:grpA];
    MGroup *grpC = [ModelUtils createGroupWithName:@"cat_C" parentGrp:grpA];
    MGroup *grpD = [ModelUtils createGroupWithName:@"cat_D" parentGrp:grpB];
    MGroup *grpE = [ModelUtils createGroupWithName:@"cat_E" parentGrp:grpB];
    MGroup *grpF = [ModelUtils createGroupWithName:@"cat_F" parentGrp:grpC];
    
    //-------------------------------------------------------
    MGroup *grpX = [ModelUtils createGroupWithName:@"cat_X" parentGrp:nil];
    
    
    //-------------------------------------------------------
    MPoint *point1 = [ModelUtils createPointWithName:@"point_1"];
    MPoint *point2 = [ModelUtils createPointWithName:@"point_2"];
    MPoint *point3 = [ModelUtils createPointWithName:@"point_3"];
    MPoint *point4 = [ModelUtils createPointWithName:@"point_4"];
    MPoint *point5 = [ModelUtils createPointWithName:@"point_5"];
    
    
    //-------------------------------------------------------
    [ModelUtils updatePoint:point1 withGroups:[NSSet setWithObjects:grp5, grp6, grpE, nil]];
    [ModelUtils updatePoint:point2 withGroups:[NSSet setWithObjects:grp4, nil]];
    [ModelUtils updatePoint:point3 withGroups:[NSSet setWithObjects:grp3, grpB, nil]];
    [ModelUtils updatePoint:point4 withGroups:[NSSet setWithObjects:grp3, grpX, nil]];
    [ModelUtils updatePoint:point5 withGroups:[NSSet setWithObjects:grpA, grpX, nil]];
}


//------------------------------------------------------------------------------------------------------------------
MGroup * _getMGroup(NSString *name) {
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request1 = [NSFetchRequest new];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MGroup" inManagedObjectContext:moc];
    [request1 setEntity:entityDescription];
    
    NSPredicate *query1 = [NSPredicate predicateWithFormat:@"name=%@", name];
    [request1 setPredicate:query1];
    
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request1 error:&error];
    if (array == nil || [array count]<=0) {
        NSLog(@"Error buscando '%@'. Error = '%@'",name, error);
        return nil;
    } else {
        return [array objectAtIndex:0];
    }
}

//------------------------------------------------------------------------------------------------------------------
void _updateFilters(NSMutableDictionary *filters, MGroup *group) {
    
    NSString *rootUID = group.root?group.root.uID:group.uID;
    [filters setObject:group forKey:rootUID];
}

//------------------------------------------------------------------------------------------------------------------
NSArray *_findAssignmentsByFilters(NSMutableDictionary *filters) {
    
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    
    NSPredicate *countNotZero = [NSPredicate predicateWithFormat:@"count>0"];
    
    NSMutableArray *predicates = [NSMutableArray arrayWithObject:countNotZero];
    MGroup *value;
    NSEnumerator *enumerator = [filters objectEnumerator];
    while ((value = [enumerator nextObject])) {
        NSMutableSet *filterGroup = [NSMutableSet setWithObject:value];
        [filterGroup unionSet:value.descendants];
        NSPredicate *groupUIdInSet = [NSPredicate predicateWithFormat:@"(ANY groups IN %@)", filterGroup];
        [predicates addObject:groupUIdInSet];
    }
    
    NSPredicate *query = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    
    
    NSFetchRequest *request = [NSFetchRequest new];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MIntersection" inManagedObjectContext:moc];
    [request setEntity:entityDescription];
    [request setPredicate:query];
    
    
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array == nil) {
        NSLog(@"Error searching assignments - %@", error);
    }
    
    return array;
    
}

//------------------------------------------------------------------------------------------------------------------
- (IBAction)pepe:(UIButton *)sender {
    
    NSLog(@"hola");
    
    //[self _populateModel];
    
    
    MGroup *grp1 = _getMGroup(@"cat_1");
    MGroup *grp2 = _getMGroup(@"cat_B");
    
    NSMutableDictionary *filters = [NSMutableDictionary new];
    //_updateFilters(filters, grp1);
    
    MGroup *selectedGroup = nil;
    
    
    NSMutableArray *viewGroups = [NSMutableArray arrayWithArray:filters];
    [viewGroups removeObject:selectedGroup];
    [viewGroups addObjectsFromArray:[selectedGroup.descendants allObjects]];
    
    NSArray *assigments = _findAssignmentsByFilters(filters);
    
    NSMutableSet *allGroups = [NSMutableSet new];
    
    for(MIntersection *inter in assigments) {
        
        BOOL inFilter = false;
        
        for(MGroup *grp in inter.groups) {
            
            NSString *rootUID = grp.root?grp.root.uID:grp.uID;
            MGroup *grp2 = [filters objectForKey:rootUID];
            
            if(grp2!=nil) {
                if([grp.uID isEqualToString:grp2.uID]) {
                    // Puntos a mostrar. Nada mas con esa asignacion
                    inFilter = true;
                    break;
                }
            }
        }
        
        
    }
    
    for(MGroup *grp in allGroups) {
        NSLog(@"cosa - %@ / %u",grp.name, grp.level);
    }
    
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.flipsidePopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.flipsidePopoverController = popoverController;
            popoverController.delegate = self;
        }
    }
}

- (IBAction)togglePopover:(id)sender
{
    if (self.flipsidePopoverController) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}

@end
