//
//  SortOptionsController.h
//  iTravelPOI
//
//  Created by JZarzuela on 11/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ModelService.h"
#import <UIKit/UIKit.h>



//*********************************************************************************************************************
#pragma mark -
#pragma mark SortOptionsController interface definition
//---------------------------------------------------------------------------------------------------------------------
@protocol SortOptionsControllerDelegate <NSObject>

- (void) sortMethodSelected:(ME_SORTING_METHOD)sortedBy;

@end  



//*********************************************************************************************************************
#pragma mark -
#pragma mark SortOptionsController interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface SortOptionsController : UIViewController


@property (nonatomic, assign) id<SortOptionsControllerDelegate> delegate;


@end
