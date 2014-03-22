//
//  IconEditorViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __IconEditorViewController__IMPL__
#import <QuartzCore/QuartzCore.h>
#import "IconEditorViewController.h"
#import "UIImage+Tint.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define ICON_SIZE           45.0
#define ICON_OFFSET         2.5
#define NUM_ICONS           98

#define P_ICONS_PER_ROW     7
#define P_ICON_ROWS         14

#define L_ICONS_PER_ROW     20
#define L_ICON_ROWS         5


//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface IconEditorViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar    *navBar;
@property (weak, nonatomic) IBOutlet UIScrollView       *scrollView;
@property (weak, nonatomic)          UIImageView        *allGMapIconsImage;
@property (strong, nonatomic)        UIImageView        *selectionFrame;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation IconEditorViewController


static __strong NSMutableArray         *_indexToHref = nil;
static __strong NSMutableDictionary    *_hrefToIndex = nil;
static __strong NSMutableDictionary    *_nameToIndex = nil;




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------




//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _loadIconsInfoFile];
    }
    return self;
}



//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    [self _setProperAllGMapIconsImage];

    self.selectionFrame = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selectionFrame" burnTint:self.view.tintColor]];
    [self _showSelectionFrame];
    
    [self _updateFieldsFromIcon];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self _scrollToSelectedIcon];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self _setProperAllGMapIconsImage];
    [self _showSelectionFrame];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {

    [super didRotateFromInterfaceOrientation:toInterfaceOrientation];
    [self _scrollToSelectedIcon];
}


//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//---------------------------------------------------------------------------------------------------------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
}


//=====================================================================================================================
#pragma mark -
#pragma mark <IBAction> outlet methods
// ---------------------------------------------------------------------------------------------------------------------
- (IBAction) doneAction:(UIBarButtonItem *)sender {
    
    if([self.delegate respondsToSelector:@selector(iconEditorDone:)]) {
        [self.delegate iconEditorDone:self];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        self.icon = nil;
    }];
}

// ---------------------------------------------------------------------------------------------------------------------
- (IBAction)cancelAction:(UIBarButtonItem *)sender {

    [self dismissViewControllerAnimated:YES completion:^{
        self.icon = nil;
    }];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) allIconsImageTapped:(UITapGestureRecognizer *)sender {
    
    CGPoint EndPoint = [sender locationInView:self.scrollView];
    
    int xPos = floor((EndPoint.x-ICON_OFFSET)/ICON_SIZE);
    int yPos = floor((EndPoint.y-ICON_OFFSET)/ICON_SIZE);
    
    if(xPos>=0 && xPos<([self _isInLandscape] ? L_ICONS_PER_ROW : P_ICONS_PER_ROW) &&
       yPos>=0 && yPos<([self _isInLandscape] ? L_ICON_ROWS : P_ICON_ROWS)) {

        unsigned index = xPos + yPos * ([self _isInLandscape] ? L_ICONS_PER_ROW : P_ICONS_PER_ROW);
        NSString *iconHREF = [self _calcIconHrefFromIndex:index];
        if(iconHREF) {
            MIcon *newIcon = [MIcon iconForHref:iconHREF inContext:self.icon.managedObjectContext];
            self.icon = newIcon;
            [self _updateFieldsFromIcon];
            [self _showSelectionFrame];
        }
        
    }

}


//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _setProperAllGMapIconsImage {
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self _isInLandscape] ? @"allGmapIcons_H" : @"allGmapIcons_V"]];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(allIconsImageTapped:)];
    [imgView addGestureRecognizer:recognizer];
    [imgView setUserInteractionEnabled:TRUE];
    
    [self.allGMapIconsImage removeFromSuperview];
    self.allGMapIconsImage = imgView;
    [self.scrollView addSubview:self.allGMapIconsImage];
    self.scrollView.contentSize = self.allGMapIconsImage.bounds.size;
    self.scrollView.contentInset = (UIEdgeInsets){self.navBar.frame.size.height,0,0,0};
    self.scrollView.contentOffset = CGPointMake(0, -self.navBar.frame.size.height);
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _scrollToSelectedIcon {
    
    CGRect iconRowRect;
    
    if([self _isInLandscape]) {
        int col = [self _calcIconIndex] % L_ICONS_PER_ROW;
        CGFloat xPos = ICON_OFFSET + ICON_SIZE * col;
        iconRowRect = CGRectMake(xPos, 0, ICON_SIZE, ICON_SIZE);
    } else {
        int row = [self _calcIconIndex] / P_ICONS_PER_ROW;
        CGFloat yPos = ICON_OFFSET + ICON_SIZE * row;
        iconRowRect = CGRectMake(0, yPos, ICON_SIZE, ICON_SIZE);
    }
    
    BOOL isFullyVisible = CGRectContainsRect(self.scrollView.bounds, iconRowRect);
    if(!isFullyVisible) {
        [self.scrollView scrollRectToVisible:iconRowRect animated:YES];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _showSelectionFrame {
    
    
    CGSize size = self.selectionFrame.bounds.size;
    
    int index = [self _calcIconIndex];
    
    int col = index % ([self _isInLandscape] ? L_ICONS_PER_ROW : P_ICONS_PER_ROW);
    int row = index / ([self _isInLandscape] ? L_ICONS_PER_ROW : P_ICONS_PER_ROW);
    
    CGFloat xPos = ICON_OFFSET +  col * ICON_SIZE + (ICON_SIZE-size.width)/2;
    CGFloat yPos = ICON_OFFSET +  row * ICON_SIZE + (ICON_SIZE-size.height)/2;
    
    [self.selectionFrame removeFromSuperview];
    self.selectionFrame.frame = CGRectMake(xPos, yPos, size.width, size.height);
    [self.scrollView insertSubview:self.selectionFrame atIndex:0];
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) _isInLandscape {
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    return (orientation==UIDeviceOrientationLandscapeLeft || orientation==UIDeviceOrientationLandscapeRight);
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _updateFieldsFromIcon {
    
    self.navBar.topItem.title = self.icon.name;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSString *) _calcIconHrefFromIndex:(NSUInteger) index {
    
    if(index < _indexToHref.count) {
        return _indexToHref[index];
    } else {
        // @TODO: ¿Como puede ser que el indice sea mayor?
        return  nil; //?????SEGURO????
    }
}


//---------------------------------------------------------------------------------------------------------------------
- (NSUInteger) _calcIconIndex {
    
    NSNumber *index = [_hrefToIndex objectForKey:self.icon.iconHREF];
    if(!index) {
        index = [_nameToIndex objectForKey:self.icon.name];
    }
    return [index unsignedIntValue];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _loadIconsInfoFile {
    
    _indexToHref = [NSMutableArray array];
    _hrefToIndex = [NSMutableDictionary dictionary];
    _nameToIndex = [NSMutableDictionary dictionary];
    
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"allGMapIconsInfo" ofType:@"plist"];
    NSDictionary *iconsInfo = [NSDictionary dictionaryWithContentsOfFile:thePath];
    NSArray *iconsData = [iconsInfo valueForKey:@"iconsData"];
    
    NSInteger index = 0;
    for(NSDictionary *iconData in iconsData) {
        
        NSString *iconHREF = [iconData valueForKey:@"url"];
        NSString *iconName = [MIcon shortnameFromIconHREF:iconHREF];
        NSNumber *cIndex = [NSNumber numberWithUnsignedInt:index++];
        
        [_indexToHref addObject:iconHREF];
        [_hrefToIndex setValue:cIndex forKey:iconHREF];
        [_nameToIndex setValue:cIndex forKey:iconName];
    }
}


@end
