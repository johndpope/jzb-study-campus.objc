//
//  MPoint.m
//

#define __MPoint__IMPL__
#define __MPoint__PROTECTED__
#define __MBase__SUBCLASSES__PROTECTED__
#define __MBaseSync__SUBCLASSES__PROTECTED__


#import "MPoint.h"
#import "MMap.h"
#import "MIcon.h"
#import "MTag.h"
#import "RPointTag.h"
#import "ErrorManagerService.h"
#import "BenchMark.h"
#import "NSString+JavaStr.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define DEFAULT_POINT_ICON_HREF @"http://maps.gstatic.com/mapfiles/ms2/micons/blue-dot.png"




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface MPoint ()

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation MPoint

@synthesize directTags = _directTags;
@synthesize directNoAutoTags = _directNoAutoTags;
@synthesize coordinate = _coordinate;
@synthesize viewDistance = _viewDistance;
@synthesize viewStringDistance = _viewStringDistance;



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) _myEntityName {
    return @"MPoint";
}

//---------------------------------------------------------------------------------------------------------------------
+ (MPoint *) emptyPointWithName:(NSString *)name inMap:(MMap *)map  {
    
    NSManagedObjectContext *moContext = map.managedObjectContext;
    
    MPoint *point = [MPoint insertInManagedObjectContext:moContext];
    [point _resetEntityWithName:name inContext:moContext];
    point.map = map;
    [map markAsModified];
    
    return point;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) allWithMap:(MMap *)map sortOrder:(NSArray *)sortOrder {

    BenchMark *benchMark = [BenchMark benchMarkLogging:@"MPoint:pointsWithMap"];
    
    // Se protege contra un filtro vacio
    if(!map) {
        [benchMark logTotalTime:@"Returning nil because map was empty"];
        return nil;
    }
    
    // Crea la condicion de filtro
    NSPredicate *query = [NSPredicate predicateWithFormat:@"markedAsDeleted=NO AND map=%@", map];

    // Se ejecuta y retorna el resultado
    return [super _allWithPredicate:query sortOrder:sortOrder inContext:map.managedObjectContext];
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSMutableSet *) allTagsFromPoints:(NSArray *)points {

    NSMutableSet *allTags = [NSMutableSet set];
    for(MPoint *point in points) {
        for(RPointTag *rpt in point.rTags) {
            [allTags addObject:rpt.tag];
        }
    }
    return allTags;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSMutableSet *) allNonAutoTagsFromPoints:(NSArray *)points {
    
    NSMutableSet *allTags = [NSMutableSet set];
    for(MPoint *point in points) {
        for(RPointTag *rpt in point.rTags) {
            if(!rpt.tag.isAutoTagValue) [allTags addObject:rpt.tag];
        }
    }
    return allTags;
}




