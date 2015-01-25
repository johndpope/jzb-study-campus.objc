//
// GMSimplePoint.m
//
// Created by Jose Zarzuela.
//

#import "GMSimpleModel.h"




// *********************************************************************************************************************
#pragma mark -
#pragma mark Private Constants and Definitions
// ---------------------------------------------------------------------------------------------------------------------




// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface Private Definition
// ---------------------------------------------------------------------------------------------------------------------
@interface GMSimplePoint ()


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// ---------------------------------------------------------------------------------------------------------------------
@implementation GMSimplePoint

// Al venir de un protocolo hay que sintetizarlas o redefinirlas
@synthesize iconHREF = _iconHREF;
@synthesize coordinates = _coordinates;


// =====================================================================================================================
#pragma mark -
#pragma mark Init && CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
- (instancetype) initWithName:(NSString *)name ownerMap:(GMSimpleMap *)owerMap {

    if ( self = [super initWithName:name ownerMap:owerMap] ) {
        self.iconHREF = GM_DEFAULT_POINT_ICON_HREF;
        self.coordinates = COORDINATES_ZERO;
    }
    
    return self;
}




// =====================================================================================================================
#pragma mark -
#pragma mark PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
// Must check all attributes (without relations with other elements)
- (BOOL) isEqualToItem:(id<GMPoint>)item {
    
    // Chequea todas las propiedades
    if(![item conformsToProtocol:@protocol(GMPoint)]) return FALSE;
    if(![super isEqualToItem:item]) return FALSE;
    if(![self.iconHREF isEqualToString:item.iconHREF]) return FALSE;
    if(![self.coordinates isEqualToCoordinates:item.coordinates]) return FALSE;
    
    // Son iguales
    return TRUE;
}

// ---------------------------------------------------------------------------------------------------------------------
// Copies just fields from source item (without relations with other elements)
- (void) shallowSetValuesFromItem:(id<GMPoint>)item {
    
    if(![item conformsToProtocol:@protocol(GMPoint)]) return;
    
    [super shallowSetValuesFromItem:item];
    self.iconHREF = item.iconHREF;
    self.coordinates = [GMCoordinates coordinatesWithCoordinates:item.coordinates];
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) description {
    
    NSMutableString *mutStr = [NSMutableString stringWithString:[super description]];
    [mutStr appendFormat:@"  iconHREF = '%@'\n", self.iconHREF];
    [mutStr appendFormat:@"  coordinates = '%@'\n", self.coordinates];
    return mutStr;
}


@end
