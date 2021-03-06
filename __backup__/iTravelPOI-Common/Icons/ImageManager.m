//
//  ImageManager.m
//  iTravelPOI-Mac
//
//  Created by Jose Zarzuela on 27/01/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __ImageManager__IMPL__
#import "ImageManager.h"

#import "NSString+JavaStr.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE IconData interface definition
//*********************************************************************************************************************
@interface IconData()
    

- (IconData *) initWithHREF:(NSString *)HREF shortName:(NSString *)shortName;


@end


//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE ImageManager interface definition
//*********************************************************************************************************************
@interface ImageManager()

+ (NSString *) _imagePath:(NSString *)imgName;
+ (JZImage *) _loadImageNamed:(NSString *)imgName;
+ (JZImage *) _loadImageShadowNamed:(NSString *)imgName;

@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark IconData Implementation
//*********************************************************************************************************************
@implementation IconData

@synthesize HREF = _HREF;
@synthesize shortName = _shortName;
@synthesize image = _image;
@synthesize shadowImage = _shadowImage;



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
- (IconData *) initWithHREF:(NSString *)HREF shortName:(NSString *)shortName {
    
    self = [super init];
    if(self) {
        _HREF = HREF;
        _shortName = shortName;
        _image = nil;
        _shadowImage = nil;
    }
    return self;
}

//=====================================================================================================================
#pragma mark -
#pragma mark Getter & Setter methods
//---------------------------------------------------------------------------------------------------------------------
- (JZImage *) image {
    
    if(_image==nil) {
        _image = [ImageManager _loadImageNamed:_shortName];
    }
    return _image;
}

// ---------------------------------------------------------------------------------------------------------------------
- (JZImage *) shadowImage {
    
    if(_shadowImage==nil) {
        _shadowImage = [ImageManager _loadImageShadowNamed:_shortName];
    }
    return _shadowImage;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) imagePath {
    return [ImageManager _imagePath:_shortName];
}

@end






//*********************************************************************************************************************
#pragma mark -
#pragma mark ImageManager Implementation
//*********************************************************************************************************************
@implementation ImageManager






//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (IconData *) iconDataForHREF:(NSString *)HREF {
    
    NSMutableDictionary *dict = [ImageManager _dictionaryIconsForHREF];
    
    IconData *icon = [dict objectForKey:HREF];
    if(icon==nil) {
        NSString *fileName = [ImageManager _fileNameFromIconHREF:HREF];
        icon = [[IconData alloc] initWithHREF:HREF shortName:fileName];
        @synchronized(dict) {
            [dict setObject:icon forKey:HREF];
        }
    }
    
    return icon;
}

//---------------------------------------------------------------------------------------------------------------------
+ (JZImage *) imageForName:(NSString *)name {
    
    NSMutableDictionary *dict = [ImageManager _dictionaryIconsForName];
    
    JZImage *icon = [dict objectForKey:name];
    if(icon==nil) {
        @synchronized(dict) {
            icon = [self _loadImageNamed:name];
            [dict setObject:icon forKey:name];
        }
    }
    
    return icon;
}



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
+ (NSMutableDictionary *) _dictionaryIconsForName {

    static __strong NSMutableDictionary *__iconsForName = nil;
    
    static dispatch_once_t _predicate;
    dispatch_once(&_predicate, ^{
        __iconsForName = [NSMutableDictionary dictionary];
    });
    return __iconsForName;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSMutableDictionary *) _dictionaryIconsForHREF {
    
    static __strong NSMutableDictionary *__iconsForHREF = nil;
    
    static dispatch_once_t _predicate;
    dispatch_once(&_predicate, ^{
        __iconsForHREF = [NSMutableDictionary dictionary];
    });
    return __iconsForHREF;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) _imagePath:(NSString *)imgName {
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"ManagedImages.bundle/%@", imgName] ofType:@"png"];
    return imagePath;
}

//---------------------------------------------------------------------------------------------------------------------
+ (JZImage *) _loadImageNamed:(NSString *)imgName {
    
    JZImage *image = [[JZImage alloc] initWithContentsOfFile:[ImageManager _imagePath:imgName]];
    if(image==nil) {
        // AQUI SE PODRIA INTENTAR CARGAR UNA IMAGEN DE OTRO SITIO QUE NO SEA LAS DE POR DEFECTO DE GMAP
        image = [ImageManager _errorImage];
    }
    return image;
}

