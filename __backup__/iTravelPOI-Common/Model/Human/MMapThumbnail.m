//
//  MMapThumbnail.m
//

#define __MMapThumbnail__IMPL__
#define __MMapThumbnail__PROTECTED__

#import "MMapThumbnail.h"
#import "BaseCoreData.h"
#import "MPoint.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define TBNL_TIMEOUT 10
#define TBNL_PARAM_SCALE 1
#define TBNL_PARAM_ZOOM 15
#define TBNL_PARAM_SIZE @"128x128"
#define TBNL_PARAM_LANGUAGE @"ES"
#define TBNL_PARAM_MARKERS @"color:blue%7C"


//=====================================================================================================================
@interface MMapThumbnailTicket ()

@property (atomic, strong) TBlock_blockDefinition callback;
@property (atomic, assign) BOOL mustSave;

@end

//=====================================================================================================================
@implementation MMapThumbnailTicket

- (void) cancelNotificationSaving:(BOOL)mustSave {
    self.mustSave = mustSave;
    self.callback = nil;
}

@end


//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface MMapThumbnail ()

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation MMapThumbnail



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (NSData *) staticMapZero {
    
    static NSData * _imgZeroData = nil;
    static dispatch_once_t _predicate;
    dispatch_once(&_predicate, ^{
        
        JZImage *pngImg = [JZImage imageNamed:@"staticMapZero.png"];
#if defined(OS_PLATFORM_MAC)
        _imgZeroData = [pngImg TIFFRepresentation];
#else
        _imgZeroData = UIImagePNGRepresentation(pngImg);
#endif
        
    });
    return _imgZeroData;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSData *) downloadThumbnailForLatitude:(double)lat longitude:(double)lng {
    
    // Este caso se dara mucho por ser los valores por defecto de creacion de los puntos
    if(lat==0.0 && lng==0.0) {
        return MMapThumbnail.staticMapZero;
    }
    
    
    NSMutableString *googleAPIs = [NSMutableString stringWithString:@"http://maps.googleapis.com/maps/api/staticmap?sensor=false&format=PNG&maptype=roadmap"];
    
    [googleAPIs appendFormat:@"&zoom=%d", TBNL_PARAM_ZOOM];
    [googleAPIs appendFormat:@"&scale=%d", TBNL_PARAM_SCALE];
    [googleAPIs appendFormat:@"&size=%@",TBNL_PARAM_SIZE];
    [googleAPIs appendFormat:@"&language=%@", TBNL_PARAM_LANGUAGE];
    //[googleAPIs appendFormat:@"&markers=%@%f,%f", TBNL_PARAM_MARKERS, lat, lng];
    [googleAPIs appendFormat:@"&center=%f,%f", lat,lng];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:googleAPIs]];
    [request setTimeoutInterval:TBNL_TIMEOUT];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"myCompany-myAppName-v1.0(gzip)" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Pragma"];
    
    NSError *err = nil;
    NSHTTPURLResponse *response = nil;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    if(err != nil || (response != nil && response.statusCode != 200)) {
        DDLogError(@"Error requesting thumbnail image. StatusCode = %ld, %@\nError = %@",
                   (long)response.statusCode,
                   [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode],
                   err);
        return nil;
    } else {
        return returnData;
    }
}



//=====================================================================================================================
#pragma mark -
#pragma mark Getter & Setter methods
//---------------------------------------------------------------------------------------------------------------------




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (MMapThumbnailTicket *) asyncUpdateLatitude:(double)lat longitude:(double)lng callback:(TBlock_blockDefinition)callback {
    
    // Almacena nuestro objID y los datos pasados
    __block NSManagedObjectID *objID = self.objectID;
    __block double latitude = lat;
    __block double longitude = lng;

    // Crea el ticket a retornar
    __block MMapThumbnailTicket *ticket = [[MMapThumbnailTicket alloc] init];
    ticket.callback = callback;
    ticket.mustSave = FALSE;
    
    // Ejecuta la actualizacion en background
    NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    childContext.parentContext = BaseCoreData.moContext;
    [childContext performBlock:^{
        
        NSData *imgData = [MMapThumbnail downloadThumbnailForLatitude:latitude longitude:longitude];
        // Graba lo descargado si asi esta indicado
        if(imgData!=nil && ticket.mustSave) {
            MMapThumbnail *thumbnail = (MMapThumbnail *)[childContext objectWithID:objID];
            thumbnail.latitudeValue = latitude;
            thumbnail.longitudeValue = longitude;
            thumbnail.imageData = imgData;
            [BaseCoreData saveMOContext:childContext saveAll:TRUE];
        }
        
        // Avisamos de que hemos terminado si el ticket aun esta vigente
        if(ticket.callback) {
            ticket.callback(latitude, longitude, imgData);
        }
        
        // Libera la informacion del ticket
        ticket.callback = nil;
    }];
    
    
    return ticket;
}





//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------




@end
