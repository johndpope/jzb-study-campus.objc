//
//  RPointTag.m
//

#define __RPointTag__IMPL__
#define __RPointTag__PROTECTED__

#import "RPointTag.h"
#import "MPoint.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface RPointTag ()

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation RPointTag



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (RPointTag *) relatePoint:(MPoint *)point withTag:(MTag *)tag isDirect:(BOOL)direct {

    RPointTag *me = [RPointTag insertInManagedObjectContext:point.managedObjectContext];
    me.point = point;
    me.tag = tag;
    me.isDirectValue = direct;
    
    // Marca el punto como modificado
    [point markAsModified];
    
    return me;
}




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) deleteEntity {
    
    // Marca a su punto como modificado
    [self.point markAsModified];
    
    // Borra la instancia
    self.isDirectValue = NO;
    self.point = nil;
    self.tag = nil;
    [self.managedObjectContext deleteObject:self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) updateIsDirect:(BOOL)value {

    // Un cambio en el tipo de relacion modifica al punto
    if(self.isDirectValue!=value) {
        [self.point markAsModified];
        self.isDirectValue = value;
    }
}




//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------




@end
