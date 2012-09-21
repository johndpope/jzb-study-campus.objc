//
//  MyClass.m
//  CDTest
//
//  Created by Snow Leopard User on 04/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MyClass.h"

#import "GData.h"


@implementation MyClass 


//---------------------------------------------------------------------------------------------------------------------
- (void) doIt {
    NSLog(@"hola");
    
    [GDataHTTPFetcher setLoggingDirectory:@"/Users/jzarzuela/Desktop"];
    
    GDataServiceGoogleMaps *service = [[GDataServiceGoogleMaps alloc] init];
    [service setShouldCacheDatedData:YES];
    [service setServiceShouldFollowNextLinks:YES];
    
    NSString *username = @"jzarzuela@gmail.com";
    NSString *password = @"";
    [service setUserCredentialsWithUsername:username password:password];

    NSURL *feedURL = [GDataServiceGoogleMaps mapsFeedURLForUserID:kGDataServiceDefaultUser
                                                       projection:kGDataMapsProjectionFull];
    
    GDataServiceTicket *ticket;
    ticket = [service fetchFeedWithURL:feedURL
                              delegate:self
                     didFinishSelector:@selector(mapsTicket:finishedWithFeed:error:)];
//    [self setMapFeedTicket:ticket];

    int number = 0;
    scanf("%d", &number);

    
}

//---------------------------------------------------------------------------------------------------------------------
// map feed fetch callback
- (void)mapsTicket:(GDataServiceTicket *)ticket
  finishedWithFeed:(GDataFeedMap *)feed
             error:(NSError *)error {

    NSLog(@"aqui");
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