//=====================================================================================================================
#pragma mark -
#pragma mark <MKAnnotation> Protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (CLLocationCoordinate2D) coordinate {

    CLLocationCoordinate2D coord = {self.latitudeValue, self.longitudeValue};
    return coord;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSString *) title {
    return self.name;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSString *) subtitle {
    return @"kkvaca";
}




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) deleteEntity {
    
    // Marca el mapa como modificado y se elimina
    [self.map markAsModified];
    self.map = nil;

    self.descr = nil;
    self.latitudeValue = self.longitudeValue = 0.0;
    
    [super deleteEntity];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) markAsDeleted:(BOOL) value {
    
    [super markAsDeleted:value];

    if(self.markedAsDeletedValue != value) {
       
        // Marca el mapa como modificado
        [self.map markAsModified];
    }
    
    if(value == TRUE) {
        // Borra la relacion con todos sus tags
        for(RPointTag *rpt in [self.rTags copy]) {
            [rpt deleteEntity];
        }
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) markAsModified {
    
    // Marca el mapa como modificado
    [self.map markAsModified];
    
    [super markAsModified];
}

//---------------------------------------------------------------------------------------------------------------------
- (NSSet *)directTags {
    
    NSMutableSet *allTags = [NSMutableSet set];
    for(RPointTag *rpt in self.rTags) {
        if(rpt.isDirectValue) {
            [allTags addObject:rpt.tag];
        }
    }
    return  allTags;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSSet *) directNoAutoTags {
    
    NSMutableSet *allTags = [NSMutableSet set];
    for(RPointTag *rpt in self.rTags) {
        if(rpt.isDirectValue && !rpt.tag.isAutoTagValue) {
            [allTags addObject:rpt.tag];
        }
    }
    return  allTags;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateDesc:(NSString *)value {
    
    if((value || self.descr) && ![self.descr isEqualToString:value]) {
        [self markAsModified];
        self.descr = value;
        return TRUE;
    }
    return FALSE;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateIcon:(MIcon *)icon {
    
    MTag *prevIconTag = self.icon.tag;

    // Llama a la clase base para que actualice la informacion
    BOOL result = [super updateIcon:icon];
    if(result) {
        
        // Actualiza el auto-tag debido al icono asignado
        [prevIconTag untagPoint:self];
        [self.icon.tag tagPoint:self];
    }
    return result;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateLatitude:(double)lat longitude:(double)lng {
    
    // Ajusta los margenes
    lat = MAX(lat, -90.0);
    lat = MIN(lat, 90.0);
    lng = MAX(lng, -180.0);
    lng = MIN(lng, 180.0);
    
    // Si hay un cambio de coordenadas las establece
    if(self.latitudeValue!=lat || self.longitudeValue!=lng) {
        self.latitudeValue = lat;
        self.longitudeValue = lng;
        return TRUE;
    } else {
        return FALSE;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) removeAllNonAutoTags {
    
    for(MTag *tag in [self.directNoAutoTags copy]) {
        [tag untagPoint:self];
    }
}

//---------------------------------------------------------------------------------------------------------------------
// With format: $[tag1, tag2, ...]$
- (NSString *) combinedDescAndTagsInfo {

    NSMutableString *tagsText = [NSMutableString stringWithString:@""];
    BOOL first = TRUE;
    for(MTag *tag in self.directNoAutoTags) {
        if(first) {
            [tagsText appendString:tag.name];
        } else {
            [tagsText appendFormat:@", %@", tag.name];
        }
        first = FALSE;
    }

    if(tagsText.length>0) {
        NSString *combinedValue = [NSString stringWithFormat:@"$[%@]$%@",tagsText,self.descr];
        return combinedValue;
    } else {
        return self.descr;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) updateFromCombinedDescAndTagsInfo:(NSString *)descAndTags {

    // Borra los tags actuales porque seran sustituidos por los indicados
    // En cualquier caso los Tags se sustituiran por el contenido
    [self removeAllNonAutoTags];

    // Busca la informacion de tags en el punto GMap
    NSUInteger p1 = [descAndTags indexOf:@"$["];
    NSUInteger p2 = [descAndTags indexOf:@"]$"];
    if(p1==NSNotFound || p2==NSNotFound || p1>=p2) {
        
        // Pone la descripcion tal cual esta en el GMTPoint
        [self updateDesc:descAndTags];
        
    } else {
        
        NSString *txt1 = [descAndTags subStrFrom:0 to:p1];
        NSString *txt2 = [descAndTags subStrFrom:2+p2];
        
        // Extrae la descripcion "limpia"
        NSString *cleanDesc = [NSString stringWithFormat:@"%@%@",txt1, txt2];
        [self updateDesc:cleanDesc];
        
        // Extrae la informacion de los tags
        NSString *tagsStr = [descAndTags subStrFrom:2+p1 to:p2];
        
        // Divide el contenido por las comas y establece los tags
        NSArray *tagNames = [tagsStr componentsSeparatedByString:@","];
        for(NSString *tagName in tagNames) {
            NSString *trimmedName = [tagName trim];
            if(trimmedName.length>0) {
                MTag *tag = [MTag tagWithFullName:trimmedName inContext:self.managedObjectContext];
                [tag tagPoint:self];
            }
        }
    }

}



//=====================================================================================================================
#pragma mark -
#pragma mark Protected methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _resetEntityWithName:(NSString *)name inContext:(NSManagedObjectContext *)moContext {
    
    [super _resetEntityWithName:name icon:[MIcon iconForHref:DEFAULT_POINT_ICON_HREF inContext:moContext]];
    self.descr = @"";
    self.latitudeValue = 0.0;
    self.longitudeValue = 0.0;
}


//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------




@end
