//
//  SafariBookmarks.m
//  GBMSync
//
//  Created by Jose Zarzuela on 21/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SafariBookmarks.h"

@implementation SafariBookmarks

@synthesize tracer;


//** CONSTANTS ***********************************************************************************************************
#define GOOGLE_BKMRKS_UUID @"0FEOF0CA-2012-DECA-1234-010203040506"
#define GOOGLE_BKMRKS_NAME @"Gookmarks"


//** IMPLEMENTATION ******************************************************************************************************

//------------------------------------------------------------------------------------------------------------------------
- (void) createEmptyGoogleBookmarksMenu {
   
    gbkmrks = [NSMutableDictionary new];
    [gbkmrks setObject:GOOGLE_BKMRKS_NAME forKey:@"Title"];
    [gbkmrks setObject:GOOGLE_BKMRKS_UUID forKey:@"WebBookmarkUUID"];
    [gbkmrks setObject:@"WebBookmarkTypeList" forKey:@"WebBookmarkType"];
    [gbkmrks setObject:[NSMutableArray new] forKey:@"Children"];
    
    NSMutableArray *children = [bkmrkBar objectForKey:@"Children"];
    [children addObject:gbkmrks];

}

//------------------------------------------------------------------------------------------------------------------------
- (void) readSafariBookmarks {
    
    // Reads PLIST file with Safari Bookmarks
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *bkmrksPath = [documentsDirectory stringByAppendingString:@"/../Library/Safari/Bookmarks.plist"];
    [self.tracer trace:@"Reading Safari Bookmarks from '%@'",bkmrksPath];
    
    safaryPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:bkmrksPath];

    
    // Search for Bookmark Bar
    for(NSMutableDictionary *child in [safaryPlist objectForKey:@"Children"]) {
        if([[child objectForKey:@"WebBookmarkType"] isEqualToString:@"WebBookmarkTypeList"] &&
           [child objectForKey:@"Children"]!=nil) {
            bkmrkBar = child;
        }
    }
    
    // Check if everything is OK with the menu bar
    if(bkmrkBar==nil) {
        [self.tracer trace:@"Error, no adecuate Bookmark Bar has been found"];
        return;
    }
    
    // Search for Google Bookmarks
    for(NSMutableDictionary *child in [bkmrkBar objectForKey:@"Children"]) {
        if([[child objectForKey:@"WebBookmarkUUID"] isEqualToString:GOOGLE_BKMRKS_UUID]) {
            gbkmrks = child;
        }
    }
    if(gbkmrks==nil) {
        [self createEmptyGoogleBookmarksMenu];
    }
    
    [self plainArrayOfBookmarks];
    
}

//------------------------------------------------------------------------------------------------------------------------
- (void) plainArrayOfBookmarks {
    
    NSMutableArray *flatBookmarks = [NSMutableArray new];
    [self plainArrayOfBookmarks:flatBookmarks baseName:@"root" element:gbkmrks];
    
}

//------------------------------------------------------------------------------------------------------------------------
- (void) plainArrayOfBookmarks:(NSMutableArray *)bookmarks baseName:(NSString *)baseName element:(NSMutableDictionary *)element {
    

    NSArray *children = [element objectForKey:@"Children"];
    for(id child in children) {
        
        NSString *type = [element objectForKey:@"WebBookmarkType"];
        if([type isEqualToString:@"WebBookmarkTypeList"]) {
            NSString *title = [NSString stringWithFormat:@"%@/%@", baseName, [element objectForKey:@"Title"]];
            [self plainArrayOfBookmarks:bookmarks baseName:title element:element];
        } else {
            NSString *title = [NSString stringWithFormat:@"%@/%@", baseName, [[element objectForKey:@"URIDictionary"] objectForKey:@"title"]];
            NSLog(@"title = %@", title);
        }
    }

}


@end
