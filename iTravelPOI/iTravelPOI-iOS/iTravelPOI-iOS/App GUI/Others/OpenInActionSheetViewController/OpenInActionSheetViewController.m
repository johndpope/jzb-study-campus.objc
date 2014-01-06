//
//  OpenInActionSheetViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __OpenInActionSheetViewController__IMPL__
#import "OpenInActionSheetViewController.h"
#import "Util_Macros.h"

#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>





//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define IS_APPLE_MAPS_APP(appName) [appName isEqualToString:@"Apple Maps"]
#define APPLE_MAPS_TAG 5001
#define DISMISS_NO_APP -1




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface OpenInActionSheetViewController() <UIScrollViewDelegate>


@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;
@property (nonatomic, weak) IBOutlet UIButton *cancelBtn;

@property (nonatomic, assign) CLLocationCoordinate2D coord;
@property (nonatomic, strong) NSString *poiName;
@property (nonatomic, strong) OpenInActionSheetViewController *mySelf;
@property (nonatomic, strong) NSMutableArray *appOpenInUrls;

@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation OpenInActionSheetViewController




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (void) showOpenInActionSheetWithController:(UIViewController *)controller point:(MPoint *)point {

    OpenInActionSheetViewController *me = [[OpenInActionSheetViewController alloc] initWithNibName:@"OpenInActionSheetViewController" bundle:nil];


    // Es necesario que alguien tenga una referencia strong hacia mi
    me.mySelf = me;

    // Ocupa todo el area del padre y se pone fuera de la vista
    CGRect rect = controller.view.frame;
    rect.origin.y = rect.size.height;
    me.view.frame = rect;
    [controller.view addSubview:me.view];
    
    
    // Copia los valores a utilizar desde el punto
    me.poiName = [point.name stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    CLLocationCoordinate2D coord = {.latitude=point.latitudeValue, .longitude=point.longitudeValue};
    me.coord = coord;
}




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
        // Custom initialization
    }
    return self;
}


//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    
    [super viewDidLoad];

    // Crea el fondo semitransparente
    UIImage *bgImg1 = [UIImage imageNamed:@"openInASheetBg"];
    UIImage *bgImg2 = [bgImg1 resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8) resizingMode:UIImageResizingModeStretch];
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:self.view.frame];
    bgView.image = bgImg2;
    [self.view insertSubview:bgView atIndex:0];
    
    // Establece al imagen del boton de cancel de forma que se pueda "estirar" adecuadamente
    UIImage *cancelImg1 = [UIImage imageNamed:@"openInASheetCancelBtn"];
    UIImage *cancelImg2 = [cancelImg1 resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8) resizingMode:UIImageResizingModeStretch];
    [self.cancelBtn setBackgroundImage:cancelImg2 forState:UIControlStateNormal];
    
    // Hace el fondo del scrollView un poco mas oscuro (semitransparente) para que se note
    self.scrollView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];

    // Crea los iconos de las aplicaciones y almacena las URLs
    [self _createAppButtons];
    
    CGRect rect = self.view.frame;
    rect.origin.y = rect.size.height;
    self.view.frame = rect;

}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    // Desplaza a la vista desde abajo
    [UIView animateWithDuration:0.25 animations:^{
        frameSetY(self.view, 0);
    } completion:^(BOOL finished) {
        frameSetY(self.view, 0);
    }];
}

//---------------------------------------------------------------------------------------------------------------------
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}




