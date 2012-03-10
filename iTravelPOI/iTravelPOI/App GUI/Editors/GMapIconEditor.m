//
//  GMapIconEditor.m
//  iTravelPOI
//
//  Created by JZarzuela on 10/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GMapIconEditor.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
//---------------------------------------------------------------------------------------------------------------------
#define ICON_SIZE 45.0
#define ICONS_PER_ROW 7



//*********************************************************************************************************************
#pragma mark -
#pragma mark MapEditorController PRIVATE interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface GMapIconEditor() 


@property (retain, nonatomic) IBOutlet UIImageView *selectedImage;
@property (retain, nonatomic) IBOutlet UIImageView *allIconsImage;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;


- (IBAction)saveAction:(id)sender;

- (void) loadGMapIconInfoList;
- (NSString *) urlFromIndex:(unsigned) index;
- (unsigned) indexFromURL:(NSString *) url;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark GMapIconEditor PRIVATE interface definition
//---------------------------------------------------------------------------------------------------------------------
@implementation GMapIconEditor


@synthesize selectedImage = _selectedImage;
@synthesize allIconsImage = _allIconsImage;
@synthesize scrollView = _scrollView;



//*********************************************************************************************************************
#pragma mark -
#pragma mark initialization & finalization
//---------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc {
    
    [_selectedImage release];
    [_scrollView release];
    [_allIconsImage release];
    
    [super dealloc];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}




//*********************************************************************************************************************
#pragma mark -
#pragma mark View lifecycle
//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Creamos el boton para salvar el nuevo icono
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                              target:self
                                                                              action:@selector(saveAction:)];
    saveBtn.enabled = NO;
    self.navigationItem.rightBarButtonItem=saveBtn;
    [saveBtn release];
    
    self.scrollView.contentSize = CGSizeMake(320, 635); //self.allIconsImage.frame.size;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"GMapIconEditorBg.png"]];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidUnload
{
    [self setSelectedImage:nil];
    [self setScrollView:nil];
    [self setAllIconsImage:nil];
    
    [super viewDidUnload];
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


//*********************************************************************************************************************
#pragma mark -
#pragma mark Internal Event Handlers
//---------------------------------------------------------------------------------------------------------------------
- (IBAction)saveAction:(id)sender {
    
    //    if(self.delegate) {
    //    }
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)imageTappedAction:(id)sender {
    
    CGPoint EndPoint = [sender locationInView:self.allIconsImage];

    NSLog(@"%f,%f",EndPoint.x,EndPoint.y);
    /*
    unsigned index = ceil((EndPoint.x-2.5)/ICON_SIZE)-1 + ICONS_PER_ROW * (ceil((EndPoint.y-2.5)/ICON_SIZE)-1);
    NSString *url = [self urlFromIndex:index];
    NSLog(@"%u %@",index, url);
     */
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE methods
//---------------------------------------------------------------------------------------------------------------------
static NSArray *indexForURL = nil;
static NSDictionary *urlForIndex = nil; 


//---------------------------------------------------------------------------------------------------------------------
- (void) loadGMapIconInfoList {
    
    NSMutableArray *_indexForURL = [[NSMutableArray alloc] init];
    NSMutableDictionary *_urlForIndex = [[NSMutableDictionary alloc] init];
    
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"allGMapIconsInfo" ofType:@"plist"];
    NSDictionary *iconsInfo = [NSDictionary dictionaryWithContentsOfFile:thePath];
    NSArray *iconsData = [iconsInfo valueForKey:@"iconsData"];
    
    unsigned index = 0;
    for(NSDictionary *iconData in iconsData) {
        NSString *url = [iconData valueForKey:@"url"];
        NSNumber *cIndex = [NSNumber numberWithUnsignedInt:index++];
        
        [_indexForURL addObject:url];
        [_urlForIndex setValue:cIndex forKey:url];
    }
    
    if(indexForURL) {
        [indexForURL release];
    }
    indexForURL = _indexForURL;
    
    if(urlForIndex) {
        [urlForIndex release];
    }
    urlForIndex = _urlForIndex;
    
}

//---------------------------------------------------------------------------------------------------------------------
- (NSString *) urlFromIndex:(unsigned) index {
    
    if(indexForURL==nil) {
        [self loadGMapIconInfoList];
    }
    return [indexForURL objectAtIndex:index];
}

//---------------------------------------------------------------------------------------------------------------------
- (unsigned) indexFromURL:(NSString *) url {
    
    if(urlForIndex==nil) {
        [self loadGMapIconInfoList];
    }
    return [(NSNumber *)[urlForIndex valueForKey:url] unsignedIntValue];
}

@end
