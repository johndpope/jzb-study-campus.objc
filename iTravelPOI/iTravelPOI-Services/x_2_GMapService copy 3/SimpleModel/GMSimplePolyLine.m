//
// GMSimplePolyLine.m
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
@interface GMSimplePolyLine ()

@property (strong, nonatomic) NSMutableArray *coordinatesList;  // Array of GMCoordinates

@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// ---------------------------------------------------------------------------------------------------------------------
@implementation GMSimplePolyLine

@synthesize color = _color;
@synthesize width = _width;
@synthesize coordinatesList = _coordinatesList;


// =====================================================================================================================
#pragma mark -
#pragma mark Init && CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
- (instancetype) initWithName:(NSString *)name ownerMap:(GMSimpleMap *)owerMap {
    
    if ( self = [super initWithName:name ownerMap:owerMap] ) {
        self.color = GM_DEFAULT_POLYLINE_COLOR;
        self.width = GM_DEFAULT_POLYLINE_WIDTH;
        self.coordinatesList = [NSMutableArray array];
    }
    
    return self;
}




// =====================================================================================================================
#pragma mark -
#pragma mark PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
// Must check all attributes (without relations with other elements)
- (BOOL) isEqualToItem:(id<GMPolyLine>)item {
    
    // Chequea todas las propiedades
    if(![item conformsToProtocol:@protocol(GMPolyLine)]) return FALSE;
    if(![super isEqualToItem:item]) return FALSE;
    if(![self.color isEqual:item.color]) return FALSE;
    if(!self.coordinatesList.count == item.coordinatesList.count) return FALSE;
    
    BOOL __block equalCoordList = TRUE;
    [self.coordinatesList enumerateObjectsUsingBlock:^(GMCoordinates *c1, NSUInteger idx, BOOL *stop) {
        GMCoordinates *c2 = (GMCoordinates *)[item.coordinatesList objectAtIndex:idx];
        equalCoordList = [c1 isEqualToCoordinates:c2];
        *stop = equalCoordList == FALSE;
    }];
    
    // Son iguales
    return equalCoordList;
}

// ---------------------------------------------------------------------------------------------------------------------
// Copies just fields from source item (without relations with other elements)
- (void) shallowSetValuesFromItem:(id<GMPolyLine>)item {
    
    if(![item conformsToProtocol:@protocol(GMPolyLine)]) return;
    
    [super shallowSetValuesFromItem:item];
    self.color = item.color;
    self.width = item.width;
    self.coordinatesList = [NSMutableArray arrayWithCapacity:item.coordinatesList.count];
    for(GMCoordinates *coord in item.coordinatesList) {
        [self.coordinatesList addObject:[GMCoordinates coordinatesWithCoordinates:coord]];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) description {
    
    NSMutableString *mutStr = [NSMutableString stringWithString:[super description]];
    [mutStr appendFormat:@"  color = '%@'\n", self.color];
    [mutStr appendFormat:@"  width = '%ld'\n", (unsigned long)self.width];
    [mutStr appendFormat:@"  coordinates List = '%@'\n", self.coordinatesList];
    return mutStr;
}


@end
