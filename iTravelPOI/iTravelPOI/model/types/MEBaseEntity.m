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


static const NSString *_SyncStatusType_Names[8]={
    @"ST_Sync_OK", 
    @"ST_Sync_Create_Local", @"ST_Sync_Create_Remote", 
    @"ST_Sync_Delete_Local", @"ST_Sync_Delete_Remote", 
    @"ST_Sync_Update_Local", @"ST_Sync_Update_Remote",
    @"ST_Sync_Error"
};



//*********************************************************************************************************************
#pragma mark -
#pragma mark MEBaseEntity PRIVATE interfade definition
//---------------------------------------------------------------------------------------------------------------------
@interface MEBaseEntity () 

@property (nonatomic, retain) NSNumber * _i_changed;


+ (NSString *) _calcRemoteCategoryETag;
+ (NSUInteger) _getNextIdCounter;

- (NSString *) _calcLocalETag;
- (NSString *) _calcLocalGID;
- (NSString *) _classTypeToString;


@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark MEBaseEntity implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation MEBaseEntity


@dynamic GID;
@dynamic syncETag;
@dynamic name;
@dynamic desc;
@dynamic iconURL;
@dynamic ts_created;
@dynamic ts_updated;
@dynamic _i_changed;

@synthesize changed = _changed;
@synthesize syncStatus = _syncStatus;


//*********************************************************************************************************************
#pragma mark -
#pragma mark initialization & finalization
//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [super dealloc];
}


//*********************************************************************************************************************
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) calcRemoteCategotyETag {
    return [MEBaseEntity _calcRemoteCategoryETag];
}

//---------------------------------------------------------------------------------------------------------------------
+ (id) searchByGID:(NSString *)gid inArray:(NSArray *)collection {
    
    for(MEBaseEntity *entity in collection) {
        if([entity.GID isEqualToString:gid]) {
            return entity;
        }
    }
    return nil;
}


//*********************************************************************************************************************
#pragma mark -
#pragma mark Getter/Setter methods
//---------------------------------------------------------------------------------------------------------------------
- (BOOL) changed {
    return [self._i_changed boolValue];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) setChanged:(BOOL)value {
    
    self.ts_updated = [NSDate date];
    self._i_changed = [NSNumber numberWithBool:value];
}



//---------------------------------------------------------------------------------------------------------------------
- (BOOL) isLocal {
    return [self.syncETag hasPrefix:LOCAL_ETAG_PREFIX];
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark General PUBLIC methods
//---------------------------------------------------------------------------------------------------------------------
- (void) deleteFromModel {
    [[ModelService sharedInstance].moContext deleteObject:self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) markAsDeleted {
}

//---------------------------------------------------------------------------------------------------------------------
- (void) unmarkAsDeleted {
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
    // Hay que crear un icono por defecto ( getDefaultIcon(); )
    self.iconURL = @"http://maps.gstatic.com/mapfiles/ms2/micons/blue-dot.png"; 
    self.changed = false;
    self.syncETag = [self _calcLocalETag];
    self.syncStatus = ST_Sync_OK;
    self.ts_created = [NSDate date];
    self.ts_updated = [NSDate date];
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
    [sbuf appendFormat:@"%@<syncStatus>%@</syncStatus>\n", ident, _SyncStatusType_Names[self.syncStatus]];
    [sbuf appendFormat:@"%@<changed>%d</changed>\n", ident, self.changed];
    [sbuf appendFormat:@"%@<description>%@</description>\n", ident, self.desc];
    [sbuf appendFormat:@"%@<icon>%@</icon>\n", ident, self.iconURL];
    [sbuf appendFormat:@"%@<ts_created>%@</ts_created>\n", ident, self.ts_created];
    [sbuf appendFormat:@"%@<ts_updated>%@</ts_updated>\n", ident, self.ts_updated];
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
