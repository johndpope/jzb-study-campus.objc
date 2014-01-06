//
//  BenchMark.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//


//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface BenchMark : NSObject



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (BenchMark *) benchMark:(NSString *) logPrefix,...;
+ (BenchMark *) benchMarkLogging:(NSString *) logPrefix,...;


//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (NSTimeInterval) stepTime;
- (NSTimeInterval) totalTime;

- (void) logStepTime:(NSString *)traceText,...;
- (void) logTotalTime:(NSString *)traceText, ...;



@end
