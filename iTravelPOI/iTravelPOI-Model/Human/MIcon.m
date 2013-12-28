//
//  MIcon.m
//

#define __MIcon__IMPL__
#define __MIcon__PROTECTED__

#import "MIcon.h"
#import "MTag.h"
#import "MPoint.h"
#import "ErrorManagerService.h"
#import "NSString+JavaStr.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface MIcon ()

@property (nonatomic, readonly, strong) UIImage *image;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation MIcon

@synthesize image = _image;


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (MIcon *) iconForHref:(NSString *)href inContext:(NSManagedObjectContext *)moContext {
    
    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MIcon"];
    
    // Se asigna una condicion de filtro
    NSPredicate *query = [NSPredicate predicateWithFormat:@"iconHREF=%@", href];
    [request setPredicate:query];
    
    // Se ejecuta y retorna el resultado
    NSError *localError = nil;
    NSArray *array = [moContext executeFetchRequest:request error:&localError];
    if(array==nil) {
        [ErrorManagerService manageError:localError compID:@"Model" messageWithFormat:@"MIcon:iconForHref - Error fetching icon in context [href=%@]", href];
    }
    
    // Si lo ha encontrado lo retorna, sino lo crea
    if(!array || array.count==0) {
        MIcon *icon = [MIcon insertInManagedObjectContext:moContext];
        icon.iconHREF = href;
        icon.name = [MIcon _nameFromIconHREF:href];
        [icon setAutoTag: YES];
        return icon;
    } else {
        NSAssert(array.count==1, @"Shouldn't be more than one icon with the same href = '%@'", href);
        return array[0];
    }
}




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (BOOL) isAutoTag {
    return (self.tag!=nil);
}

//---------------------------------------------------------------------------------------------------------------------
- (void) setAutoTag:(BOOL)value {

    // Solo actua si ha cambiado el valor
    if(value == self.isAutoTag) return;

    // Ahora debe hacer lo contrario a lo que tenga
    if(self.tag==nil) {
        // Antes no lo era y debe añadir los puntos al auto-tag
        MTag *tag = [MTag tagFromIcon:self];
        NSArray *points = [MPoint pointsWithIcon:self];
        for(MPoint *point in points) {
            [tag tagPoint:point];
        }
        self.tag = tag;
    } else {
        // Antes lo era y debe quitar el tag de los puntos
        NSArray *points = [MPoint pointsWithIcon:self];
        for(MPoint *point in points) {
            [self.tag untagPoint:point];
        }
        self.tag=nil;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (UIImage *) image {
    if(_image==nil) {
        _image = [MIcon _loadImageNamed:self.name];
    }
    return _image;
}



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) _imagePath:(NSString *)imgName {
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"MapIconImages.bundle/%@", imgName] ofType:@"png"];
    return imagePath;
}

//---------------------------------------------------------------------------------------------------------------------
+ (UIImage *) _errorImage {
    
    static __strong UIImage *__errorImage = nil;
    
    static dispatch_once_t _predicate;
    dispatch_once(&_predicate, ^{
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"MapIconImages.bundle/GMI_error" ofType:@"png"];
        __errorImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
    });
    return __errorImage;
}

//---------------------------------------------------------------------------------------------------------------------
+ (UIImage *) _loadImageNamed:(NSString *)imgName {
    
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[MIcon _imagePath:imgName]];
    if(image==nil) {
        // AQUI SE PODRIA INTENTAR CARGAR UNA IMAGEN DE OTRO SITIO QUE NO SEA LAS DE POR DEFECTO DE GMAP
        image = [MIcon _errorImage];
    }
    return image;
}

//---------------------------------------------------------------------------------------------------------------------
// Utility method that calculates a "simplified fileName" from the iconHREF
+ (NSString *) _nameFromIconHREF:(NSString *)iconHREF {
    
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
