//
//  MEBaseEntity.m
//  iTravelPOI
//
//  Created by jzarzuela on 26/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MEBaseEntity.h"
#import "MEBaseEntity_Protected.h"
#import "JavaStringCat.h"
#import "ModelService.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark MEBaseEntity PRIVATE CONSTANTS and C-Methods definitions
//---------------------------------------------------------------------------------------------------------------------
#define LOCAL_ETAG_PREFIX  @"@Local-"
#define LOCAL_ID_PREFIX    @"@cafe-"
#define REMOTE_ETAG_PREFIX @"@Sync-"

#define DEFAULT_ICON_URL   @"http://maps.google.com/mapfiles/ms/micons/red-dot.png"



//*********************************************************************************************************************
#pragma mark -
#pragma mark MEBaseEntity PRIVATE interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface MEBaseEntity () 

+ (NSUInteger) _getNextIdCounter;

- (NSString *) _calcLocalETag;
- (NSString *) _calcLocalGID;
- (NSString *) _classTypeToString;


@property (nonatomic,assign) BOOL i_wasDeleted;


@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark MEBaseEntity implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation MEBaseEntity


@synthesize GID = _GID;
@synthesize syncETag = _syncETag;
@synthesize name = _name;
@synthesize desc = _desc;
@synthesize icon = _icon;
@synthesize ts_created = _ts_created;
@synthesize ts_updated = _ts_updated;
@synthesize changed = _changed;
@synthesize isLocal = _isLocal;
@synthesize syncStatus = _syncStatus;
@synthesize isMarkedAsDeleted = _isMarkedAsDeleted;

@synthesize i_wasDeleted = _i_wasDeleted;


//*********************************************************************************************************************
#pragma mark -
#pragma mark initialization & finalization
//---------------------------------------------------------------------------------------------------------------------
- (id)init
{
    self = [super init];
    if (self) {
        [self resetEntity];
    }
    
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc {

    [_GID release];
    [_syncETag release];
    [_name release];
    [_desc release];
    [_icon release];
    [_ts_created release];
    [_ts_updated release];
    
    [super dealloc];
}


//*********************************************************************************************************************
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (id) searchByGID:(NSString *)gid inArray:(NSArray *)collection {
    
    for(MEBaseEntity *entity in collection) {
        if([entity.GID isEqualToString:gid]) {
            return entity;
        }
    }
    return nil;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) defaultIconURL {
    return DEFAULT_ICON_URL;
}


//*********************************************************************************************************************
#pragma mark -
#pragma mark Getter/Setter methods
//---------------------------------------------------------------------------------------------------------------------
- (void) setChanged:(BOOL)value {
    
    self.ts_updated = [NSDate date];
    _changed = value;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) isLocal {
    return [self.syncETag hasPrefix:LOCAL_ETAG_PREFIX];
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark General PUBLIC methods
//---------------------------------------------------------------------------------------------------------------------
- (NSError *) commitChanges {
    return nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) markAsDeleted {
    // Lo marca como borrado
    self.i_wasDeleted = true;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) unmarkAsDeleted {
    // Quita marca como borrado
    self.i_wasDeleted = false;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) isMarkedAsDeleted {
    return self.i_wasDeleted;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSString *) description {
    
    return [self toXmlString];
}

//---------------------------------------------------------------------------------------------------------------------
- (NSString *) toXmlString {
    return [self toXmlString:0];
}

//---------------------------------------------------------------------------------------------------------------------
- (NSString *) toXmlString: (unsigned) ident {
    
    NSString *strIdent1 = [[NSString string] stringByPaddingToLength:ident+0 withString:@" " startingAtIndex:0];
    NSString *strIdent2 = [[NSString string] stringByPaddingToLength:ident+2 withString:@" " startingAtIndex:0];
    
    NSMutableString *buffer = [NSMutableString stringWithString:@""];
    
    [self _xmlStringBTag:buffer ident:strIdent1];
    [self _xmlStringBody:buffer ident:strIdent2];
    [self _xmlStringETag:buffer ident:strIdent1];
    
    return [buffer copy];
}

//*********************************************************************************************************************
#pragma mark -
#pragma mark PROTECTED methods
//---------------------------------------------------------------------------------------------------------------------
- (void) resetEntity {
    self.GID = [self _calcLocalGID]; 
    self.name = @"";
    self.desc = @"";
    self.icon = [GMapIcon iconForURL:[[self class] defaultIconURL]];
    self.changed = false;
    self.syncETag = [self _calcLocalETag];
    self.syncStatus = ST_Sync_OK;
    self.ts_created = [NSDate date];
    self.ts_updated = [NSDate date];
    self.i_wasDeleted = false;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _xmlStringBTag: (NSMutableString*) sbuf ident:(NSString *) ident {
    [sbuf appendFormat:@"%@<%@>\n", ident, [self _classTypeToString]];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _xmlStringETag: (NSMutableString*) sbuf ident:(NSString *) ident {
    [sbuf appendFormat:@"%@</%@>",ident, [self _classTypeToString]];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _xmlStringBody: (NSMutableString*) sbuf ident:(NSString *) ident {
    
    [sbuf appendFormat:@"%@<id>%@</id>\n", ident, self.GID];
    [sbuf appendFormat:@"%@<name>%@</name>\n", ident, self.name];
    [sbuf appendFormat:@"%@<syncETag>%@</syncETag>\n", ident, self.syncETag];
    [sbuf appendFormat:@"%@<syncStatus>%@</syncStatus>\n", ident, SyncStatusType_Names[self.syncStatus]];
    [sbuf appendFormat:@"%@<changed>%d</changed>\n", ident, self.changed];
    [sbuf appendFormat:@"%@<description>%@</description>\n", ident, self.desc];
    [sbuf appendFormat:@"%@<icon>%@</icon>\n", ident, self.icon.url];
    [sbuf appendFormat:@"%@<ts_created>%@</ts_created>\n", ident, self.ts_created];
    [sbuf appendFormat:@"%@<ts_updated>%@</ts_updated>\n", ident, self.ts_updated];
    [sbuf appendFormat:@"%@<wasDeleted>%d</wasDeleted>\n", ident, self.isMarkedAsDeleted];
}


//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE methods
//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) _calcRemoteCategoryETag {
    NSUInteger nCounter = [MEBaseEntity _getNextIdCounter];
    NSString * lEtag = [NSString stringWithFormat:@"%@%u-%u", REMOTE_ETAG_PREFIX,time(0L),nCounter];
    return lEtag;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSUInteger) _getNextIdCounter {
    
    static NSUInteger s_idCounter = 0;
    
    if(s_idCounter==0) {
        srand((unsigned)time(0L));
        s_idCounter = (NSUInteger)rand()%1000;
    }
    return s_idCounter++;
}


//---------------------------------------------------------------------------------------------------------------------
- (NSString *) _calcLocalETag {
    NSUInteger nCounter = [MEBaseEntity _getNextIdCounter];
    NSString * lEtag = [NSString stringWithFormat:@"%@%u-%u", LOCAL_ETAG_PREFIX,time(0L),nCounter];
    return lEtag;
}


//---------------------------------------------------------------------------------------------------------------------
- (NSString *) _calcLocalGID {
    NSUInteger nCounter = [MEBaseEntity _getNextIdCounter];
    NSString * lGID = [NSString stringWithFormat:@"%@%u-%u", LOCAL_ID_PREFIX,time(0L),nCounter];
    return lGID;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSString *) _classTypeToString {
    return [[self class] description];
}

@end
