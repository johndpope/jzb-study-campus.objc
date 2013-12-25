//
//  MBase.m
//

#define __MBase__IMPL__
#define __MBase__PROTECTED__

#import "MBase.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface MBase ()

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation MBase



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) updateIcon:(MIcon *)icon {
    self.icon = icon;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) markAsModified {
    @throw [NSException exceptionWithName:@"AbstractMethodException" reason:@"Abstract method 'markAsModified' must be implemented by subclass" userInfo:nil];
}



//=====================================================================================================================
#pragma mark -
#pragma mark Protected methods
// ---------------------------------------------------------------------------------------------------------------------
+ (int64_t) _generateInternalID {
    
    static int64_t s_idCounter = 0;
    
    @synchronized([MBase class]) {
        // La primera vez comienza en un numero aleatorio
        if(s_idCounter==0) {
            srand((unsigned)time(0L));
            s_idCounter = ((int64_t)rand())<<48;
        }
        
        // Incrementa la cuenta
        s_idCounter = 0x7FFF000000000000  & ( s_idCounter + 0x0001000000000000);
        
        // El identificador es una mezcla de numero aleatorio y la hora actual
        int64_t newID = s_idCounter | (((int64_t)time(0L)) & 0x0000FFFFFFFFFFFF);
        
        return newID;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _resetEntityWithName:(NSString *)name icon:(MIcon *)icon {
    
    NSDate *now = [NSDate date];
    
    self.tCreation = now;
    self.tUpdate = now;
    
    //self.internalIDValue = [MBase _generateInternalID];
    self.name = [name copy];
    [self updateIcon:icon];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _markAsModified {
    
    self.tUpdate = [NSDate date];
}



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------




@end
