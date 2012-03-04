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
static NSMutableDictionary *iconsForURL = nil;
static NSMutableDictionary *iconsForShortName = nil;



//*********************************************************************************************************************
#pragma mark -
#pragma mark GMapIcon PRIVATE interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface GMapIcon () 

+ (void) loadIconsData;

- (id) initWithURL:(NSString *)url shortName:(NSString *)shortName; 

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark GMapIcon implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation GMapIcon


@synthesize url = _url;
@synthesize shortName = _shortName;

UIImage *_image = nil;
UIImage *_shadowImage = nil;

static UIImage *_errorImage = nil;
static UIImage *_errorShadowImage = nil;


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
- (void)dealloc
{
    [super dealloc];
    [_url release];
    [_shortName release];
    [_image release];
    [_shadowImage release];
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
        icon = [[GMapIcon alloc] initWithURL:url shortName:url];
    }
    
    return icon;
}

//---------------------------------------------------------------------------------------------------------------------
+ (GMapIcon *) iconForShortName:(NSString *)shortName {
    
    if(!iconsForShortName) {
        [GMapIcon loadIconsData];
    }
    
    GMapIcon *icon = [iconsForShortName objectForKey:shortName];
    if(!icon) {
        // No ha encontrado un icono para esta informacion
        icon = [[GMapIcon alloc] initWithURL:shortName shortName:shortName];
    }
    
    return icon;
}

//---------------------------------------------------------------------------------------------------------------------
+ (void) loadIconsData {
    
    if(!iconsForURL && !iconsForShortName) {
        
        iconsForURL = [NSMutableDictionary dictionary];
        iconsForShortName = [NSMutableDictionary dictionary];
        
        NSString *dictPath = [[NSBundle mainBundle] pathForResource:@"GMapIcons.bundle/allGMapIconsInfo" ofType:@"plist"];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:dictPath];
        NSArray *allIconsData = [dict objectForKey:@"iconsData"];
        
        for(NSDictionary *iconDict in allIconsData) {
            
            NSString *url = [iconDict valueForKey:@"url"];
            NSString *shortName = [iconDict valueForKey:@"shortName"];
            
            GMapIcon * icon = [[GMapIcon alloc] initWithURL:url shortName:shortName];
            
            [iconsForURL setObject:icon forKey:url];
            [iconsForShortName setObject:icon forKey:shortName];
        }
    }
    
    [_errorImage release];
    _errorImage = [[UIImage imageNamed:@"GMapIcons.bundle/error.png"] retain];
    
    [_errorShadowImage release];
    _errorShadowImage = [[UIImage imageNamed:@"GMapIcons.bundle/error.shadow.png"] retain];
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
            _image = _errorImage;
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
            _shadowImage = _errorShadowImage;
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



@end
