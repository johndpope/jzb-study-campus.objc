//
//  TestViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __TestViewController__IMPL__
#import "TestViewController.h"

#import <MapKit/MapKit.h>

#import "ImageManager.h"
#import "OpenInActionSheetViewController.h"




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
    
    
    NSArray *labels = [NSArray arrayWithObjects:@"Normandia", @"Puntos chulos", @"Rentaurantes", @"Compras", @"Zona norte con nombre largo", nil];
    NSArray *icons = [NSArray arrayWithObjects:@"red-dot", @"camera", @"restaurant", @"convienancestore", @"campground", nil];
    NSMutableArray *tags = [NSMutableArray arrayWithCapacity:labels.count];
    for(int n=0;n<labels.count;n++) {
        UIImage *iconImg = [ImageManager imageForName:[NSString stringWithFormat:@"GMap/GMI_%@",icons[n]]];
        UIImageView *tagImgView = [self tagImageViewWithlabel:labels[n] icon:iconImg];
        tags[n] = tagImgView;
    }

    [tags sortUsingComparator:^NSComparisonResult(UIImageView *tagImgView1, UIImageView *tagImgView2) {
        return [[NSNumber numberWithFloat:tagImgView1.frame.size.width] compare:[NSNumber numberWithFloat:tagImgView2.frame.size.width]];
    }];
    
    CGFloat py = 260;
    CGFloat initPX = 10;
    CGFloat maxPX = self.view.frame.size.width-2*initPX;
    CGFloat px = initPX;
    for(int n=0;n<tags.count;n++) {
        
        UIImageView *tagImgView = tags[n];
        
        if(px+tagImgView.frame.size.width>maxPX) {
            px = initPX;
            py += tagImgView.frame.size.height;
        }
        
        tagImgView.frame = CGRectOffset(tagImgView.frame, px, py);
        [self.view addSubview:tagImgView];
        
        px += tagImgView.frame.size.width;
    }
    
    /*
    tagImgView = [self tagImageViewAtX:40 y:260 label:@"Normandia" icon:[ImageManager imageForName:@"GMap/GMI_red-dot"]];
    [self.view addSubview:tagImgView];

    tagImgView = [self tagImageViewAtX:40+tagImgView.frame.size.width y:260 label:@"Puntos Chulos" icon:[ImageManager imageForName:@"GMap/GMI_camera"]];
    [self.view addSubview:tagImgView];
     */
}

//---------------------------------------------------------------------------------------------------------------------
- (UIImageView *) tagImageViewAtX:(CGFloat)x y:(CGFloat)y label:(NSString *)label icon:(UIImage *)icon {
    
    // Retorna el UIImageView resultante posicionado en el punto indicado
    UIImageView *tagImgView = [self tagImageViewWithlabel:label icon:icon];
    tagImgView.frame = CGRectOffset(tagImgView.frame, x, y);
    return tagImgView;
}

//---------------------------------------------------------------------------------------------------------------------
- (UIImageView *) tagImageViewWithlabel:(NSString *)label icon:(UIImage *)icon {
    
    // Font a utilizar en la creacion de las etiquetas
    static UIFont *_lblFont = nil;
    if(_lblFont==nil) {
        _lblFont = [UIFont fontWithName:@"BanglaSangamMN-Bold" size:11];
    }
    
    // Color para el texto
    UIColor *_lblColor = nil;
    if(_lblColor==nil) {
        _lblColor = [UIColor colorWithRed:0.1961 green:0.3098 blue:0.5216 alpha:1.0];
    }
    
    // Imagen de fondo de las etiquetas
    static UIImage *_tagBgImg = nil;
    if(_tagBgImg==nil) {
        _tagBgImg = [[UIImage imageNamed:@"Tag"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 28, 8, 14) resizingMode:UIImageResizingModeStretch];
    }
    
    
    // Calcula el tamaño del texto estableciendo 100x24 pt como el maximo
    CGSize _lblSize=[label sizeWithFont:_lblFont constrainedToSize:CGSizeMake(100, 24) lineBreakMode:NSLineBreakByCharWrapping];
    
    // Calcula las dimensiones totales de la etiqueta
    CGSize totalSize = CGSizeMake(28 + _lblSize.width + 14, _tagBgImg.size.height);
    
    // Crea el UIImageView
    UIImageView *tagImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -2, totalSize.width, totalSize.height)];
    tagImgView.image = _tagBgImg;
    
    // Añade el texto
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(28, 1+(_tagBgImg.size.height-_lblSize.height)/2, _lblSize.width, _lblSize.height)];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textColor = _lblColor;
    lbl.text = label;
    lbl.font = _lblFont;
    [tagImgView addSubview:lbl];
    
    // Añade el icono reducido a 16x16
    UIImageView *_tagIcon = [[UIImageView alloc] initWithImage:[self scaleImage:icon toSize:CGSizeMake(16.0, 16.0)]];
    _tagIcon.frame = CGRectOffset(_tagIcon.frame, 6.5, 6);
    [tagImgView addSubview:_tagIcon];
    
    // Retorna el UIImageView resultante
    return tagImgView;
}

