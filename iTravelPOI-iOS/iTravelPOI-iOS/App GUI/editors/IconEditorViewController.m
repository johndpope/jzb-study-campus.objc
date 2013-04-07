//
//  IconEditorViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __IconEditorViewController__IMPL__

#import <QuartzCore/QuartzCore.h>

#import "IconEditorViewController.h"
#import "ImageManager.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define ICON_OFFSET 2.5
#define ICON_SIZE 45.0
#define ICONS_PER_ROW 7
#define ICON_ROWS 14





//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface IconEditorViewController() <UITextFieldDelegate, UITextViewDelegate>


@property (nonatomic, assign) IBOutlet UILabel *nameField;
@property (nonatomic, assign) IBOutlet UIImageView *iconImageField;
@property (nonatomic, assign) IBOutlet UIImageView *allIconsImageField;

@property (nonatomic, assign) IBOutlet UIScrollView *contentScrollView;

@property (nonatomic, assign) UIViewController<IconEditorDelegate> *delegate;


@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation IconEditorViewController




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (IconEditorViewController *) startEditingIcon:(NSString *)iconBaseHREF delegate:(UIViewController<IconEditorDelegate> *)delegate {

    if(iconBaseHREF!=nil && delegate!=nil) {
        IconEditorViewController *me = [[IconEditorViewController alloc] initWithNibName:@"IconEditorViewController" bundle:nil];
        me.delegate = delegate;
        me.iconBaseHREF = iconBaseHREF;
        me.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [delegate presentViewController:me animated:YES completion:nil];
        return me;
    } else {
        DDLogVerbose(@"Warning: IconEditorViewController-startEditingMap called with nil IconBaseHREF or Delegate");
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
    
    // Actualiza los campos desde la entidad a editar
    self.contentScrollView.contentSize = CGSizeMake(self.allIconsImageField.frame.size.width, self.allIconsImageField.frame.size.height);
    [self _setFieldValuesFromEntity];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated {
    
    // Set properties to nil
    //self.delegate = nil;
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
#pragma mark BIAction methods
//---------------------------------------------------------------------------------------------------------------------
- (IBAction)okAction:(UIButton *)sender {
    if([self.delegate closeIconEditor:self]) {
        [self _dismissEditor];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)iconImageTapAction:(UITapGestureRecognizer *)sender {
    
    if(sender.state == UIGestureRecognizerStateEnded) {
        
        CGPoint EndPoint = [sender locationInView:self.contentScrollView];

        if(EndPoint.y >= self.contentScrollView.contentOffset.y) {
            int xPos = floor((EndPoint.x-ICON_OFFSET)/ICON_SIZE);
            int yPos = floor((EndPoint.y-ICON_OFFSET)/ICON_SIZE);
            
            if(xPos>=0 && xPos<ICONS_PER_ROW && yPos>=0 && yPos<ICON_ROWS) {
                unsigned index = xPos + yPos * ICONS_PER_ROW;
                NSString *iconHREF = [self _iconHrefFromIndex:index];
                if(iconHREF) {
                    self.iconBaseHREF = iconHREF;
                    [self _setFieldValuesFromEntity];
                }
            }
        }
    }
}



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _dismissEditor {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _setFieldValuesFromEntity {
    
    IconData *icon = [ImageManager iconDataForHREF:self.iconBaseHREF];
    self.nameField.text = icon.shortName;
    self.iconImageField.image = icon.image;
    
    int row = [self _iconIndexFromHREF:self.iconBaseHREF] / ICONS_PER_ROW;
    CGFloat yPos = ICON_OFFSET + ICON_SIZE * row;
    [self.contentScrollView scrollRectToVisible:CGRectMake(0, yPos, ICON_SIZE, ICON_SIZE) animated:YES];
}


//---------------------------------------------------------------------------------------------------------------------
- (NSString *) _iconHrefFromIndex:(unsigned) index {
    
    static __strong NSArray *_indexToHref = nil;
    
    if(_indexToHref==nil) {
        [self _loadIconsIndexToHREF:&_indexToHref AndHrefToIndex:nil];
    }
    
    if(index < [_indexToHref count])
        return [_indexToHref objectAtIndex:index];
    else
        return  nil; //?????SEGURO????
}


//---------------------------------------------------------------------------------------------------------------------
- (unsigned) _iconIndexFromHREF:(NSString *)iconBaseHREF {
    
    static __strong NSDictionary *_hrefToIndex = nil;
    
    if(_hrefToIndex==nil) {
        [self _loadIconsIndexToHREF:nil AndHrefToIndex:&_hrefToIndex];
    }
    
    NSNumber *index = [_hrefToIndex objectForKey:iconBaseHREF];
    return [index unsignedIntValue];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _loadIconsIndexToHREF:(NSArray * __strong *)indexToHREF AndHrefToIndex:(NSDictionary * __strong *)hrefToIndex {
    
    static __strong NSMutableDictionary *_urlForIndex = nil;
    static __strong NSMutableArray *_indexForURL = nil;
    
    if(_indexForURL==nil || _urlForIndex==nil) {

        _indexForURL = [NSMutableArray array];
        _urlForIndex = [NSMutableDictionary dictionary];
        
        NSString *thePath = [[NSBundle mainBundle] pathForResource:@"allGMapIconsInfo" ofType:@"plist"];
        NSDictionary *iconsInfo = [NSDictionary dictionaryWithContentsOfFile:thePath];
        NSArray *iconsData = [iconsInfo valueForKey:@"iconsData"];
        
        unsigned index = 0;
        for(NSDictionary *iconData in iconsData) {
            NSString *iconURL = [iconData valueForKey:@"url"];
            NSNumber *cIndex = [NSNumber numberWithUnsignedInt:index++];
            
            [_indexForURL addObject:iconURL];
            [_urlForIndex setValue:cIndex forKey:iconURL];
        }
    }
    
    if(indexToHREF) *indexToHREF = _indexForURL;
    if(hrefToIndex) *hrefToIndex = _urlForIndex;
}



@end

