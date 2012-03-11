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
#define ICON_OFFSET 2.5
#define ICON_SIZE 45.0
#define ICONS_PER_ROW 7
#define ICON_ROWS 14



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
- (void) scrollToSelectedIcon:(NSString *) url;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark GMapIconEditor PRIVATE interface definition
//---------------------------------------------------------------------------------------------------------------------
@implementation GMapIconEditor


@synthesize selectedImage = _selectedImage;
@synthesize allIconsImage = _allIconsImage;
@synthesize scrollView = _scrollView;

@synthesize gmapIcon = _gmapIcon;
@synthesize delegate = _delegate;



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
    
    [_gmapIcon release];
    
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
    
    self.scrollView.contentSize = CGSizeMake(320, 645); //self.allIconsImage.frame.size;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"GMapIconEditorBg.png"]];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidUnload
{
    [self setSelectedImage:nil];
    [self setScrollView:nil];
    [self setAllIconsImage:nil];
    
    [self setGmapIcon:nil];
    [self setDelegate:nil];
    
    [super viewDidUnload];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.selectedImage.image = self.gmapIcon.image;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self scrollToSelectedIcon:self.gmapIcon.url];
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
    
    if(self.delegate) {
        [self.delegate saveNewIcon:self iconToSave:self.gmapIcon];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)imageTappedAction:(id)sender {
    
    
    // Esto hace falta porque el TapGestureRecognized se ha puesto al nivel de toda la vista
    // porque, por alguna razon, no reconocia las ultimas filas (del tamaño de la "solapa" superior)
    CGPoint EndPoint = [sender locationInView:self.allIconsImage];
    
    if(EndPoint.y >= self.scrollView.contentOffset.y) {
        int xPos = floor((EndPoint.x-ICON_OFFSET)/ICON_SIZE);
        int yPos = floor((EndPoint.y-ICON_OFFSET)/ICON_SIZE);
        
        if(xPos>=0 && xPos<ICONS_PER_ROW && yPos>=0 && yPos<ICON_ROWS) {
            unsigned index = xPos + yPos * ICONS_PER_ROW;
            NSString *url = [self urlFromIndex:index];
            
            self.gmapIcon = [GMapIcon iconForURL:url];
            self.selectedImage.image = self.gmapIcon.image;
            
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }
    
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
    
    if(index < [indexForURL count])
        return [indexForURL objectAtIndex:index];
    else
        return  nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) scrollToSelectedIcon:(NSString *) url {
    
    if(url) {
        if(urlForIndex==nil) {
            [self loadGMapIconInfoList];
        }
        
        NSNumber *index = nil;
        index = [urlForIndex valueForKey:url];
        if(index) {
            unsigned yPos = ICON_OFFSET + ICON_SIZE * [index unsignedIntValue] / ICONS_PER_ROW;
            [self.scrollView scrollRectToVisible:CGRectMake(0, yPos, ICON_SIZE, ICON_SIZE) animated:YES];
        }
    }
}

@end
