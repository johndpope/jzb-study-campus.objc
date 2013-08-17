//
//  VisualMapEditorViewController.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>



//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************
typedef void (^VMapCloseCallback)(CLLocationCoordinate2D coord);
typedef void (^VMapModifiedCallback)(void);





//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface VisualMapEditorViewController : UIViewController



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (VisualMapEditorViewController *) editCoordinates:(CLLocationCoordinate2D)coord title:(NSString *)title image:(UIImage *)image controller:(UIViewController *)controller closeCallback:(VMapCloseCallback)closeCallback;
+ (VisualMapEditorViewController *) showPointsWithNoEditing:(NSArray *)points controller:(UIViewController *)controller;
+ (VisualMapEditorViewController *) showPoints:(NSArray *)points withContext:(NSManagedObjectContext *)moContext controller:(UIViewController *)controller modifiedCallback:(VMapModifiedCallback)modifiedCallback;


@end

