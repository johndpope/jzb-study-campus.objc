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
#define ICON_OFFSET 2.5
#define ICON_SIZE 45.0
#define ICONS_PER_ROW 7
#define ICON_ROWS 14



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface IconEditorViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar    *navBar;
@property (weak, nonatomic) IBOutlet UIImageView        *iconImage;
@property (weak, nonatomic) IBOutlet UIScrollView       *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView        *allGMapIconsImage;

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

    [self _updateFieldsFromIcon];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    int row = [self _calcIconIndex] / ICONS_PER_ROW;
    CGFloat yPos = ICON_OFFSET + ICON_SIZE * row;
    [self.scrollView scrollRectToVisible:CGRectMake(0, yPos, ICON_SIZE, ICON_SIZE) animated:YES];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];

    self.scrollView.contentInset = (UIEdgeInsets){self.navBar.frame.size.height,0,0,0};
    self.scrollView.contentSize = self.allGMapIconsImage.frame.size;
    
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

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)allIconsImageTapped:(UITapGestureRecognizer *)sender {
    
    CGPoint EndPoint = [sender locationInView:self.scrollView];
    
    int xPos = floor((EndPoint.x-ICON_OFFSET)/ICON_SIZE);
    int yPos = floor((EndPoint.y-ICON_OFFSET)/ICON_SIZE);
    
    if(xPos>=0 && xPos<ICONS_PER_ROW && yPos>=0 && yPos<ICON_ROWS) {
        unsigned index = xPos + yPos * ICONS_PER_ROW;
        NSString *iconHREF = [self _calcIconHrefFromIndex:index];
        if(iconHREF) {
            MIcon *newIcon = [MIcon iconForHref:iconHREF inContext:self.icon.managedObjectContext];
            self.icon = newIcon;
            [self _updateFieldsFromIcon];
        }
    }

}


//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _updateFieldsFromIcon {
    
    self.navBar.topItem.title = self.icon.name;
    self.iconImage.image = self.icon.image;
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
