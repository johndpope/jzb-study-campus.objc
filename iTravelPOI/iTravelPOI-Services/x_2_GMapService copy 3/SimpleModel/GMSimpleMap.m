//
// GMSimpleMap.m
//
// Created by Jose Zarzuela.
//

#import "GMSimpleModel.h"
#import "GMSimpleModel+Protected.h"




// *********************************************************************************************************************
#pragma mark -
#pragma mark Private Constants and Definitions
// ---------------------------------------------------------------------------------------------------------------------
#define Self_MUT_Placemarks ((NSMutableArray *)self.placemarks)




// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface Private Definition
// ---------------------------------------------------------------------------------------------------------------------
@interface GMSimpleMap ()

@property (strong, nonatomic) NSMutableArray *placemarks;

@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// ---------------------------------------------------------------------------------------------------------------------
@implementation GMSimpleMap

// Al venir de un protocolo hay que sintetizarlas o redefinirlas
@synthesize summary = _summary;


// =====================================================================================================================
#pragma mark -
#pragma mark Init && CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
- (instancetype) initWithName:(NSString *)name {
    
    if ( self = [super initWithName:name] ) {
        self.summary = @"";
        self.placemarks = nil; // Until DataSource fills in
    }
    return self;
}




// =====================================================================================================================
#pragma mark -
#pragma mark PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
// Must check all attributes (without relations with other elements)
- (BOOL) isEqualToItem:(id<GMMap>)item {
    
    // Chequea todas las propiedades
    if(![item conformsToProtocol:@protocol(GMMap)]) return FALSE;
    if(![super isEqualToItem:item]) return FALSE;
    if(![self.summary isEqualToString:item.summary]) return FALSE;
    
    // Son iguales
    return TRUE;
}

// ---------------------------------------------------------------------------------------------------------------------
// Copies just fields from source item (without relations with other elements)
- (void) shallowSetValuesFromItem:(id<GMMap>)item {

    if(![item conformsToProtocol:@protocol(GMMap)]) return;
    
    [super shallowSetValuesFromItem:item];
    self.summary = item.summary;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) description {

    NSMutableString *mutStr = [NSMutableString stringWithString:[super description]];
    [mutStr appendFormat:@"  summary = '%@'\n", self.summary];
    [mutStr appendFormat:@"  placemarks count = '%ld'\n", self.placemarks.count];
    return mutStr;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) removeAllPlacemarks {
    [Self_MUT_Placemarks removeAllObjects];
}


// =====================================================================================================================
#pragma mark -
#pragma mark PROTECTED methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) addPlacemark:(GMSimplePlacemark *)placemark {
    
    if(!self.placemarks) self.placemarks = [NSMutableArray array];
    [Self_MUT_Placemarks addObject:placemark];
    
    // Añadir un punto modifica el estado de synchronizacion mapa
    self.markedForSync = YES;

}

// ---------------------------------------------------------------------------------------------------------------------
- (void) removePlacemark:(GMSimplePlacemark *)placemark {
    
    [Self_MUT_Placemarks removeObject:placemark];
    
    // Borrar un punto modifica el estado de synchronizacion mapa
    self.markedForSync = YES;
}


@end
