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


@property (nonatomic, strong)           NSManagedObjectContext  *moContext;

@property (nonatomic, strong)           MMap                    *filterMap;
@property (nonatomic, strong)           NSSet                   *filterTags;
@property (nonatomic, strong)           NSArray                 *pointOrder; // MBase.h -> MBaseOrderByNameAsc

@property (nonatomic, strong, readonly) NSArray                 *pointList;
@property (nonatomic, strong, readonly) NSSet                   *tagList;




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


@end
