//
//  PointsControllerProtocol.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 15/02/14.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPoint.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Protocol Enumerations & definitions
//*********************************************************************************************************************



//*********************************************************************************************************************
#pragma mark -
#pragma mark PointsControllerDelegate Public protocol definition
//*********************************************************************************************************************
@protocol PointsControllerDelegate <NSObject>

@property (weak, readonly, nonatomic) NSArray *pointList;
@property (strong, readonly, nonatomic) NSMutableSet *selectedPoints;


- (void) editPoint:(MPoint *)point;
- (void) openInExternalApp:(MPoint *)point;

@end

//*********************************************************************************************************************
#pragma mark -
#pragma mark PointsViewerProtocol Public protocol definition
//*********************************************************************************************************************
@protocol PointsViewerProtocol <NSObject>

@property (weak, nonatomic) id<PointsControllerDelegate> delegate;

- (void) pointsHaveChanged;
- (void) startMultiplePointSelection;
- (void) doneMultiplePointSelection;


@end


