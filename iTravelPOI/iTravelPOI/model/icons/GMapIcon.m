//
//  GMapIcon.m
//  iTravelPOI
//
//  Created by jzarzuela on 03/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GMapIcon.h"
#import "JavaStringCat.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark GMapIcon PRIVATE CONSTANTS and C-Methods definitions
//---------------------------------------------------------------------------------------------------------------------



//*********************************************************************************************************************
#pragma mark -
#pragma mark GMapIcon PRIVATE interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface GMapIcon () 

+ (void) loadIconsData;
+ (NSString *) calcShorNameFromIconURL: (NSString *)iconURL;

- (id) initWithURL:(NSString *)url shortName:(NSString *)shortName; 

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark GMapIcon implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation GMapIcon


@synthesize url = _url;
@synthesize shortName = _shortName;

static UIImage *_errorImage = nil;
static UIImage *_errorShadowImage = nil;

static NSMutableDictionary *iconsForURL = nil;



//*********************************************************************************************************************
#pragma mark -
#pragma mark initialization & finalization
//---------------------------------------------------------------------------------------------------------------------
- (id) initWithURL:(NSString *)url shortName:(NSString *)shortName {
    
    self = [super init];
    if(self) {
        _url = [url retain];
        _shortName = [shortName retain];
    }
    return self;
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc {
    [_url release];
    [_shortName release];
    [_image release];
    [_shadowImage release];
    
    [super dealloc];
}


//*********************************************************************************************************************
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (GMapIcon *) iconForURL:(NSString *)url {
    
    if(!iconsForURL) {
        [GMapIcon loadIconsData];
    }
    
    GMapIcon *icon = [iconsForURL objectForKey:url];
    if(!icon) {
        // No ha encontrado un icono para esta informacion
        NSString *shortName = [GMapIcon calcShorNameFromIconURL:url];
        icon = [[GMapIcon alloc] initWithURL:url shortName:shortName];
    }
    
    return [icon autorelease];
}

//---------------------------------------------------------------------------------------------------------------------
+ (void) loadIconsData {
    
    if(!iconsForURL) {
        
        iconsForURL = [[NSMutableDictionary alloc] init];
        
        [_errorImage release];
        _errorImage = [[UIImage imageNamed:@"GMapIcons.bundle/error.png"] retain];
        
        [_errorShadowImage release];
        _errorShadowImage = [[UIImage imageNamed:@"GMapIcons.bundle/error.shadow.png"] retain];
    }
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark Getter/Setter methods
//---------------------------------------------------------------------------------------------------------------------
- (UIImage *) image {
    
    if(!_image) {
        NSString *imageName = [NSString stringWithFormat:@"GMapIcons.bundle/%@.png", self.shortName];
        _image = [[UIImage imageNamed:imageName] retain];
        if(!_image) {
            // AQUI SE PODRIA INTENTAR CARGAR UNA IMAGEN DE OTRO SITIO QUE NO SEA LAS DE POR DEFECTO DE GMAP
            _image = [_errorImage retain];
        }
    }
    return _image;
}

//---------------------------------------------------------------------------------------------------------------------
- (UIImage *) shadowImage {
    
    if(!_shadowImage) {
        NSString *shadowImageName = [NSString stringWithFormat:@"GMapIcons.bundle/%@.shadow.png", self.shortName];
        _shadowImage = [[UIImage imageNamed:shadowImageName] retain];
        if(!_shadowImage) {
            // AQUI SE PODRIA INTENTAR CARGAR UNA IMAGEN DE OTRO SITIO QUE NO SEA LAS DE POR DEFECTO DE GMAP
            _shadowImage = [_errorShadowImage retain];
        }
    }
    return _shadowImage;
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark General PUBLIC methods
//---------------------------------------------------------------------------------------------------------------------


//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE methods
//---------------------------------------------------------------------------------------------------------------------



//-----------------------------------------------------------------------------------------
// Utility method that calculates a "simplified shortName" from the iconURL
+ (NSString *) calcShorNameFromIconURL: (NSString *)iconURL {
    
    NSString *shortName = nil;
    
    //-----------------------------------------------------------
    if(iconURL == nil || [iconURL length] == 0) {
        
        return nil;
        
    } 
    //-----------------------------------------------------------
    else if([iconURL indexOf:@"chst=d_map_pin_letter"] != -1) {
        
        NSUInteger p1 = [iconURL lastIndexOf:@"chld="];
        if(p1 != -1) {
            
            NSUInteger p2 = [iconURL lastIndexOf:@"|" startIndex:p1];
            if(p2 == -1) {
                p2 = [iconURL length];
            }
            
            shortName = [NSString stringWithFormat:@"Pin_Letter_%@", [iconURL subStrFrom: p1+5 to:p2]];
            shortName = [shortName replaceStr:@"|" with:@"_"];
        }
    }
    //-----------------------------------------------------------
    else if([iconURL indexOf:@"/kml/paddle"] != -1) {
        
        NSUInteger p1 = [iconURL lastIndexOf:@"/"];
        if(p1 != -1) {
            
            NSUInteger p2 = [iconURL lastIndexOf:@"_maps" startIndex:p1];
            if(p2 == -1) {
                p2 = [iconURL length];
            }
            
            shortName = [NSString stringWithFormat:@"Pin_Letter_%@", [iconURL subStrFrom: p1+1 to:p2]];
        } 
    }
    //-----------------------------------------------------------
    else if([iconURL indexOf:@"/mapfiles/ms/micons"] != -1 || [iconURL indexOf:@"/mapfiles/ms2/micons"] != -1) {
        
        NSUInteger p1 = [iconURL lastIndexOf:@"/"];
        if(p1 != -1) {
            
            NSUInteger p2 = [iconURL lastIndexOf:@"." startIndex:p1];
            if(p2 == -1) {
                p2 = [iconURL length];
            }
            
            shortName = [NSString stringWithFormat:@"GMI_%@", [iconURL subStrFrom: p1+1 to:p2]];
        } 
    }
    //-----------------------------------------------------------
    else if([iconURL indexOf:@"/kml/shapes"] != -1) {
        
        NSUInteger p1 = [iconURL lastIndexOf:@"/"];
        if(p1 != -1) {
            
            NSUInteger p2 = [iconURL lastIndexOf:@"_maps" startIndex:p1];
            if(p2 == -1) {
                p2 = [iconURL length];
            }
            
            shortName = [NSString stringWithFormat:@"GMI_%@", [iconURL subStrFrom: p1+1 to:p2]];
        } 
    }
    
    
    
    //-----------------------------------------------------------
    // Retorna la categoria calculada o la última parte de la URL
    if(!shortName) {
        NSUInteger p1 = [iconURL lastIndexOf:@"/"];
        if(p1 != -1) {
            NSUInteger p2 = [iconURL length];
            shortName = [iconURL subStrFrom: p1+1 to:p2];
        } else {
            shortName = iconURL;
        }
    }    
    
    return shortName;
    
}


@end
