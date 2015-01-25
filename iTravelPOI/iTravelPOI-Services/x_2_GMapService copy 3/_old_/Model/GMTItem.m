//
// GMTItemBase.m
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __GMTItem__IMPL__
#define __GMTItem__PROTECTED__

#import "GMTItem.h"
#import "NSString+JavaStr.h"
#import "NSString+HTML.h"




// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
// ---------------------------------------------------------------------------------------------------------------------
#define GM_NO_SYNC_LOCAL_ID    @"No-Sync-Local-GID"
#define GM_NO_SYNC_LOCAL_ETAG  @"No-Sync-Local-ETag"

#define GM_DATE_FORMATTER @"yyyy-MM-dd'T'HH:mm:ss'.'SSSS'Z'"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface GMTItem ()


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation GMTItem



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (NSString *) stringFromDate:(NSDate *)date {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:GM_DATE_FORMATTER];
    // The Z at the end of your string represents Zulu which is UTC
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

// ---------------------------------------------------------------------------------------------------------------------
+ (NSDate *) dateFromString:(NSString *)str {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:GM_DATE_FORMATTER];
    // The Z at the end of your string represents Zulu which is UTC
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate *dateFromString = [dateFormatter dateFromString:str];
    return dateFromString;
}



// =====================================================================================================================
#pragma mark -
#pragma mark Getter/Setter methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) editLink {

    NSUInteger lastIndex = [self.gID lastIndexOf:@"/"];
    if(lastIndex != NSNotFound) {
        NSString *url = [NSString stringWithFormat:@"%@/full%@",
                         [self.gID substringToIndex:lastIndex],
                         [self.gID substringFromIndex:lastIndex]];
        return url;
    } else {
        return nil;
    }
}




// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
- (instancetype) init {
    
    return [self initWithName:@""];
}

// ---------------------------------------------------------------------------------------------------------------------
- (instancetype) initWithName:(NSString *)name {

    
    if ( self = [super init] ) {
        self.name = name;
        [self setLocalNoSyncValues];
        self.published_Date = [NSDate date];
        self.updated_Date = self.published_Date;
        self.modifiedSinceLastSyncValue = FALSE;
        self.markedAsDeletedValue = FALSE;
    }
    return self;
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setLocalNoSyncValues {
    
    // Contador para los IDs y ETags iniciales
    static NSUInteger s_idCounter = 1;
    
    // Genera la informacion propia de este item
    NSString *strID = [NSString stringWithFormat:@"%ld-%lu", time(0L), (unsigned long)s_idCounter++];
    
    self.gID = [NSString stringWithFormat:@"%@-%@", GM_NO_SYNC_LOCAL_ID, strID];
    self.etag = [NSString stringWithFormat:@"%@-%@", GM_NO_SYNC_LOCAL_ETAG, strID];
}

// ---------------------------------------------------------------------------------------------------------------------
- (instancetype) initWithContentOfFeed:(NSDictionary *)feedDict errRef:(NSErrorRef *)errRef {
    
    // Establece que no hay un error
    [NSError nilErrorRef:errRef];

    if ( self = [self initWithName:@""] ) {
        
        // Parsea el contenido
        [self __parseInfoFromFeed:feedDict];
        
        // Chequea que todo se relleno correctamente
        NSMutableArray *nilProps = [self __assertNotNilProperties];
        
        // Avisa si hubo algun error, dejando SELF == NIL
        if(nilProps.count > 0) {
            self = nil;
            [NSError setErrorRef:errRef domain:@"GMTItem" reason:@"Some properties of %@ have a nil value: %@", [self.class className], [nilProps componentsJoinedByString:@", "]];
        }

    }
    
    return self;

}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) hasNoSyncLocalGID {
    return [self.gID hasPrefix:GM_NO_SYNC_LOCAL_ID];
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) hasNoSyncLocalETag {
    return [self.etag hasPrefix:GM_NO_SYNC_LOCAL_ETAG];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) copyValuesFromItem:(GMTItem *)item {

    if(![item isKindOfClass:GMTItem.class]) {
        return;
    }

    self.name = item.name;
    self.gID = item.gID;
    self.etag = item.etag;
    self.published_Date = item.published_Date;
    self.updated_Date = item.published_Date;
    self.modifiedSinceLastSyncValue = item.modifiedSinceLastSyncValue;
    self.markedAsDeletedValue = item.markedAsDeletedValue;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSMutableString *) atomEntryContentWithErrRef:(NSErrorRef *)errRef {
    
    
    // Establece que no hay un error
    [NSError nilErrorRef:errRef];

    // Chequea que todo se relleno correctamente
    NSMutableArray *nilProps = [self __assertNotNilProperties];
    
    // Avisa si hubo algun error retornando NIL
    if(nilProps.count > 0) {
        [NSError setErrorRef:errRef domain:@"GMTItem" reason:@"Some properties of %@ have a nil value: %@", [self.class className], [nilProps componentsJoinedByString:@", "]];
        return nil;
    }
    
    
    // Genera el texto del ATOM
    NSMutableString *atomStr = [NSMutableString string];
    
    if(self.gID != nil && self.gID.length > 0 && !self.hasNoSyncLocalGID) {
        [atomStr appendFormat:@"  <atom:id>%@</atom:id>\n", self.gID];
        [atomStr appendFormat:@"  <atom:link rel='edit' type='application/atom+xml' href='%@'/>\n", self.editLink];
    }
    
    [atomStr appendFormat:@"  <atom:published>%@</atom:published>\n", [GMTItem stringFromDate:self.published_Date]];
    [atomStr appendFormat:@"  <atom:updated>%@</atom:updated>\n", [GMTItem stringFromDate:self.updated_Date]];
    
    [atomStr appendFormat:@"  <atom:title type='text'>%@</atom:title>\n", [self __cleanXMLText:self.name]];
    
    return atomStr;

}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) description {

    NSMutableString *desc = [NSMutableString string];

    [desc appendFormat:@"%@:\n", [[self class] className]];
    [desc appendFormat:@"  name = '%@'\n", self.name];
    [desc appendFormat:@"  gID = '%@'\n", self.gID];
    [desc appendFormat:@"  etag = '%@'\n", self.etag];
    [desc appendFormat:@"  editLink = '%@'\n", self.editLink];
    [desc appendFormat:@"  published = '%@'\n", [GMTItem stringFromDate:self.published_Date]];
    [desc appendFormat:@"  updated = '%@'\n", [GMTItem stringFromDate:self.updated_Date]];
    [desc appendFormat:@"  markedAsDeleted = '%d'\n", self.markedAsDeletedValue];
    [desc appendFormat:@"  modifiedSinceLastSync = '%d'\n", self.modifiedSinceLastSyncValue];

    return desc;
}