//---------------------------------------------------------------------------------------------------------------------
+ (JZImage *) _loadImageShadowNamed:(NSString *)imgName {
    
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"ManagedImages.bundle/%@.shadow", imgName] ofType:@"png"];
    JZImage *image = [[JZImage alloc] initWithContentsOfFile:imagePath];
    if(image==nil) {
        // AQUI SE PODRIA INTENTAR CARGAR UNA IMAGEN DE OTRO SITIO QUE NO SEA LAS DE POR DEFECTO DE GMAP
        image = [ImageManager _errorImage];
    }
    return image;
}

//---------------------------------------------------------------------------------------------------------------------
+ (JZImage *) _errorImage {
    
    static __strong JZImage *__errorImage = nil;
    
    static dispatch_once_t _predicate;
    dispatch_once(&_predicate, ^{
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"ManagedImages.bundle/GMI_error" ofType:@"png"];
        __errorImage = [[JZImage alloc] initWithContentsOfFile:imagePath];
    });
    return __errorImage;
}

//---------------------------------------------------------------------------------------------------------------------
+ (JZImage *) _errorImageShadow {
    
    static __strong JZImage *__errorShadowImage = nil;
    
    static dispatch_once_t _predicate;
    dispatch_once(&_predicate, ^{
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"ManagedImages.bundle/GMI_error.shadow" ofType:@"png"];
        __errorShadowImage = [[JZImage alloc] initWithContentsOfFile:imagePath];
    });
    return __errorShadowImage;
}

// -----------------------------------------------------------------------------------------
// Utility method that calculates a "simplified fileName" from the iconHREF
+ (NSString *) _fileNameFromIconHREF:(NSString *)iconHREF {
    
    NSString *fileName = nil;
    
    // -----------------------------------------------------------
    if(iconHREF == nil || [iconHREF length] == 0) {
        
        return nil;
        
    }
    // -----------------------------------------------------------
    else if([iconHREF indexOf:@"chst=d_map_pin_letter"] != NSNotFound) {
        
        NSUInteger p1 = [iconHREF lastIndexOf:@"chld="];
        if(p1 != NSNotFound) {
            
            NSUInteger p2 = [iconHREF lastIndexOf:@"|" startIndex:p1];
            if(p2 == NSNotFound) {
                p2 = [iconHREF length];
            }
            
            fileName = [NSString stringWithFormat:@"Pin_Letter_%@", [iconHREF subStrFrom:p1 + 5 to:p2]];
            fileName = [fileName replaceStr:@"|" with:@"_"];
        }
    }
    // -----------------------------------------------------------
    else if([iconHREF indexOf:@"/kml/paddle"] != NSNotFound) {
        
        NSUInteger p1 = [iconHREF lastIndexOf:@"/"];
        if(p1 != NSNotFound) {
            
            NSUInteger p2 = [iconHREF lastIndexOf:@"_maps" startIndex:p1];
            if(p2 == NSNotFound) {
                p2 = [iconHREF length];
            }
            
            fileName = [NSString stringWithFormat:@"Pin_Letter_%@", [iconHREF subStrFrom:p1 + 1 to:p2]];
        }
    }
    // -----------------------------------------------------------
    else if([iconHREF indexOf:@"/mapfiles/ms/micons"] != NSNotFound || [iconHREF indexOf:@"/mapfiles/ms2/micons"] != NSNotFound) {
        
        NSUInteger p1 = [iconHREF lastIndexOf:@"/"];
        if(p1 != NSNotFound) {
            
            NSUInteger p2 = [iconHREF lastIndexOf:@"." startIndex:p1];
            if(p2 == NSNotFound) {
                p2 = [iconHREF length];
            }
            
            fileName = [NSString stringWithFormat:@"GMI_%@", [iconHREF subStrFrom:p1 + 1 to:p2]];
        }
    }
    // -----------------------------------------------------------
    else if([iconHREF indexOf:@"/kml/shapes"] != NSNotFound) {
        
        NSUInteger p1 = [iconHREF lastIndexOf:@"/"];
        if(p1 != NSNotFound) {
            
            NSUInteger p2 = [iconHREF lastIndexOf:@"_maps" startIndex:p1];
            if(p2 == NSNotFound) {
                p2 = [iconHREF length];
            }
            
            fileName = [NSString stringWithFormat:@"GMI_%@", [iconHREF subStrFrom:p1 + 1 to:p2]];
        }
    }
    
    
    
    // -----------------------------------------------------------
    // Retorna la categoria calculada o la última parte de la HREF
    if(!fileName) {
        NSUInteger p1 = [iconHREF lastIndexOf:@"/"];
        if(p1 != NSNotFound) {
            NSUInteger p2 = [iconHREF length];
            fileName = [iconHREF subStrFrom:p1 + 1 to:p2];
        } else {
            fileName = iconHREF;
        }
    }
    
    
    // Retorna el valor calculado tras aplicar todas las reglas
    return fileName;
    
}


@end

