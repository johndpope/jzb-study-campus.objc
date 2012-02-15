//
//  WCDTestAppDelegate.m
//  WCDTest
//
//  Created by jzarzuela on 09/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "WCDTestAppDelegate.h"
#import "ModelService.h"
#import "GMapServiceAsync.h"


#define USER_PREFS_EMAIL    @"userEMail"
#define USER_PREFS_PASSWORD @"userPassword"



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface  WCDTestAppDelegate() {
@private
}

@property (nonatomic, retain) NSString * userEMail;
@property (nonatomic, retain) NSString * userPassword;
@property (nonatomic, retain) NSArray *syncMaps;

@end



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation WCDTestAppDelegate


// ----- OUTLETs -----
@synthesize bi_window = _bi_window;
@synthesize bi_tabs = _bi_tabs;
@synthesize bi_email = _bi_email;
@synthesize bi_password = _bi_password;
@synthesize bi_syncTable = _bi_syncTable;


// ----- Properties -----
@synthesize userEMail = _userEMail;
@synthesize userPassword = _userPassword;
@synthesize syncMaps = _syncMaps;


//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    //    [__managedObjectContext release];
    //    [__persistentStoreCoordinator release];
    //    [__managedObjectModel release];
    
    [[ModelService sharedInstance] doneCDStack];
    [self.userEMail release];
    [self.userPassword release];
    [self.syncMaps release];
    
    [super dealloc];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)awakeFromNib
{
    self.userEMail = [[NSUserDefaults standardUserDefaults] objectForKey:USER_PREFS_EMAIL];
    self.userPassword = [[NSUserDefaults standardUserDefaults] objectForKey:USER_PREFS_PASSWORD];
    
    [[ModelService sharedInstance] initCDStack];
    
    [self.bi_email setDelegate:self];
    [self.bi_password setDelegate:self];
    [self.bi_syncTable setDataSource:self];
    
    if(self.userEMail)
        [self.bi_email setStringValue: self.userEMail];
    if(self.userPassword)
        [self.bi_password setStringValue:self.userPassword];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

//---------------------------------------------------------------------------------------------------------------------
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    
    return NSTerminateNow;
}



//---------------------------------------------------------------------------------------------------------------------
- (void)controlTextDidEndEditing:(NSNotification *)notification {
    if([notification object] == self.bi_email)
    {
        self.userEMail = [self.bi_email stringValue];
        [[NSUserDefaults standardUserDefaults] setObject:self.userEMail forKey:USER_PREFS_EMAIL];
    }
    else {
        self.userPassword = [self.bi_password stringValue];
        [[NSUserDefaults standardUserDefaults] setObject:self.userPassword forKey:USER_PREFS_PASSWORD];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)synchronizeMaps:(id)sender {
    
    [[GMapServiceAsync sharedInstance] loginWithUser:self.userEMail password:self.userPassword];
    [[GMapServiceAsync sharedInstance] fetchUserMapList:^(NSArray *maps, NSError *error) {
        
        if(error==nil) {
            self.syncMaps = maps;
            [self.bi_syncTable reloadData];
            
            if(maps) {
                TMap *map = [maps objectAtIndex:0];
                [[GMapServiceAsync sharedInstance] fetchMapData:map callback:^(TMap *map, NSError *error) {
                    NSLog(@"puntos");
                }];
            }
        }
    }];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [self.syncMaps count];
}

//---------------------------------------------------------------------------------------------------------------------
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    
    TMap *map=[self.syncMaps objectAtIndex:rowIndex];
    return map.name;
}




@end




