//
//  GMapService.m
//  WCDTest
//
//  Created by jzarzuela on 11/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GMapService.h"
#import "ModelService.h"
#import "GData.h"
#import "JavaStringCat.h"



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface GMapService () {
@private
    BOOL _isLoggedIn;
    dispatch_queue_t _GMapServiceQueue;
}

@property (nonatomic,retain) GDataServiceGoogleMaps *service;


+ (NSString *) _extract_TMapID_fromEntry:(GDataEntryMap*) entry;
+ (void) _fill_TMap:(TMap *)map withFeedMapEntry:(GDataEntryMap*) entry;


@end


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation GMapService


@synthesize service = _service;



//---------------------------------------------------------------------------------------------------------------------
+ (GMapService *)sharedInstance {
    
	static GMapService *_globalGMapInstance = nil;
    
	static dispatch_once_t _predicate;
	dispatch_once(&_predicate, ^{
        NSLog(@"Creating sharedInstance");
        _globalGMapInstance = [[self alloc] init];
    });
	return _globalGMapInstance;
}

//---------------------------------------------------------------------------------------------------------------------
- (id)init
{
    self = [super init];
    if (self) {
        
        self.service = [[GDataServiceGoogleMaps alloc] init];
        [self.service setShouldCacheDatedData:YES];
        [self.service setServiceShouldFollowNextLinks:YES];
        
        _GMapServiceQueue = dispatch_queue_create("GMapServiceQueue", NULL);
        
    }
    
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [self.service release];
    dispatch_release(_GMapServiceQueue);
    
    [super dealloc];
}



//---------------------------------------------------------------------------------------------------------------------
- (void) loginWithUser:(NSString *)email password:(NSString *)password {
    
    NSLog(@"GMapService - loginWithUser");
    _isLoggedIn = true;
    [self.service setUserCredentialsWithUsername:email password:password];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) logout {
    NSLog(@"GMapService - logout");
    _isLoggedIn = false;
    [self.service setUserCredentialsWithUsername:nil password:nil];
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) isLoggedIn {
    return _isLoggedIn;
}

//---------------------------------------------------------------------------------------------------------------------
// Consigue la lista de mapas de los que el usuario logado es dueño.
// Los mapas estan vacios (sin puntos)
- (ASYNCHRONOUS) fetchUserMapList:(TBlock_FetchUserMapListFinished)callbackBlock {
    
    
    NSLog(@"GMapService - fetchUserMapList");

    // Si no hay nadie esperando no hacemos nada
    if(callbackBlock==nil) {
        return;
    }
    
    
    dispatch_queue_t caller_queue = dispatch_get_current_queue();
    
    NSURL *feedURL = [GDataServiceGoogleMaps mapsFeedURLForUserID:kGDataServiceDefaultUser projection:kGDataMapsProjectionOwned];
    
    [self.service fetchFeedWithURL:feedURL completionHandler:^(GDataServiceTicket *ticket, GDataFeedBase *feed, NSError *error) {
        
        // Hacemos el trabajo en otro hilo porque podría ser pesado y así evitamos bloqueos del llamante (GUI)
        dispatch_async(_GMapServiceQueue,^(void){
            
            NSLog(@"GMapService - fetchUserMapList - completionHandler");

            // Iteramos por la lista de mapas que se han retornado en el feed
            NSMutableArray *mapList = [[[NSMutableArray alloc] init] autorelease];
            for(GDataEntryMap *mapEntry in [feed entries]) {
                
                // ************************************************************************************
                // MIENTRAS ESTEMOS EN PRUEBAS!!!!!!!
                NSString *entryName = [[mapEntry title] stringValue];
                if(![entryName hasPrefix:@"@"]) {
                    NSLog(@"Skipping map named: '%@'",entryName);
                    //continue;
                }
                // ************************************************************************************
                
                
                TMap *map = [TMap insertTmpNew];
                [GMapService _fill_TMap:map withFeedMapEntry: mapEntry];
                
                [mapList addObject:map];
            }
            
            // Avisamos al llamante de que ya tenemos la lista con los mapas
            NSArray *maps = [[mapList copy] autorelease];
            dispatch_async(caller_queue, ^(void){
                callbackBlock(maps, error);
            });
            
        });
        
        
        
        
    }];
    
}


//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) _extract_TMapID_fromEntry:(GDataEntryMap*) entry {
    
    // La URL tiene el formato: http://maps.google.com/maps/feeds/features/<<user_id>>/<<map_id>>/full
    
    NSString *str = [[entry featuresFeedURL] absoluteString];
    
    NSUInteger p1 = 10 + [str indexOf:@"/features/"];
    NSUInteger p2 = 1 + [str indexOf:@"/" startIndex:p1];
    NSUInteger p3 = [str indexOf:@"/" startIndex:p2];
    
    NSString *userID = [str subStrFrom:p1 To: p2-1];
    NSString *mapID = [str subStrFrom:p2 To: p3];
    
    return [[[NSString alloc] initWithFormat:@"%@#%@", userID, mapID] autorelease];
}

//---------------------------------------------------------------------------------------------------------------------
+ (void) _fill_TMap:(TMap *)map withFeedMapEntry:(GDataEntryMap*) entry {
    
    map.GID = [GMapService _extract_TMapID_fromEntry:entry];
    map.name = [[entry title] stringValue];
    map.syncETag = [entry ETag];
    map.desc = [[entry summary] stringValue];
    map.ts_created = [[entry publishedDate] date];
    map.ts_updated = [[entry updatedDate] date];
}


@end
