//
//  OpenInActionSheetViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __OpenInActionSheetViewController__IMPL__
#import "OpenInActionSheetViewController.h"
#import "MyCollectionViewCell.h"
#import "TopViewController.h"
#import "UIViewController+Storyboard.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define IS_APPLE_MAPS_URL(appURL) [appURL isEqualToString:@"Apple Maps"]
#define DISMISS_NO_APP -1




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface OpenInActionSheetViewController() <UICollectionViewDelegate, UICollectionViewDataSource>


@property (weak, nonatomic) IBOutlet NSLayoutConstraint             *verticalConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView               *itemCollection;

@property (assign, nonatomic) CLLocationCoordinate2D                coord;
@property (strong, nonatomic) NSString                              *poiName;
@property (strong, nonatomic) NSArray                               *appInfoList;


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
+ (void) showOpenInActionSheetWithControllerWithPoint:(MPoint *)point {

    // Crea una instancia a partir del storyboard
    OpenInActionSheetViewController *me = (OpenInActionSheetViewController *)[UIViewController instantiateViewControllerFromStoryboardWithID:@"OpenInActionSheetViewController"];

    // Copia el color del tinte
    //me.view.tintColor = TopViewController.instance.view.tintColor;

    // Ocupa todo el area del padre y se añade como hija
    [TopViewController addChildViewController:me];

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
- (void) viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    // Lee la infomacion de los nombres, iconos y URLs de las aplicaciones
    self.appInfoList = [self _getAppNamesAndUrlSchemas];

    // Prepara la vista para que aparezca desde abajo y con el fondo transparente
    self.view.backgroundColor = [UIColor clearColor];
    self.verticalConstraint.constant = -self.view.frame.size.height;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    // Desplaza a la vista desde abajo
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.parentViewController.navigationController.toolbarHidden = TRUE;
                         self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
                         self.verticalConstraint.constant = 0;
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                     }];
}




//=====================================================================================================================
#pragma mark -
#pragma mark BIAction methods
//---------------------------------------------------------------------------------------------------------------------
- (IBAction)cancelBtnPressed:(UIBarButtonItem *)sender {
    [self _dismissActionSheet:DISMISS_NO_APP];
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UICollectionViewDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:0.97255 green:0.97255 blue:0.97255 alpha:1.0];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    // Ejecuta la aplicacion accion selecionada y cierra la ventana
    NSUInteger index = [indexPath indexAtPosition:1];
    [self _dismissActionSheet:index];
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UICollectionViewDataSource> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.appInfoList.count;
}

//---------------------------------------------------------------------------------------------------------------------
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reusableCellID = @"MyReusableCellID";
    
    MyCollectionViewCell *cell = (MyCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reusableCellID forIndexPath:indexPath];
    
    NSUInteger index = [indexPath indexAtPosition:1];
    
    NSDictionary *appInfo = self.appInfoList[index];
    NSString *appName = [appInfo valueForKey:@"name"];
    NSString *icon    = [appInfo valueForKey:@"icon"];

    cell.label.text = appName;
    cell.label.textColor = self.view.tintColor;
    cell.image.image = [UIImage imageNamed:icon];

    return cell;
}



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _dismissActionSheet:(NSInteger) index {
    
    // Desplaza a la vista hacia abajo
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.backgroundColor = [UIColor clearColor];
                         self.verticalConstraint.constant = -self.view.frame.size.height;
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {

                         // Abre la aplicacion
                         if(index!=DISMISS_NO_APP) {
                             [self _openInAppIndex:index];
                         }
                         // Y cierra la ventana
                         [TopViewController removeChildViewController:self];
                     }];

    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _openInAppIndex:(NSInteger) index {
    
    NSString *urlStr = [self.appInfoList[index] valueForKey:@"url"];
    if(IS_APPLE_MAPS_URL(urlStr)) {
        [self _openAppleMapsAtCoord:self.coord poiName:self.poiName];
    } else {
        [self _openAppForSchema:urlStr atCoord:self.coord poiName:self.poiName];
    }
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
- (NSArray *) _getAppNamesAndUrlSchemas {
    
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"openInAppInfo" ofType:@"plist"];
    NSDictionary *openInAppInfo = [NSDictionary dictionaryWithContentsOfFile:thePath];
    NSArray *appInfoList = [openInAppInfo valueForKey:@"appInfoList"];

    NSMutableArray *availableApps = [NSMutableArray array];
    for(NSDictionary *appInfo in appInfoList) {
        NSString *url = [appInfo valueForKey:@"url"];
        BOOL isAppAvailable = [self _isAppAvailableForSchema:url];
        if(isAppAvailable) {
            [availableApps addObject:appInfo];
        }
    }
    
    return availableApps;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) _isAppAvailableForSchema:(NSString *)urlStr {
    
    if(IS_APPLE_MAPS_URL(urlStr)) {
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


@end

