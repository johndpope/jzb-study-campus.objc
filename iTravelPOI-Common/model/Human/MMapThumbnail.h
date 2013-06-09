//
//  MMapThumbnail.h
//


#import "_MMapThumbnail.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************
typedef void (^TBlock_blockDefinition)(double lat, double lng, NSData *imageData);


//=====================================================================================================================
@interface MMapThumbnailTicket: NSObject

- (void) cancelNotification;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface MMapThumbnail : _MMapThumbnail {}


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (MMapThumbnail *) emptyThumnailInContext:(NSManagedObjectContext *)moContext;


//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (MMapThumbnailTicket *) asyncUpdateLatitude:(double)lat longitude:(double)lng callback:(TBlock_blockDefinition)callback;

@end
