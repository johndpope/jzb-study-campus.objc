//
//  MComplexFilter.h
//

#import <UIKit/UIKit.h>
#import "MMap.h"
#import "MPoint.h"
#import "MTag.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************



//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface MComplexFilter : NSObject


@property (strong, nonatomic)           NSManagedObjectContext  *moContext;

@property (strong, nonatomic)           MMap                    *filterMap;
@property (strong, nonatomic)           NSSet                   *filterTags;
@property (strong, nonatomic)           NSArray                 *pointOrder; // MBase.h -> MBaseOrderByNameAsc

@property (strong, readonly, nonatomic) NSArray                 *pointList;
@property (strong, readonly, nonatomic) NSSet                   *tagsForPointList;




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (MComplexFilter *) filter;
+ (MComplexFilter *) filterWithContext:(NSManagedObjectContext *)moContext;



//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) reset;
- (void) resortPoints;

@end
