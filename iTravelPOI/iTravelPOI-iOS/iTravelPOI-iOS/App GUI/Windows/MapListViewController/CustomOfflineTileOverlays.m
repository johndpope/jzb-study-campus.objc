//
//  CustomOfflineTileOverlays.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 30/03/14.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

#define __CustomOfflineTileOverlays__IMPL__
#import "CustomOfflineTileOverlays.h"



@implementation TPointPath
@end


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
+ (CustomOfflineTileOverlay *) overlay {
    
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
    overlay.maximumZ = 19;
    
    return overlay;
}



//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (void)loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData *tileData, NSError *error))result {
    
    // tendremos guardados los mapas del 3 al 6 y el 17
    
    if(path.z<17) {
        [self _loadTileAtPathAtSmallerZoomLevel:path result:result];
    } else {
        [self _loadTileAtPathAtBiggerZoomLevel:path result:result];
    }
}


//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (UIImage *) _loadTileImageAtPath:(MKTileOverlayPath)path error:(NSError * __autoreleasing *)error {
 
    if(![self isNearPath:path]) return nil;
    
    return [UIImage imageNamed:@"MapEmptyTile"];
    
    // Carga la imagen desde una URL... Luego la sacara de fichero
    NSURL *scaledUrl = [super URLForTilePath:path];
    NSData *tileData = [[NSData alloc] initWithContentsOfURL:scaledUrl options:NSDataReadingMappedIfSafe error:error];

    if (tileData!=nil && *error==nil) {
        UIImage *tileImg = [UIImage imageWithData: tileData];
        return tileImg;
    }
    return nil;
    
}

- (BOOL) isNearPath:(MKTileOverlayPath)path {

#define TILES_SIZE 5
    
    for(TPointPath *pp in self.pointPaths) {
        BOOL value = abs(pp.x-path.x)<=TILES_SIZE && abs(pp.y-path.y)<=TILES_SIZE;
        if(value) {
            return TRUE;
        }
    }
    return FALSE;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _loadTileAtPathAtBiggerZoomLevel:(MKTileOverlayPath)path result:(void (^)(NSData *tileData, NSError *error))result {
    
    // Calcula la scala de zoom entre el actual y el del mapa almacenado
    NSUInteger zoomScale = path.z - 17;
    
    // Busca el tile del mapa almacenado equivalente al pedido
    MKTileOverlayPath scaledPath;
    scaledPath.contentScaleFactor = path.contentScaleFactor;
    scaledPath.z = 17;
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

//---------------------------------------------------------------------------------------------------------------------
- (void) _loadTileAtPathAtSmallerZoomLevel:(MKTileOverlayPath)path result:(void (^)(NSData *tileData, NSError *error))result {
    
    
    // Calcula la scala de zoom entre el actual y el del mapa almacenado
    NSUInteger zoomScale = 17 - path.z;
    
    // Hay que pedir varios tiles de los almacenados
    MKTileOverlayPath scaledPath;
    scaledPath.contentScaleFactor = path.contentScaleFactor;
    scaledPath.z = 17;
    NSUInteger baseX = ((NSUInteger)path.x) << zoomScale;
    NSUInteger baseY = ((NSUInteger)path.y) << zoomScale;
    
    NSUInteger scaledSize = 256 >> zoomScale;
    
    UIGraphicsBeginImageContext(CGSizeMake(256, 256));
    
    // Hay que recuperar varios tiles para crear el resultado
    int iterations = 1 << zoomScale;
    for(int y=0;y<iterations; y++) {
        
        scaledPath.y = baseY + y;
        NSUInteger offsetY = y * scaledSize;
        
        for(int x=0;x<iterations; x++) {
            
            scaledPath.x = baseX + x;
            NSUInteger offsetX = x * scaledSize;
            
            // Busca el tile del mapa almacenado equivalente al pedido
            NSError *localError = nil;
            UIImage *tileImg = [self _loadTileImageAtPath:scaledPath error:&localError];
            
            // Si lo ha encontrado lo pinta
            if (tileImg!=nil && !localError) {
                CGRect rect = CGRectMake(offsetX, offsetY, scaledSize, scaledSize);
                [tileImg drawInRect:rect];
            }
        }
    }
    
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    NSData *scaledData = UIImagePNGRepresentation(scaledImage);
    result(scaledData, nil);
    
}


@end

