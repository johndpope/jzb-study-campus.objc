//
//  TBaseEntity.m
//  CDTest
//
//  Created by Snow Leopard User on 04/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JavaStringCat.h"
#import "TBaseEntity.h"


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------

#define LOCAL_ETAG_PREFIX  @"@Local-"
#define LOCAL_ID_PREFIX    @"@cafe-"
#define REMOTE_ETAG_PREFIX @"@Sync-"



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------

//synchronized 
NSUInteger _getNextIdCounter();
NSString* _calcLocalETag();
NSString* _calcRemoteCategoryETag();
NSString* _calcLocalGID();
NSString* _typeToString(id element);




//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface TBaseEntity() {
}

@property (nonatomic, retain) NSNumber * _i_wasDeleted;
@property (nonatomic, retain) NSNumber * _i_changed;

- (void) initEntity;

- (void) _xmlStringBody: (NSMutableString*) sb ident:(NSString *) ident;
- (void) _xmlStringBTag: (NSMutableString*) sb ident:(NSString *) ident;
- (void) _xmlStringETag: (NSMutableString*) sb ident:(NSString *) ident;


@end

//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation TBaseEntity

@dynamic name;
@dynamic desc;
@dynamic _i_wasDeleted;
@dynamic _i_changed;
@dynamic ts_created;
@dynamic syncETag;
@dynamic GID;
@dynamic ts_updated;
@dynamic iconURL;
@synthesize syncStatus = _syncStatus;


//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) calcRemoteCategotyETag {
    return _calcRemoteCategoryETag();
}

//---------------------------------------------------------------------------------------------------------------------
- (void) initEntity
{
    self.GID = _calcLocalGID(); 
    self.name = @"";
    self.desc = @"";
    self.iconURL = @"http://icon"; // Hay que crear un icono por defecto ( getDefaultIcon(); )
    self.changed = false;
    self.wasDeleted = false;
    self.syncETag = _calcLocalETag();
    self.syncStatus = ST_Sync_OK;
    self.ts_created = [NSNumber numberWithLong:time(0L)];
    self.ts_updated = [NSNumber numberWithLong:time(0L)];
}


//---------------------------------------------------------------------------------------------------------------------
- (BOOL) changed {
    return [self._i_changed boolValue];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) setChanged:(BOOL)value {
    
    self.ts_updated = [NSNumber numberWithLong:time(0L)];
    self._i_changed = [NSNumber numberWithBool:value];
}


//---------------------------------------------------------------------------------------------------------------------
- (BOOL) wasDeleted {
    return [self._i_wasDeleted boolValue];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) setWasDeleted:(BOOL)value {
    self._i_wasDeleted = [NSNumber numberWithBool:value];
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) isLocal {
    NSUInteger pos = [self.syncETag indexOf:LOCAL_ETAG_PREFIX];
    return pos!=-1;
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


//---------------------------------------------------------------------------------------------------------------------
- (void) _xmlStringBTag: (NSMutableString*) sbuf ident:(NSString *) ident {
    [sbuf appendFormat:@"%@<%@>\n", ident, _typeToString(self)];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _xmlStringETag: (NSMutableString*) sbuf ident:(NSString *) ident {
    [sbuf appendFormat:@"%@</%@>",ident, _typeToString(self)];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _xmlStringBody: (NSMutableString*) sbuf ident:(NSString *) ident {
    
    [sbuf appendFormat:@"%@<id>%@</id>\n", ident, self.GID];
    [sbuf appendFormat:@"%@<name>%@</name>\n", ident, self.name];
    [sbuf appendFormat:@"%@<syncETag>%@</syncETag>\n", ident, self.syncETag];
    [sbuf appendFormat:@"%@<syncStatus>%d</syncStatus>\n", ident, self.syncStatus];
    [sbuf appendFormat:@"%@<changed>%d</changed>\n", ident, self.changed];
    [sbuf appendFormat:@"%@<description>%@</description>\n", ident, self.desc];
    [sbuf appendFormat:@"%@<icon>%@</icon>\n", ident, self.iconURL];
    [sbuf appendFormat:@"%@<wasDeleted>%d</wasDeleted>\n", ident, self.wasDeleted];
    [sbuf appendFormat:@"%@<ts_created>%@</ts_created>\n", ident, self.ts_created];
    [sbuf appendFormat:@"%@<ts_updated>%@</ts_updated>\n", ident, self.ts_updated];
}





@end



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
//synchronized 
NSUInteger _getNextIdCounter() {

    static NSUInteger s_idCounter = 0;

    if(s_idCounter==0) {
        srand((unsigned)time(0L));
        s_idCounter = (NSUInteger)rand()%1000;
    }
    return s_idCounter++;
}


//---------------------------------------------------------------------------------------------------------------------
NSString* _calcLocalETag() {
    NSUInteger nCounter = _getNextIdCounter();
    NSString * lEtag = [NSString stringWithFormat:@"%@%u-%u", LOCAL_ETAG_PREFIX,time(0L),nCounter];
    return lEtag;
}


//---------------------------------------------------------------------------------------------------------------------
NSString* _calcRemoteCategoryETag() {
    NSUInteger nCounter = _getNextIdCounter();
    NSString * lEtag = [NSString stringWithFormat:@"%@%u-%u", REMOTE_ETAG_PREFIX,time(0L),nCounter];
    return lEtag;
}

//---------------------------------------------------------------------------------------------------------------------
NSString* _calcLocalGID() {
    NSUInteger nCounter = _getNextIdCounter();
    NSString * lGID = [NSString stringWithFormat:@"%@%u-%u", LOCAL_ID_PREFIX,time(0L),nCounter];
    return lGID;
}

//---------------------------------------------------------------------------------------------------------------------
NSString* _typeToString(id element) {
    return [[element class] description];
}
