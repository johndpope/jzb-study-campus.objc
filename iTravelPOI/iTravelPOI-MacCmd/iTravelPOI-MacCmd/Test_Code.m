//
// Test_Code.m
//
// Created by Jose Zarzuela on 29/08/12.
// Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "Test_Code.h"
#import "DDTTYLogger.h"
#import "GMapService.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark Service private enumerations & definitions
// ---------------------------------------------------------------------------------------------------------------------




// *********************************************************************************************************************
#pragma mark -
#pragma mark Test_Code Service private interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface Test_Code ()

@property (strong, nonatomic) GMapService *gmapService;


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Test_Code Service implementation
// ---------------------------------------------------------------------------------------------------------------------
@implementation Test_Code







// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
+ (void) executeTests {
    
    Test_Code *me = [[Test_Code alloc] init];
    [me _testGMapService];
}





// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Private methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) _testGMapService {
    
    NSString *ct = [GMapService encryptString:@"hola" withKey:nil];
    NSLog(@"%@",ct);
    NSString *pt = [GMapService decryptString:ct withKey:nil];
    NSLog(@"%@",pt);
    
    //self.gmapService = [GMapService serviceWithEmail:"jzar" password:<#(NSString *)#> error:<#(NSError *__autoreleasing *)#>
}


@end

