//
//  BenchMark.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import "BenchMark.h"
#import "DDLog.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface BenchMark()

@property (strong, nonatomic) NSString *logPrefix;
@property (strong, nonatomic) NSDate *tStarTime;
@property (strong, nonatomic) NSDate *tLastStepTime;

@end


//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation BenchMark


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (BenchMark *) benchMark:(NSString *) logPrefix,... {
    
    va_list args;
    va_start(args, logPrefix);
    NSString *txt = [[NSString alloc] initWithFormat:logPrefix arguments:args];
    va_end(args);
    
    BenchMark *me = [[BenchMark alloc] init];
    me.tStarTime = me.tLastStepTime = [NSDate date];
    me.logPrefix = txt;
    return me;
}

//---------------------------------------------------------------------------------------------------------------------
+ (BenchMark *) benchMarkLogging:(NSString *) logPrefix,... {

    va_list args;
    va_start(args, logPrefix);
    NSString *txt = [[NSString alloc] initWithFormat:logPrefix arguments:args];
    va_end(args);
    
    BenchMark *me = [BenchMark benchMark:txt];
    DDLogVerbose(@"**>> BenchMark[%@]  Starting -------------------------", me.logPrefix);
    return me;
}


//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (NSTimeInterval) stepTime {
    NSDate *now = [NSDate date];
    NSTimeInterval time =[now timeIntervalSinceDate:self.tLastStepTime];
    self.tLastStepTime = now;
    return  time;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSTimeInterval) totalTime {
    NSDate *now = [NSDate date];
    NSTimeInterval time =[now timeIntervalSinceDate:self.tStarTime];
    return  time;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) logStepTime:(NSString *)traceText,... {

    va_list args;
    va_start(args, traceText);
    NSString *txt = [[NSString alloc] initWithFormat:traceText arguments:args];
    va_end(args);
    
    DDLogVerbose(@"**>> BenchMark[%@]  %@ - step time: %1.3f", self.logPrefix, txt, [self stepTime]);
}

//---------------------------------------------------------------------------------------------------------------------
- (void) logTotalTime:(NSString *)traceText,... {

    va_list args;
    va_start(args, traceText);
    NSString *txt = [[NSString alloc] initWithFormat:traceText arguments:args];
    va_end(args);

    if(self.tLastStepTime == self.tStarTime) {
        DDLogVerbose(@"**>> BenchMark[%@]  %@ - total time: %1.3f", self.logPrefix, txt, [self totalTime]);
    } else {
        DDLogVerbose(@"**>> BenchMark[%@]  %@ - step time: %1.3f / total time: %1.3f", self.logPrefix, txt, [self stepTime], [self totalTime]);
    }
}


//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------


@end
