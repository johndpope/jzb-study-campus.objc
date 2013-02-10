//
//  IconManager.m
//  iTravelPOI-Mac
//
//  Created by Jose Zarzuela on 27/01/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __IconManager__IMPL__
#import "IconManager.h"

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
#pragma mark PRIVATE IconManager interface definition
//*********************************************************************************************************************
@interface IconManager()

+ (NSImage *) _loadImageNamed:(NSString *)imgName;
+ (NSImage *) _loadImageShadowNamed:(NSString *)imgName;

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
- (NSImage *) image {
    
    if(_image==nil) {
        _image = [IconManager _loadImageNamed:_shortName];
    }
    return _image;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSImage *) shadowImage {
    
    if(_shadowImage==nil) {
        _shadowImage = [IconManager _loadImageShadowNamed:_shortName];
    }
    return _shadowImage;
}

@end






//*********************************************************************************************************************
#pragma mark -
#pragma mark IconManager Implementation
//*********************************************************************************************************************
@implementation IconManager






//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (IconData *) iconDataForHREF:(NSString *)HREF {
    
    NSMutableDictionary *dict = [IconManager _dictionaryIconsForHREF];
    
    IconData *icon = [dict objectForKey:HREF];
    if(icon==nil) {
        NSString *fileName = [IconManager _fileNameFromIconHREF:HREF];
        icon = [[IconData alloc] initWithHREF:HREF shortName:fileName];
        @synchronized(dict) {
            [dict setObject:icon forKey:HREF];
        }
    }
    
    return icon;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSImage *) imageForName:(NSString *)name {
    
    NSMutableDictionary *dict = [IconManager _dictionaryIconsForName];
    
    NSImage *icon = [dict objectForKey:name];
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
+ (NSImage *) _loadImageNamed:(NSString *)imgName {
    
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"ManagedIcons.bundle/%@", imgName] ofType:@"png"];
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];
    if(image==nil) {
        // AQUI SE PODRIA INTENTAR CARGAR UNA IMAGEN DE OTRO SITIO QUE NO SEA LAS DE POR DEFECTO DE GMAP
        image = [IconManager _errorImage];
    }
    return image;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSImage *) _loadImageShadowNamed:(NSString *)imgName {
    
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"ManagedIcons.bundle/%@.shadow", imgName] ofType:@"png"];
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];
    if(image==nil) {
        // AQUI SE PODRIA INTENTAR CARGAR UNA IMAGEN DE OTRO SITIO QUE NO SEA LAS DE POR DEFECTO DE GMAP
        image = [IconManager _errorImage];
    }
    return image;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSImage *) _errorImage {
    
    static __strong NSImage *__errorImage = nil;
    
    static dispatch_once_t _predicate;
    dispatch_once(&_predicate, ^{
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"ManagedIcons.bundle/GMI_error" ofType:@"png"];
        __errorImage = [[NSImage alloc] initWithContentsOfFile:imagePath];
    });
    return __errorImage;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSImage *) _errorImageShadow {
    
    static __strong NSImage *__errorShadowImage = nil;
    
    static dispatch_once_t _predicate;
    dispatch_once(&_predicate, ^{
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"ManagedIcons.bundle/GMI_error.shadow" ofType:@"png"];
        __errorShadowImage = [[NSImage alloc] initWithContentsOfFile:imagePath];
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

