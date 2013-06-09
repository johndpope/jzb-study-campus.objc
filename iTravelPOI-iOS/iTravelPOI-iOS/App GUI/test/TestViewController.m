//
//  TestViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __TestViewController__IMPL__
#import "TestViewController.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface TestViewController() <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *browser;

@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation TestViewController




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (TestViewController *) startTestController {

    TestViewController *me = [[TestViewController alloc] initWithNibName:@"TestViewController" bundle:nil];
    return me;
}






//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIImage *img1 = [UIImage imageNamed:@"shadowedBox"];
    UIImage *img2 = [img1 resizableImageWithCapInsets:UIEdgeInsetsMake(4,6,8,6) resizingMode:UIImageResizingModeStretch];
    
    CGFloat x=self.browser.frame.origin.x-5+2;
    CGFloat y=self.browser.frame.origin.y-3+2;
    CGFloat w=self.browser.frame.size.width+5+5-2-2;
    CGFloat h=self.browser.frame.size.height+3+7-2-2;
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    imgView.image = img2;
    [self.view addSubview:imgView];
    
    self.browser.delegate = self;
    [self.browser loadHTMLString:@"<div id='example-one' contenteditable='true'>hola</div>" baseURL:[NSURL URLWithString:nil]];

    // Pone el color de fondo para los editorres
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"myTableBg"]];
}



//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return TRUE;
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------




//=====================================================================================================================
#pragma mark -
#pragma mark <UIWebViewDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"1");
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"2");
    return YES;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"3");
}

//---------------------------------------------------------------------------------------------------------------------
- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"4");
}






//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (IBAction)_setHtml:(UIButton *)sender {
    
    NSString *htmlStr = @"<div><ul><li><b>Surname:</b> John</li><li><b>Last name:</b> Doe</li></div>";
    
    NSString *editableHtmlContent = [NSString stringWithFormat:@"<div id='my-editor-div' contenteditable='true'>%@</div>", htmlStr];
    [self.browser loadHTMLString:editableHtmlContent baseURL:[NSURL URLWithString:nil]];
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)_getHtml:(UIButton *)sender {

    NSString *scriptResult;
    
    scriptResult = [self.browser stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    NSLog(@"result = %@", scriptResult);

    scriptResult = [self.browser stringByEvaluatingJavaScriptFromString:@"document.getElementById('my-editor-div').innerHTML"];
    NSLog(@"result = %@", scriptResult);
}



@end

