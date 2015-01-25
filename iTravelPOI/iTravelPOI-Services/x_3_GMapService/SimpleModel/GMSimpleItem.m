//
// GMSimpleItem.m
//
// Created by Jose Zarzuela.
//

#import "GMSimpleModel.h"
#import "GMSimpleModel+Protected.h"




// *********************************************************************************************************************
#pragma mark -
#pragma mark Private Constants and Definitions
// ---------------------------------------------------------------------------------------------------------------------




// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface Private Definition
// ---------------------------------------------------------------------------------------------------------------------
@interface GMSimpleItem ()


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// ---------------------------------------------------------------------------------------------------------------------
@implementation GMSimpleItem

// Al venir de un protocolo hay que sintetizarlas o redefinirlas
@synthesize name = _name;
@synthesize gID = _gID;
@synthesize etag = _etag;
@synthesize published_Date = _published_Date;
@synthesize updated_Date = _updated_Date;
@synthesize markedAsDeleted = _markedAsDeleted;
@synthesize markedForSync = _markedForSync;



// =====================================================================================================================
#pragma mark -
#pragma mark Init && CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
- (instancetype) initWithName:(NSString *)name {
    
    if ( self = [super init] ) {
        
        self.name = name;
        self.gID = [self _generateLocalGID];
        self.etag = [self _generateLocalETag];
        self.published_Date = [NSDate date];
        self.updated_Date = self.published_Date;
        self.markedAsDeleted = FALSE;
        self.markedForSync = TRUE; // Su primer valor es que es local
    }
    return self;
    
}




// =====================================================================================================================
#pragma mark -
#pragma mark PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
// gID != LOCAL
- (BOOL) wasSynchronized {

    [self isEqual:nil];
    return ![self.gID hasPrefix:GM_LOCAL_NO_SYNC_ID];
}

// ---------------------------------------------------------------------------------------------------------------------
// Must check all attributes (without relations with other elements)
- (BOOL) isEqualToItem:(id<GMItem>)item {
    
    // Chequea todas las propiedades
    if(!item) return FALSE;
    if(![item conformsToProtocol:@protocol(GMItem)]) return FALSE;
    if(![self.name isEqualToString:item.name]) return FALSE;
    if(![self.gID isEqualToString:item.gID]) return FALSE;
    if(![self.etag isEqualToString:item.etag]) return FALSE;
    if(![self.published_Date isEqualToDate:item.published_Date]) return FALSE;
    if(![self.updated_Date isEqualToDate:item.updated_Date]) return FALSE;

    // No chequea markedForSync ni markedAsDeleted
    
    // Son iguales
    return TRUE;
}

// ---------------------------------------------------------------------------------------------------------------------
// Copies just fields from source item (without relations with other elements)
- (void) shallowSetValuesFromItem:(id<GMItem>)item {

    if(![item conformsToProtocol:@protocol(GMItem)]) return;

    self.name = item.name;
    self.gID = item.gID;
    self.etag = item.etag;
    self.published_Date = item.published_Date;
    self.updated_Date = item.updated_Date;
    self.markedAsDeleted = item.markedAsDeleted;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) description {

    NSMutableString *desc = [NSMutableString string];

    [desc appendFormat:@"%@:\n", [[self class] className]];
    [desc appendFormat:@"  name = '%@'\n", self.name];
    [desc appendFormat:@"  gID = '%@'\n", self.gID];
    [desc appendFormat:@"  etag = '%@'\n", self.etag];
    [desc appendFormat:@"  published = '%@'\n", self.published_Date];
    [desc appendFormat:@"  updated = '%@'\n", self.updated_Date];
    [desc appendFormat:@"  markedAsDeleted = '%d'\n", self.markedAsDeleted];
    
    return desc;
}




// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) _generateLocalGID {

    static long s_idCounter = 1;
    NSString *strID = [NSString stringWithFormat:@"%@-%ld-%ld", GM_LOCAL_NO_SYNC_ID, time(0L), (long)s_idCounter++];
    return strID;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) _generateLocalETag {
    
    static long s_idCounter = 1;
    NSString *strID = [NSString stringWithFormat:@"%@-%ld-%ld", GM_LOCAL_NO_SYNC_ETAG, time(0L), (long)s_idCounter++];
    return strID;
}


@end
