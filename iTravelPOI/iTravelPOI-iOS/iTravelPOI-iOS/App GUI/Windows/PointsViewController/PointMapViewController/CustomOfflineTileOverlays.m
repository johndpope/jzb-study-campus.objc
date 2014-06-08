//
//  CustomOfflineTileOverlays.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 30/03/14.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

#define __CustomOfflineTileOverlays__IMPL__
#import "CustomOfflineTileOverlays.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE <CustomOfflineTileOverlayRenderer> interface definition
//*********************************************************************************************************************
@interface CustomOfflineTileOverlayRenderer()


@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation <CustomOfflineTileOverlayRenderer>
//*********************************************************************************************************************
@implementation CustomOfflineTileOverlayRenderer


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------


//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (BOOL)canDrawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale {
    
    //NSLog(@"canDrawMapRect  %f,%f - %f,%f - %f - %f,%f",mapRect.origin.x,mapRect.origin.y,mapRect.size.width,mapRect.size.height, 1/zoomScale, mapRect.size.width*zoomScale, mapRect.size.height*zoomScale);
    return [super canDrawMapRect:mapRect zoomScale:zoomScale];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
    
    //NSLog(@"drawMapRect     %0.2f, %0.2f - %0.2f, %0.2f - %0.2f - %0.2f, %0.2f",mapRect.origin.x,mapRect.origin.y,mapRect.size.width,mapRect.size.height, 1/zoomScale, mapRect.size.width*zoomScale, mapRect.size.height*zoomScale);
    [super drawMapRect:mapRect zoomScale:zoomScale inContext:context];
}


//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------


@end


//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE <CustomOfflineTileOverlay> interface definition
//*********************************************************************************************************************
@interface CustomOfflineTileOverlay()

@property (nonatomic, strong) NSString  *offlineMapPath;
@property (nonatomic, assign) int       maxBucketA;

@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation <CustomOfflineTileOverlay>
//*********************************************************************************************************************
@implementation CustomOfflineTileOverlay



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (CustomOfflineTileOverlay *) overlay:(NSString *)mapName {
    
    // Las URLs que tenemos para sacar tiles[max zoom] son:
    // (En algunas hay varios servidores para hacer peticiones simultaneas)
    //OpenCycleMap:    NSString *template = @"http://b.tile.opencyclemap.org/cycle/{z}/{x}/{y}.png";
    //MapQuest[19]:    NSString *template = @"http://otile3.mqcdn.com/tiles/1.0.0/osm/{z}/{x}/{y}.jpg";
    //OpenStreetMap:   NSString *template = @"http://tile.openstreetmap.org/{z}/{x}/{y}.png";
    //Google Maps[22]: NSString *template = @"http://mt0.google.com/vt/x={x}&y={y}&z={z}";

    NSString *template = @"http://otile3.mqcdn.com/tiles/1.0.0/osm/{z}/{x}/{y}.jpg";
    CustomOfflineTileOverlay *overlay = [[CustomOfflineTileOverlay alloc] initWithURLTemplate:template];
    overlay.canReplaceMapContent = YES;
    overlay.minimumZ = 3;
    overlay.maximumZ = 18;
    
    [overlay initOfflineMapFolderInfo:mapName];
    
    return overlay;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) initOfflineMapFolderInfo:(NSString *)mapName {
    
    //Get the get the path to the Documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //Combine Documents directory path with your file name to get the full path
    self.offlineMapPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"offlineMaps/%@",mapName]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileNames = [fileManager contentsOfDirectoryAtPath:self.offlineMapPath error:nil];
    for(NSString *name in fileNames) {
        if([name hasPrefix:@"a"]) self.maxBucketA++;
    }
    
    // El valor maximo va por zoom
    self.maxBucketA = 2;
}


//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (void)loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData *tileData, NSError *error))result {
    
    // tendremos guardados los mapas del 3 al 6 y el 17
    if(path.z<7) {
        result(nil,nil);
    } else {
        [self _loadTileWithBiggerZoomLevelAtPath:path result:result];
    }
}


//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (UIImage *) _loadTileImageAtPath:(MKTileOverlayPath)path error:(NSError * __autoreleasing *)error {

    /*
    UIImage *emptyMapTile = [UIImage imageNamed:@"emptyMapTile"];
    return emptyMapTile;
    */
    
    NSString *fileName = [NSString stringWithFormat:@"%zd_%zd.jpg",path.x,path.y];
    
    for(NSUInteger bucketA=0;bucketA<self.maxBucketA;bucketA++) {
        for(NSUInteger bucketB=0;bucketB<16;bucketB++) {
            
            NSString *withBucketPath=[NSString stringWithFormat:@"%zd/a%td/b%td/%@",path.z,bucketA,bucketB,fileName];
            NSString *fullOfflineFile = [self.offlineMapPath stringByAppendingPathComponent:withBucketPath];

            UIImage *tileImg = [UIImage imageWithContentsOfFile:fullOfflineFile];
            if(tileImg) return tileImg;
        }
    }
    return nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _loadTileWithBiggerZoomLevelAtPath:(MKTileOverlayPath)path  result:(void (^)(NSData *tileData, NSError *error))result {
    
    //    NSInteger zoomLevel = (path.z -1) | 1;
    NSInteger zoomLevel = path.z -1;
    
    // Calcula la scala de zoom entre el actual y el del mapa almacenado
    NSUInteger zoomScale = path.z - zoomLevel;
    
    // Busca el tile del mapa almacenado equivalente al pedido
    MKTileOverlayPath scaledPath;
    scaledPath.contentScaleFactor = path.contentScaleFactor;
    scaledPath.z = zoomLevel;
    scaledPath.x= path.x >>zoomScale;
    scaledPath.y= path.y >>zoomScale;

    // Carga la imagen que se esta buscando
    NSError *localError = nil;
    UIImage *tileImg = [self _loadTileImageAtPath:scaledPath error:&localError];
    
    // Si lo ha encontrado lo pinta. Sino, informa del error
    if (tileImg==nil) {
        result(nil, localError);
    } else {
    
        NSUInteger offsetMask = (1 << zoomScale) - 1;
        NSUInteger offsetX    = (path.x & offsetMask) << 8;
        NSUInteger offsetY    = (path.y & offsetMask) << 8;
        NSUInteger scaledSize = 1 << (8+zoomScale);
        
        UIGraphicsBeginImageContext(CGSizeMake(256, 256));
        
        CGRect rect = CGRectMake(-(double)offsetX, -(double)offsetY, scaledSize, scaledSize);
        [tileImg drawInRect:rect];
        
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        NSData *scaledData = UIImagePNGRepresentation(scaledImage);
        result(scaledData, nil);
        
    }
    
}

@end