/****************************************************************************************************************
 
 //---------------------------------------------------------------------------------------------------------------------
 //
 //Returns the directory the application uses to store the Core Data store file. This code uses a directory named "WCDTest" in the user's Library directory.
 //
 - (NSURL *)applicationFilesDirectory {
 
 NSFileManager *fileManager = [NSFileManager defaultManager];
 NSURL *libraryURL = [[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
 return [libraryURL URLByAppendingPathComponent:@"WCDTest"];
 }
 
 
 //---------------------------------------------------------------------------------------------------------------------
 //
 //Creates if necessary and returns the managed object model for the application.
 //
 - (NSManagedObjectModel *)managedObjectModel {
 if (__managedObjectModel) {
 return __managedObjectModel;
 }
 
 NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"WCDTest" withExtension:@"momd"];
 __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
 return __managedObjectModel;
 }
 
 
 //---------------------------------------------------------------------------------------------------------------------
 //
 //Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
 //
 - (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
 if (__persistentStoreCoordinator) {
 return __persistentStoreCoordinator;
 }
 
 NSManagedObjectModel *mom = [self managedObjectModel];
 if (!mom) {
 NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
 return nil;
 }
 
 NSFileManager *fileManager = [NSFileManager defaultManager];
 NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
 NSError *error = nil;
 
 NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:&error];
 
 if (!properties) {
 BOOL ok = NO;
 if ([error code] == NSFileReadNoSuchFileError) {
 ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
 }
 if (!ok) {
 [[NSApplication sharedApplication] presentError:error];
 return nil;
 }
 }
 else {
 if ([[properties objectForKey:NSURLIsDirectoryKey] boolValue] != YES) {
 // Customize and localize this error.
 NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]]; 
 
 NSMutableDictionary *dict = [NSMutableDictionary dictionary];
 [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
 error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
 
 [[NSApplication sharedApplication] presentError:error];
 return nil;
 }
 }
 
 NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"WCDTest.storedata"];
 __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
 if (![__persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
 [[NSApplication sharedApplication] presentError:error];
 [__persistentStoreCoordinator release], __persistentStoreCoordinator = nil;
 return nil;
 }
 
 return __persistentStoreCoordinator;
 }
 
 
 //---------------------------------------------------------------------------------------------------------------------
 //
 // Returns the managed object context for the application (which is already
 // bound to the persistent store coordinator for the application.) 
 //
 - (NSManagedObjectContext *) managedObjectContext {
 if (__managedObjectContext) {
 return __managedObjectContext;
 }
 
 NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
 if (!coordinator) {
 NSMutableDictionary *dict = [NSMutableDictionary dictionary];
 [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
 [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
 NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
 [[NSApplication sharedApplication] presentError:error];
 return nil;
 }
 __managedObjectContext = [[NSManagedObjectContext alloc] init];
 [__managedObjectContext setPersistentStoreCoordinator:coordinator];
 
 return __managedObjectContext;
 }
 
 
 //---------------------------------------------------------------------------------------------------------------------
 //
 // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
 //
 - (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
 return [[self managedObjectContext] undoManager];
 }
 
 
 //---------------------------------------------------------------------------------------------------------------------
 //
 // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
 //
 - (IBAction) saveAction:(id)sender {
 NSError *error = nil;
 
 if (![[self managedObjectContext] commitEditing]) {
 NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
 }
 
 if (![[self managedObjectContext] save:&error]) {
 [[NSApplication sharedApplication] presentError:error];
 }
 }
 
 
 //---------------------------------------------------------------------------------------------------------------------
 - (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
 
 // Save changes in the application's managed object context before the application terminates.
 
 if (!__managedObjectContext) {
 return NSTerminateNow;
 }
 
 if (![[self managedObjectContext] commitEditing]) {
 NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
 return NSTerminateCancel;
 }
 
 if (![[self managedObjectContext] hasChanges]) {
 return NSTerminateNow;
 }
 
 NSError *error = nil;
 if (![[self managedObjectContext] save:&error]) {
 
 // Customize this code block to include application-specific recovery steps.              
 BOOL result = [sender presentError:error];
 if (result) {
 return NSTerminateCancel;
 }
 
 NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
 NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
 NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
 NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
 NSAlert *alert = [[NSAlert alloc] init];
 [alert setMessageText:question];
 [alert setInformativeText:info];
 [alert addButtonWithTitle:quitButton];
 [alert addButtonWithTitle:cancelButton];
 
 NSInteger answer = [alert runModal];
 [alert release];
 alert = nil;
 
 if (answer == NSAlertAlternateReturn) {
 return NSTerminateCancel;
 }
 }
 
 return NSTerminateNow;
 }
 ****************************************************************************************************************/