//=====================================================================================================================
#pragma mark -
#pragma mark BIAction methods
//---------------------------------------------------------------------------------------------------------------------
- (IBAction)cancelBtnPressed:(UIButton *)sender {
    [self _dismissActionSheet:DISMISS_NO_APP];
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)pageChanged:(UIPageControl *)sender {
    CGPoint point = self.scrollView.contentOffset;
    point.x = self.pageControl.currentPage * self.scrollView.frame.size.width;
    [self.scrollView setContentOffset:point animated:YES];
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UIScrollViewDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSInteger page = scrollView.contentOffset.x / scrollView.frame.size.width;
    self.pageControl.currentPage = page;
}



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _dismissActionSheet:(NSInteger) index {
    
    // Desplaza a la vista desde abajo
    [UIView animateWithDuration:0.25 animations:^{
        frameSetY(self.view, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        frameSetY(self.view, self.view.frame.size.height);
        if(index!=DISMISS_NO_APP) {
            [self _openInAppIndex:index];
        }
        [self.view removeFromSuperview];
        self.mySelf = nil;
    }];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _openInAppIndex:(NSInteger) index {
    
    if(index!=APPLE_MAPS_TAG) {
        NSString *urlStr = self.appOpenInUrls[index];
        [self _openAppForSchema:urlStr atCoord:self.coord poiName:self.poiName];
    } else {
        [self _openAppleMapsAtCoord:self.coord poiName:self.poiName];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _appButtonPressed:(UIButton *)sender {

    [self _dismissActionSheet:sender.tag];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _createAppButtons {
    
    self.appOpenInUrls = [NSMutableArray array];
    
    NSArray *appInfoList = [self _getAppNamesAndUrlSchemas];
    
    NSInteger index=0;
    for(NSDictionary *appInfo in appInfoList) {
        
        NSString *appName = [appInfo valueForKey:@"name"];
        NSString *icon    = [appInfo valueForKey:@"icon"];
        NSString *url     = [appInfo valueForKey:@"url"];

        BOOL isAppAvailable = [self _isAppAvailableForSchema:url];

        if(isAppAvailable) {
            NSInteger x = index % 3;
            NSInteger y = ((NSInteger)floor(index/3) % 2);
            NSInteger page = floor(index/6);
            
            CGRect rect = CGRectMake(30+x*(57+45)+page*320, 30+y*(57+45), 57, 57);
            UIButton *btn = [[UIButton alloc] initWithFrame:rect];
            UIImage *btnImg = [UIImage imageNamed:icon];
            [btn setImage:btnImg forState:UIControlStateNormal];
            btn.tag = IS_APPLE_MAPS_APP(appName) ? APPLE_MAPS_TAG : index;
            [btn addTarget:self action:@selector(_appButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self.scrollView addSubview:btn];
            
            CGRect rect2 = CGRectMake(30+x*(57+45)+page*320, 30+50+y*(57+45), 57, 45);
            UILabel *lbl = [[UILabel alloc] initWithFrame:rect2];
            lbl.numberOfLines = 2;
            lbl.text = appName;
            lbl.textColor = [UIColor whiteColor];
            lbl.backgroundColor = [UIColor clearColor];
            lbl.font = [UIFont systemFontOfSize:12];
            lbl.textAlignment = NSTextAlignmentCenter;
            [self.scrollView addSubview:lbl];
            
            [self.appOpenInUrls addObject:url];
            
            index++;
        }
    }
        
    NSInteger pages = 1+floor(index/6);
    CGSize size = self.scrollView.frame.size;
    size.width = size.width * pages;
    self.scrollView.contentSize = size;
    
    self.pageControl.numberOfPages = pages;

}

//---------------------------------------------------------------------------------------------------------------------
- (void) _openAppleMapsAtCoord:(CLLocationCoordinate2D)coord poiName:(NSString *)poiName {
    
    MKPlacemark *location = [[MKPlacemark alloc] initWithCoordinate:coord addressDictionary:nil];
    MKMapItem *pinItem = [[MKMapItem alloc] initWithPlacemark:location];
    pinItem.name = poiName;
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    [pinItem openInMapsWithLaunchOptions:@{ MKLaunchOptionsMapSpanKey : [NSValue valueWithMKCoordinateSpan:span] }];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _openAppForSchema:(NSString *)urlStr atCoord:(CLLocationCoordinate2D)coord poiName:(NSString *)poiName {
    
    NSURL *url = [self _composeUrl:urlStr AtCoord:coord poiName:poiName];
    [NSURL URLWithString:[NSString stringWithFormat:urlStr,coord.latitude, coord.longitude, poiName]];
    [[UIApplication sharedApplication] openURL:url];
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) _isAppAvailableForSchema:(NSString *)urlStr {
    
    if(IS_APPLE_MAPS_APP(urlStr)) {
        return YES;
    } else {
        CLLocationCoordinate2D coord = {.latitude=0, .longitude=0};
        BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:[self _composeUrl:urlStr AtCoord:coord poiName:@"name"]];
        return canOpen;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (NSURL *) _composeUrl:(NSString *)urlStr AtCoord:(CLLocationCoordinate2D)coord poiName:(NSString *)poiName {
    
    NSString *urlStr2 = urlStr;
    
    urlStr2 = [urlStr2 stringByReplacingOccurrencesOfString:@"{lat}" withString:[NSString stringWithFormat:@"%f",coord.latitude]];
    urlStr2 = [urlStr2 stringByReplacingOccurrencesOfString:@"{lng}" withString:[NSString stringWithFormat:@"%f",coord.longitude]];
    urlStr2 = [urlStr2 stringByReplacingOccurrencesOfString:@"{name}" withString:[poiName stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    
    
    return [NSURL URLWithString:urlStr2];
}

//---------------------------------------------------------------------------------------------------------------------
- (NSArray *) _getAppNamesAndUrlSchemas {
    
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"openInAppInfo" ofType:@"plist"];
    NSDictionary *openInAppInfo = [NSDictionary dictionaryWithContentsOfFile:thePath];
    NSArray *appInfoList = [openInAppInfo valueForKey:@"appInfoList"];
    return appInfoList;
}



@end

