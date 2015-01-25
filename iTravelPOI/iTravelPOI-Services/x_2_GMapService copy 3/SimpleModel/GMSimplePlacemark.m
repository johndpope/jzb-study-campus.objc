//
// GMSimplePlacemark.m
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
@interface GMSimplePlacemark ()

@property (weak, nonatomic) GMSimpleMap  *map;

@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// ---------------------------------------------------------------------------------------------------------------------
@implementation GMSimplePlacemark

// Al venir de un protocolo hay que sintetizarlas o redefinirlas
@synthesize descr = _descr;


// =====================================================================================================================
#pragma mark -
#pragma mark Init && CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
- (instancetype) initWithName:(NSString *)name ownerMap:(GMSimpleMap *)owerMap {

    // No se puede crear sin mapa
    if(!owerMap) return nil;
    
    if ( self = [super initWithName:name] ) {
        self.descr = @"";
        self.map = owerMap;
        [self.map addPlacemark:self];
    }
    
    return self;
}




// =====================================================================================================================
#pragma mark -
#pragma mark PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
// Must check all attributes (without relations with other elements)
- (BOOL) isEqualToItem:(id<GMPlacemark>)item {
    
    // Chequea todas las propiedades
    if(![item conformsToProtocol:@protocol(GMPlacemark)]) return FALSE;
    if(![super isEqualToItem:item]) return FALSE;
    if(![self.descr isEqualToString:item.descr]) return FALSE;
    
    // Son iguales
    return TRUE;
}

// ---------------------------------------------------------------------------------------------------------------------
// Copies just fields from source item (without relations with other elements)
- (void) shallowSetValuesFromItem:(id<GMPlacemark>)item {
    
    if(![item conformsToProtocol:@protocol(GMPlacemark)]) return;
    
    [super shallowSetValuesFromItem:item];
    self.descr = item.descr;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setMarkedForSync:(BOOL)value {

    // Propagar el cambio al mapa
    if(value==YES) self.map.markedForSync = YES;
    
    // Establece el valor
    super.markedForSync = value;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) description {
    
    NSMutableString *mutStr = [NSMutableString stringWithString:[super description]];
    [mutStr appendFormat:@"  map.name = '%@'\n", self.map.name];
    [mutStr appendFormat:@"  descr = '%@'\n", self.descr];
    return mutStr;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) removeFromMap {
    GMSimpleMap *ownerMap = self.map;
    self.map = nil;
    [ownerMap removePlacemark:self];
}


@end
