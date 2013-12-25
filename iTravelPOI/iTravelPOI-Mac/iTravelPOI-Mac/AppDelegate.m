//
//  AppDelegate.m
//  iTravelPOI-Mac
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import "AppDelegate.h"

#import "BaseCoreDataService.h"
#import "MockUp.h"
#import "DDTTYLogger.h"




// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface AppDelegate()
@end


// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation AppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;


// =====================================================================================================================
#pragma mark -
#pragma mark <NSApplicationDelegate> methods
// ---------------------------------------------------------------------------------------------------------------------
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    // Establece un gestor especial de excepciones
    NSSetUncaughtExceptionHandler(&_uncaughtExceptionHandler);
    
    // Inicializa el sistema de logging
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // Inicializa el modelo de datos
    [self _initDataModel];
    
    
    // Hace unas pruebas minimas
    [MockUp listModel];
    
    
    // Se crea la ventana y controller inicial de la aplicación
    //////self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //////UIViewController *controller = [ItemListViewController itemListViewControllerWithContext:BaseCoreDataService.moContext];
    //UIViewController *controller = [TestViewController startTestController];
    //UIViewController *controller = [GMapSyncViewController gmapSyncViewController];
    
    //////self.window.rootViewController = controller;
    //////[self.window makeKeyAndVisible];
    
    //////return YES;
}


// ------------------------------------------------------------------------------------------------------------------
// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "com.zetLabs.iTravelPOI_Mac" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.zetLabs.iTravelPOI_Mac"];
}



// ------------------------------------------------------------------------------------------------------------------
// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}


// ------------------------------------------------------------------------------------------------------------------
// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
}


// ------------------------------------------------------------------------------------------------------------------
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    return NSTerminateNow;
}


// =====================================================================================================================
#pragma mark -
#pragma mark Private methods
// ---------------------------------------------------------------------------------------------------------------------
void _uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}


// ---------------------------------------------------------------------------------------------------------------------
- (void) _initDataModel {
    
    // ---------------------------------------
    // ---------------------------------------
    [MockUp resetModel:@"iTravelPOI"];
    // ---------------------------------------
    // ---------------------------------------
    
    
    if(![BaseCoreDataService initCDStack:@"iTravelPOI-Model"]) {
        abort();
    }
    
    
    // ---------------------------------------
    // ---------------------------------------
    [MockUp populateModel];
    // ---------------------------------------
    // ---------------------------------------
    
}

@end
