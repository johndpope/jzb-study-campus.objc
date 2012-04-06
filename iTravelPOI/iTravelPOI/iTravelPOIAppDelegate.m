//
//  iTravelPOIAppDelegate.m
//  iTravelPOI
//
//  Created by jzarzuela on 18/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "iTravelPOIAppDelegate.h"
#import "ModelService.h"



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation iTravelPOIAppDelegate


@synthesize window=_window;
@synthesize navigationController=_navigationController;



//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [super dealloc];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)awakeFromNib
{
    
    // Inicializa la persistencia de los datos
    NSManagedObjectContext *ctx = [[ModelService sharedInstance] initContext];
    if(!ctx) {
        NSLog(@"Error: data core can't be initialized");
    }
    [ctx release];

}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Add the navigation controller's view to the window and display.
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

//---------------------------------------------------------------------------------------------------------------------
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

//---------------------------------------------------------------------------------------------------------------------
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

//---------------------------------------------------------------------------------------------------------------------
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

//---------------------------------------------------------------------------------------------------------------------
- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
}


@end