//---------------------------------------------------------------------------------------------------------------------
- (UIImageView *) _tagImageViewAtX:(CGFloat)x y:(CGFloat)y label:(NSString *)label icon:(UIImage *)icon {
    
    // Font a utilizar en la creacion de las etiquetas
    static UIFont *_lblFont = nil;
    if(_lblFont==nil) {
        //_lblFont = [UIFont fontWithName:@"BanglaSangamMN-Bold" size:13];
        _lblFont = [UIFont boldSystemFontOfSize:15];
    }
    
    // Color para el texto
    UIColor *_lblColor = nil;
    if(_lblColor==nil) {
        _lblColor = [UIColor colorWithRed:0.1961 green:0.3098 blue:0.5216 alpha:1.0];
    }
    
    // Imagen de fondo de las etiquetas
    static UIImage *_tagBgImg = nil;
    if(_tagBgImg==nil) {
        _tagBgImg = [[UIImage imageNamed:@"Tag"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 28, 8, 14) resizingMode:UIImageResizingModeStretch];
    }
    
    
    // Reduce el icono a 16x16
    UIImage *_tagIcon = [self scaleImage:icon toSize:CGSizeMake(16.0, 16.0)];
    
    // Calcula el tamaño del texto estableciendo 150x24 pt como el maximo
    CGSize _lblSize=[label sizeWithFont:_lblFont constrainedToSize:CGSizeMake(150, 24) lineBreakMode:NSLineBreakByCharWrapping];

    // Calcula las dimensiones totales de la etiqueta
    CGSize totalSize = CGSizeMake(28 + _lblSize.width + 14, _tagBgImg.size.height);

    // Pinta el conjunto de elementos
    UIGraphicsBeginImageContext(totalSize);
    [_tagBgImg drawInRect:CGRectMake(0, 0, totalSize.width, totalSize.height)];
    [_tagIcon drawAtPoint:CGPointMake(7, 6)];
    [_lblColor set];
    [label drawAtPoint:CGPointMake(28, 1+(_tagBgImg.size.height-_lblSize.height)/2) withFont:_lblFont];
    
    // Obtiene la imagen resultante y la retorna
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Retorna el UIImageView resultante posicionado en el punto indicado
    UIImageView *imgView = [[UIImageView alloc] initWithImage:newImage];
    imgView.frame = CGRectOffset(imgView.frame, x, y);
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(28, 1+(_tagBgImg.size.height-_lblSize.height)/2, _lblSize.width, _lblSize.height)];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textColor = _lblColor;
    lbl.text = label;
    lbl.font = _lblFont;
    [imgView addSubview:lbl];
    
    return  imgView;

}

//---------------------------------------------------------------------------------------------------------------------
-(UIImage*) scaleImage: (UIImage*)image toSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)_btnTest:(UIButton *)sender {
    
    [OpenInActionSheetViewController showOpenInActionSheetWithController:self point:nil];
    /*
    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%f,%f", 32.0, 10.0];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    
    BOOL sup = [self isAppSupported:ExternalNavigationAppGoogleMaps];
     */
}

typedef enum {
    ExternalNavigationAppGoogleMaps,
    ExternalNavigationAppNavigon,
    ExternalNavigationAppTomTom
} ExternalNavigationApp;


//---------------------------------------------------------------------------------------------------------------------
- (NSString *)googleMapsUrlWithTipName:(NSString *)tipName tipLat:(CLLocationDegrees)tipLat tipLng:(CLLocationDegrees)tipLng from:(CLLocationCoordinate2D)from {
    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%1.6f,%1.6f&daddr=%1.6f,%1.6f",
                           from.latitude, from.longitude,
                           tipLat, tipLng];
    return urlString;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSString *)navigonAppUrlWithTipName:(NSString *)tipName tipLat:(CLLocationDegrees)tipLat tipLng:(CLLocationDegrees)tipLng from:(CLLocationCoordinate2D)from {
    NSString *urlString = [NSString stringWithFormat:@"navigon://%@|%@||||||%f|%f",
                           [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"],
                           tipName,
                           tipLng,
                           tipLat];
    
    return urlString;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSString *)tomtomAppUrlWithTipName:(NSString *)tipName tipLat:(CLLocationDegrees)tipLat tipLng:(CLLocationDegrees)tipLng from:(CLLocationCoordinate2D)from {
    
    return nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSURL *)urlForApp:(ExternalNavigationApp)navigationApp withTipName:(NSString *)tipName tipLat:(CLLocationDegrees)tipLat tipLng:(CLLocationDegrees)tipLng from:(CLLocationCoordinate2D)from {
    
    NSString *urlString = nil;
    if ( ExternalNavigationAppNavigon == navigationApp ) {
        urlString = [self navigonAppUrlWithTipName:tipName tipLat:tipLat tipLng:tipLng from:from];
    } else if ( ExternalNavigationAppTomTom == navigationApp ) {
        urlString = [self tomtomAppUrlWithTipName:tipName tipLat:tipLat tipLng:tipLng from:from];
    } else if ( ExternalNavigationAppGoogleMaps == navigationApp ) {
        urlString = [self googleMapsUrlWithTipName:tipName tipLat:tipLat tipLng:tipLng from:from];
    }
    
    if ( urlString == nil )
        return nil;
    
    return [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) isAppSupported:(ExternalNavigationApp)navigationApp {
    
    CLLocationCoordinate2D coord;
    NSURL *url = [self urlForApp:navigationApp withTipName:nil tipLat:0 tipLng:0 from:coord];
    
    if ( url == nil )
        return NO;
    
    return [[UIApplication sharedApplication]canOpenURL:url];
}



@end

