//
//  MyImageView.m
//  iTravelPOI
//
//  Created by jzarzuela on 02/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MyImageView.h"



@implementation MyImageView

@synthesize delegate2 = _delegate2;


//---------------------------------------------------------------------------------------------------------------------
// Handles the start of a touch
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    NSLog(@"ya 1");
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {  
    [super touchesMoved:touches withEvent:event];
    NSLog(@"ya 2");
}

// Handles the end of a touch event.
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    NSLog(@"ya 3");
    
    if(self.delegate2) {
        UITouch *end = [[event allTouches] anyObject];
        CGPoint EndPoint = [end locationInView:self];
        NSLog(@"end ponts x : %f y : %f", EndPoint.x, EndPoint.y);
        NSLog(@"end ponts x : %f y : %f", floor(EndPoint.x/45), floor(EndPoint.y/45));
        
        CGRect rect = {3+45*floor(EndPoint.x/45), 2+45*floor(EndPoint.y/45), 45, 45};
        CGImageRef imageRef = CGImageCreateWithImageInRect(self.image.CGImage, rect);
        UIImage *img = [[UIImage alloc] initWithCGImage:imageRef];
        CGImageRelease(imageRef);
        [self.delegate2 setSelectedImage:img];
    }
    
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    NSLog(@"ya 4");
}


//---------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
