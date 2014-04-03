//
//  TagFilterViewController.m
//  iTravelPoint-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __TagFilterViewController__IMPL__
#import "TagFilterViewController.h"
#import "TagTreeTableViewController.h"
#import "TopViewController.h"
#import "Util_Macros.h"
#import "UIViewController+Storyboard.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define TAGFILTER_X_POS 60.0




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface TagFilterViewController ()

@property (weak, nonatomic) IBOutlet    NSLayoutConstraint                      *tagsLeftConstraint;
@property (weak, nonatomic) IBOutlet    NSLayoutConstraint                      *tagsWidthConstraint;
@property (weak, nonatomic) IBOutlet    UIView                                  *tableView;

@property (strong, nonatomic)           TagTreeTableViewController              *tagTableVC;
@property (weak, nonatomic)             id<TagTreeTableViewControllerDelegate>  tagTreeDelegate;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation TagFilterViewController


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (TagFilterViewController *) createInstanceWithDelegate:(id<TagTreeTableViewControllerDelegate>) tagTreeDelegate {
    
    // Crea una instancia a partir del storyboard
    TagFilterViewController *me = (TagFilterViewController *)[UIViewController instantiateViewControllerFromStoryboardWithID:@"TagFilterViewController"];
        
    // Copia los valores pasados
    me.tagTreeDelegate = tagTreeDelegate;

    // Ocupa todo el area del padre y se añade como hija
    [TopViewController addChildViewController:me];
    
    return me;
}



//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) setTagList:(NSSet *)tagList selectedTags:(NSSet *)selectedTags expandedTags:(NSSet *)expandedTags {
    [self.tagTableVC setTagList:tagList selectedTags:selectedTags expandedTags:expandedTags];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) toggleShowFilter {
    
    if(self.view.hidden) {
        [self _showFilter];
    } else {
        [self _hideFilterFast:FALSE];
    }
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
    }
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.hidden = TRUE;
    self.tagsLeftConstraint.constant = self.view.bounds.size.width;
    self.tagsWidthConstraint.constant = self.view.bounds.size.width-TAGFILTER_X_POS;
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTagFilterPan:)];
    [self.view addGestureRecognizer:panRecognizer];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    self.view.frame = self.view.superview.bounds;
    self.tagsLeftConstraint.constant = TAGFILTER_X_POS;
    self.tagsWidthConstraint.constant = self.view.bounds.size.width-TAGFILTER_X_POS;
    [self.view layoutIfNeeded];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"tagListTree"])
    {
        // Get reference to the destination view controller
        self.tagTableVC = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        self.tagTableVC.delegate = self.tagTreeDelegate;
    }
}





//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (void)handleTagFilterPan:(UIPanGestureRecognizer *)recognizer {
    
    if(recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [recognizer translationInView:recognizer.view];
        CGFloat newValue = MAX(TAGFILTER_X_POS, self.tagsLeftConstraint.constant + translation.x);
        self.tagsLeftConstraint.constant = newValue;
        
        [recognizer setTranslation:CGPointMake(0, 0) inView:recognizer.view];
        
    } else {
        
        CGPoint velocity = [recognizer velocityInView:recognizer.view];
        if(velocity.x>0) {
            [self _hideFilterFast:TRUE];
        } else {
            [self _showFilter];
        }
        
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _showFilter {
    
    self.view.frame = self.view.superview.bounds;
    self.tagsLeftConstraint.constant = self.view.bounds.size.width;
    self.tagsWidthConstraint.constant = self.view.bounds.size.width-TAGFILTER_X_POS;
    [self.view layoutIfNeeded];
    
    self.view.hidden = FALSE;
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
                         self.tagsLeftConstraint.constant = TAGFILTER_X_POS;
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                     }];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _hideFilterFast:(BOOL)fast {
    
    [UIView animateWithDuration:fast ? 0.15 : 0.35
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.backgroundColor = [UIColor clearColor];
                         self.tagsLeftConstraint.constant = self.view.bounds.size.width;
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         self.view.hidden = TRUE;
                     }];
}



@end
