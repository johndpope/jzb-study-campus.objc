//
//  MMapThumbnail.m
//

#define __MMapThumbnail__IMPL__
#define __MMapThumbnail__PROTECTED__

#import "MMapThumbnail.h"
#import "NSManagedObjectContext+Utils.h"
#import "MPoint.h"
#import "NetworkProgressWheelController.h"



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

@end

//=====================================================================================================================
@implementation MMapThumbnailTicket

- (void) cancelNotification {
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
+ (MMapThumbnail *) emptyThumnailInContext:(NSManagedObjectContext *)moContext {

    MMapThumbnail *me = [MMapThumbnail insertInManagedObjectContext:moContext];
    me.internalIDValue = [MBaseEntity _generateInternalID];
    me.point = nil;
    me.imageData = nil;
    me.latitudeValue = 0.0;
    me.longitudeValue = 0.0;
    return me;
}

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
    [NetworkProgressWheelController start];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    [NetworkProgressWheelController stop];
    
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
- (MMapThumbnailTicket *) asyncUpdateLatitude:(double)lat
                                    longitude:(double)lng moContext:(NSManagedObjectContext *)moContext
                                     callback:(TBlock_blockDefinition)callback {

    // Crea el ticket a retornar
    __block MMapThumbnailTicket *ticket = [[MMapThumbnailTicket alloc] init];
    ticket.callback = callback;
    
    // Ejecuta la actualizacion en background
    NSManagedObjectContext *childContextAsync = moContext.ChildContextASync;
    [childContextAsync performBlock:^{
        
        // Consigue la informacion
        __block NSData *imgData = [MMapThumbnail downloadThumbnailForLatitude:lat longitude:lng];

        // Avisa que ha terminado en el hilo principal
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Llama al callback si el ticket aun esta vigente
            if(ticket.callback) {
                ticket.callback(lat, lng, imgData);
            }
            
            // Libera la informacion del ticket
            ticket.callback = nil;
        });
    }];
    
    
    return ticket;
}





//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------




@end
