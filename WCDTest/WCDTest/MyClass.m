//
//  MyClass.m
//  CDTest
//
//  Created by Snow Leopard User on 04/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MyClass.h"
#import "ModelService.h"


#import "GData.h"


@implementation MyClass 

@synthesize owner;


//---------------------------------------------------------------------------------------------------------------------
- (void) createCDataInfo {
    
    [[ModelService sharedInstance] initCDStack];
    NSManagedObjectContext * _moContext = [ModelService sharedInstance].moContext;
    
    TMap *map = [TMap insertTmpNew];
    map.name=@"hola";
    
    TPoint *point1 = [TPoint insertTmpNewInMap: map];
    point1.name = @"P1";
    TPoint *point2 = [TPoint insertTmpNewInMap: map];
    point2.name = @"P2";
    TPoint *point3 = [TPoint insertTmpNewInMap: map];
    point3.name = @"P3";
    
    TCategory *cat0 = [TCategory insertTmpNewInMap: map];
    cat0.name = @"cat0";
    TCategory *cat1 = [TCategory insertTmpNewInMap: map];
    cat1.name = @"cat1";
    TCategory *cat2 = [TCategory insertTmpNewInMap: map];
    cat2.name = @"cat2";
    
    
    [cat1 addPoint: point1];
    [cat1 addPoint: point2];
    [point2 addCategory: cat2];
    [point3 addCategory: cat2];
    
    [cat1 addCategory:cat0];
    [cat0 addSubcategory:cat2];
    
    [cat1 removePoint:point3];
    [cat2 removePoint:point3];
    [point1 removeCategory:cat1];
    [point1 removeCategory:cat2];
       
    [map removePoint: point2];
    NSLog(@"%@",point2);

    [map removeCategory: cat0];
    NSLog(@"%@",cat0);
 
    
    for(TCategory *c in map.categories) {
        NSLog(@"%@",c);
    }
    
    for(TPoint *p in map.points) {
        NSLog(@"%@",p);
    }
        
    [[ModelService sharedInstance] doneCDStack];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) doIt {
    
    NSLog(@"----------> doIt");
    
    GDataServiceGoogleMaps *service = [[GDataServiceGoogleMaps alloc] init];
    [service setShouldCacheDatedData:YES];
    [service setServiceShouldFollowNextLinks:YES];
    
    NSString *username = @"jzarzuela@gmail.com";
    NSString *password = @"#webweb1971";
    [service setUserCredentialsWithUsername:username password:password];
    
    NSURL *feedURL = [GDataServiceGoogleMaps mapsFeedURLForUserID:kGDataServiceDefaultUser
                                                       projection:kGDataMapsProjectionFull];
    
    GDataServiceTicket *ticket;
    ticket = [service fetchFeedWithURL:feedURL
                              delegate:self
                     didFinishSelector:@selector(mapsTicket:finishedWithFeed:error:)];
    //    [self setMapFeedTicket:ticket];
    
    
}

//---------------------------------------------------------------------------------------------------------------------
// map feed fetch callback
- (void)mapsTicket:(GDataServiceTicket *)ticket
  finishedWithFeed:(GDataFeedMap *)feed
             error:(NSError *)error {
    
    NSLog(@"----------> aqui");
    
    NSLog(@"error %@ - %@",error, [error userInfo]);
    NSLog(@"ticket - %@", ticket);
    NSLog(@"feed - %@", feed);
    
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for(GDataEntryBase *entry in [feed entries]) {
        NSString *title = [[entry title] stringValue];
        if ([entry isKindOfClass:[GDataEntryMap class]]) {
            BOOL isAPIVisible = [(GDataEntryMap *)entry isAPIVisible];
            if (!isAPIVisible) {
                title = [title stringByAppendingString:@" (not API visible)"];
            }
        }
        [array addObject:title];
    }
    
    [owner setMaps:[array autorelease]];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [super dealloc];
}

@end
