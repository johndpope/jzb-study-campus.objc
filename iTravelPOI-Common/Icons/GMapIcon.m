//
// GMapIcon.m
// iTravelPOI
//
// Created by jzarzuela on 03/03/12.
// Copyright 2012 __MyCompanyName__. All rights reserved.
//

#define __GMapIcon__IMPL__
#import "GMapIcon.h"
#import "NSString+JavaStr.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark GMapIcon PRIVATE CONSTANTS and C-Methods definitions
// *********************************************************************************************************************



// *********************************************************************************************************************
#pragma mark -
#pragma mark GMapIcon PRIVATE interface definition
// *********************************************************************************************************************
@interface GMapIcon ()

+ (void) loadIconsData;
+ (NSString *) calcShorNameFromIconHREF:(NSString *)iconHREF;

@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark GMapIcon implementation
// *********************************************************************************************************************
@implementation GMapIcon


static __strong NSImage *_errorImage = nil;
static __strong NSImage *_errorShadowImage = nil;

static __strong NSMutableDictionary *_iconsForHREF = nil;



// =====================================================================================================================
#pragma mark -
#pragma mark initialization & finalization
// ---------------------------------------------------------------------------------------------------------------------
- (id) initWithHREF:(NSString *)HREF shortName:(NSString *)shortName {

    self = [super init];
    if(self) {
        _HREF = [[NSString alloc] initWithString:HREF];
        _shortName = [[NSString alloc] initWithString:shortName];
    }
    return self;

}

// *********************************************************************************************************************
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (GMapIcon *) iconForHREF:(NSString *)HREF {

    if(!_iconsForHREF) {
        [GMapIcon loadIconsData];
    }

    GMapIcon *icon = [_iconsForHREF objectForKey:HREF];
    if(!icon) {
        // No ha encontrado un icono para esta informacion
        NSString *shortName = [GMapIcon calcShorNameFromIconHREF:HREF];
        icon = [[GMapIcon alloc] initWithHREF:HREF shortName:shortName];
        [_iconsForHREF setObject:icon forKey:HREF];
    }

    return icon;
}

// ---------------------------------------------------------------------------------------------------------------------
+ (void) loadIconsData {

    _iconsForHREF = [NSMutableDictionary dictionary];

    NSString *imagePath;

    imagePath = [[NSBundle mainBundle] pathForResource:@"GMapIcons.bundle/GMI_error" ofType:@"png"];
    _errorImage = [[NSImage alloc] initWithContentsOfFile:imagePath];

    imagePath = [[NSBundle mainBundle] pathForResource:@"GMapIcons.bundle/GMI_error.shadow" ofType:@"png"];
    _errorShadowImage = [[NSImage alloc] initWithContentsOfFile:imagePath];
}

// *********************************************************************************************************************
#pragma mark -
#pragma mark Getter/Setter methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSImage *) image {

    if(!_image) {

        NSString *imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"GMapIcons.bundle/%@", self.shortName] ofType:@"png"];
        _image = [[NSImage alloc] initWithContentsOfFile:imagePath];
        if(!_image) {
            // AQUI SE PODRIA INTENTAR CARGAR UNA IMAGEN DE OTRO SITIO QUE NO SEA LAS DE POR DEFECTO DE GMAP
            _image = _errorImage;
        }
    }
    return _image;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSImage *) shadowImage {

    if(!_shadowImage) {

        NSString *imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"GMapIcons.bundle/%@.shadow", self.shortName] ofType:@"png"];
        _shadowImage = [[NSImage alloc] initWithContentsOfFile:imagePath];
        if(!_shadowImage) {
            // AQUI SE PODRIA INTENTAR CARGAR UNA IMAGEN DE OTRO SITIO QUE NO SEA LAS DE POR DEFECTO DE GMAP
            _shadowImage = _errorShadowImage;
        }
    }
    return _shadowImage;
}

// *********************************************************************************************************************
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------


// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------



// -----------------------------------------------------------------------------------------
// Utility method that calculates a "simplified shortName" from the iconHREF
+ (NSString *) calcShorNameFromIconHREF:(NSString *)iconHREF {

    NSString *shortName = nil;

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

            shortName = [NSString stringWithFormat:@"Pin_Letter_%@", [iconHREF subStrFrom:p1 + 5 to:p2]];
            shortName = [shortName replaceStr:@"|" with:@"_"];
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

            shortName = [NSString stringWithFormat:@"Pin_Letter_%@", [iconHREF subStrFrom:p1 + 1 to:p2]];
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

            shortName = [NSString stringWithFormat:@"GMI_%@", [iconHREF subStrFrom:p1 + 1 to:p2]];
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

            shortName = [NSString stringWithFormat:@"GMI_%@", [iconHREF subStrFrom:p1 + 1 to:p2]];
        }
    }



    // -----------------------------------------------------------
    // Retorna la categoria calculada o la última parte de la HREF
    if(!shortName) {
        NSUInteger p1 = [iconHREF lastIndexOf:@"/"];
        if(p1 != NSNotFound) {
            NSUInteger p2 = [iconHREF length];
            shortName = [iconHREF subStrFrom:p1 + 1 to:p2];
        } else {
            shortName = iconHREF;
        }
    }

    return shortName;

}

@end