// =====================================================================================================================
#pragma mark -
#pragma mark PROTECTED methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSMutableArray *) __assertNotNilProperties {
    
    NSMutableArray *nilProperties = [NSMutableArray array];

    if(!self.name) [nilProperties addObject:@"name"];
    if(!self.gID) [nilProperties addObject:@"gID"];
    if(!self.etag) [nilProperties addObject:@"etag"];
    if(!self.published_Date) [nilProperties addObject:@"published_Date"];
    if(!self.updated_Date) [nilProperties addObject:@"updated_Date"];
    
    return nilProperties;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) __parseInfoFromFeed:(NSDictionary *)feedDict {
    
    // Parsea la informacion
    self.name = [[[feedDict valueForKeyPath:@"title.text"] gtm_stringByUnescapingFromHTML] trim];
    
    self.gID = [[feedDict valueForKeyPath:@"id.text"] trim];
    if(!self.gID) self.gID = [[feedDict valueForKeyPath:@"atom:id.text"] trim];
    
    self.etag = [[feedDict valueForKeyPath:@"gd:etag"] trim];
    
    self.published_Date = [GMTItem dateFromString:[feedDict valueForKeyPath:@"published.text"]];
    if(!self.published_Date) self.published_Date = [GMTItem dateFromString:[feedDict valueForKeyPath:@"atom:published.text"]];
    
    self.updated_Date = [GMTItem dateFromString:[feedDict valueForKeyPath:@"updated.text"]];
    if(!self.updated_Date) self.updated_Date = [GMTItem dateFromString:[feedDict valueForKeyPath:@"atom:updated.text"]];

}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) __cleanXMLText:(NSString *)text {
    return [NSString stringWithFormat:@"<![CDATA[%@]]>", text];
    //return [text gtm_stringByEscapingForHTML];
}



// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------





@end
