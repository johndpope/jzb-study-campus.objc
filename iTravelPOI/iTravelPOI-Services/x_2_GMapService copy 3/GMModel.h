//
// GMModel.h
//
// Created by Jose Zarzuela.
//

#import <Foundation/Foundation.h>
#import "GMCoordinates.h"
#import "NSError+SimpleInit.h"




// *********************************************************************************************************************
#pragma mark -
#pragma mark PUBLIC Enumeration & definitions
// ---------------------------------------------------------------------------------------------------------------------
#if TARGET_OS_MAC
    #define GMColor NSColor
#elif TARGET_OS_IPHONE && !TARGET_OS_MAC
    #define GMColor UIColor
#endif

#define GM_LOCAL_NO_SYNC_ID    @"Local-No-Synchronized-GID"
#define GM_LOCAL_NO_SYNC_ETAG  @"Local-No-Synchronized-ETag"

#define GM_DATE_FORMAT @"yyyy-MM-dd'T'HH:mm:ss'.'SSSS'Z'"

#define GM_MAP_EMPTY_SUMMARY @"[empty]"

#define GM_DEFAULT_POINT_ICON_HREF @"http://maps.gstatic.com/mapfiles/ms2/micons/blue-dot.png"

#define GM_DEFAULT_POLYLINE_WIDTH 2
#define GM_DEFAULT_POLYLINE_COLOR [GMColor colorWithRed:128.0/255.0 green:196.0/255.0 blue:64.0/255.0 alpha:255.0*0.75];




// *********************************************************************************************************************
#pragma mark -
#pragma mark GMItem Protocol definition
// ---------------------------------------------------------------------------------------------------------------------
@protocol GMItem <NSObject>

@property (strong, nonatomic)  NSString  *name;
@property (strong, nonatomic)  NSString  *gID;
@property (strong, nonatomic)  NSString  *etag;
@property (strong, nonatomic)  NSDate    *published_Date;
@property (strong, nonatomic)  NSDate    *updated_Date;
@property (assign, nonatomic)  BOOL       markedForSync;      // Needed for remote synchonization (UNSET). Created as TRUE
@property (assign, nonatomic)  BOOL       markedAsDeleted;    // Needed until remote is deleted as well




// Public methods -------------------------------------------------------------------------------------------
// gID != LOCAL
- (BOOL) wasSynchronized;

// Must check all attributes (without relations with other elements)
// It doesn't check 'markedForSync' and 'markedAsDeleted' either
- (BOOL) isEqualToItem:(id<GMItem>)item;

// Copies just fields from source item (without relations with other elements)
- (void) shallowSetValuesFromItem:(id<GMItem>)item;

@end




// *********************************************************************************************************************
#pragma mark -
#pragma mark GMMap Protocol definition
// ---------------------------------------------------------------------------------------------------------------------
@protocol GMPoint, GMPolyLine;
@protocol GMMap <GMItem>

@property (assign, nonatomic)            BOOL       markedForSync;    // CRITICAL: ANY CHANGE IN PLACEMARKS SHOULD UPDATE
                                                                      //           THIS TOO. EVEN ADDING, REMOVING THEM.

@property (strong, nonatomic)            NSString  *summary;

@property (strong, nonatomic, readonly)  NSArray   *placemarks;       // All placemarks, even those marked as deleted.
                                                                      // Could be nil if not requested to DataSource yet.


@end




// *********************************************************************************************************************
#pragma mark -
#pragma mark GMPlacemark Protocol definition
// ---------------------------------------------------------------------------------------------------------------------
@protocol GMPlacemark <GMItem>

@property (assign, nonatomic)          BOOL       markedForSync;  // CRITICAL: IF SET, THIS MUST UPDATE ITS OWNER MAP TOO

@property (weak, nonatomic, readonly)  id<GMMap>  map;            // Owner map
@property (strong, nonatomic)          NSString  *descr;

@end




// *********************************************************************************************************************
#pragma mark -
#pragma mark GMPoint Protocol definition
// ---------------------------------------------------------------------------------------------------------------------
@protocol GMPoint <GMPlacemark>

@property (strong, nonatomic)  NSString       *iconHREF;
@property (strong, nonatomic)  GMCoordinates  *coordinates;

@end




// *********************************************************************************************************************
#pragma mark -
#pragma mark GMPolyLine Protocol definition
// ---------------------------------------------------------------------------------------------------------------------
@protocol GMPolyLine <GMPlacemark>

@property (strong, nonatomic)            GMColor         *color;
@property (assign, nonatomic)            NSUInteger       width;
@property (strong, nonatomic, readonly)  NSMutableArray  *coordinatesList;  // Array of GMCoordinates. At least 2

@end

