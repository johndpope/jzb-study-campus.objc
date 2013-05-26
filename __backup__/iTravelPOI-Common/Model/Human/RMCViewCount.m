//
//  RMCViewCount.m
//

#define __RMCViewCount__IMPL__
#define __RMCViewCount__PROTECTED__

#import "RMCViewCount.h"
#import "MMap.h"
#import "MCategory.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface RMCViewCount ()

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation RMCViewCount



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (RMCViewCount *) rmcViewCountForMap:(MMap *)map category:(MCategory *)category {
    
    
    NSManagedObjectContext *moContext = map.managedObjectContext;
    
    RMCViewCount *cacheMC = [RMCViewCount insertInManagedObjectContext:moContext];
    
    cacheMC.map = map;
    cacheMC.category = (MCategory *)[moContext objectWithID:category.objectID];
    cacheMC.viewCount = 0;
    
    return cacheMC;
}




//=====================================================================================================================
#pragma mark -
#pragma mark Getter & Setter methods
//---------------------------------------------------------------------------------------------------------------------




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) updateViewCount:(int) increment {
    self.viewCountValue += increment;
}




//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------




@end
