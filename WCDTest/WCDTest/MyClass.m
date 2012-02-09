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


//---------------------------------------------------------------------------------------------------------------------
- (void) createCDataInfo {
    
    [[ModelService sharedInstance] initCDStack];
    NSManagedObjectContext * _moContext = [ModelService sharedInstance].moContext;
    
    TMap *map = [TMap insertNewTmp];
    map.name=@"hola";
    
    TPoint *point = [TPoint insertNewTmpInMap: map];
    point.name = @"adios";
    
    TCategory *cat = [TCategory insertNewTmpInMap: map];
    cat.name = @"cat";
    
    [cat addPoint: point];
    [cat addPoint: point];
    [cat addPoint: point];
    [cat addPoint: point];
    
    for(TPoint *p in cat.points) {
        NSLog(@"point name = %@",p.name);
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
