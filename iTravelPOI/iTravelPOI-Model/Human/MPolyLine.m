//
//  MPolyLine.m
//

#define __MPolyLine__IMPL__
#define __MPolyLine__PROTECTED__
#define __MPoint__PROTECTED__
#define __MBase__SUBCLASSES__PROTECTED__
#define __MBaseSync__SUBCLASSES__PROTECTED__


#import "MPolyLine.h"
#import "MMap.h"
#import "MIcon.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define DEFAULT_POLYLINE_ICON_HREF @"http://maps.gstatic.com/mapfiles/ms2/micons/landmarks-jp.png"




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface MPolyLine ()

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation MPolyLine




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) _myEntityName {
    return @"MPolyLine";
}

//---------------------------------------------------------------------------------------------------------------------
+ (MPolyLine *) emptyPolyLineWithName:(NSString *)name inMap:(MMap *)map  {
    
    NSManagedObjectContext *moContext = map.managedObjectContext;
    
    MPolyLine *polyLine = [MPolyLine insertInManagedObjectContext:moContext];
    [polyLine _resetEntityWithName:name inContext:moContext];
    polyLine.map = map;
    [map markAsModified];
    
    return polyLine;
}





//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) deleteEntity {

    // Nada especial de momento
    [super deleteEntity];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) setColor:(UIColor *)color {
    
    CGFloat red, green, blue, alpha;
    
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    unsigned int uiAlpha = (unsigned int)(alpha*255.0);
    unsigned int uiBlue  = (unsigned int)(blue*255.0);
    unsigned int uiGreen = (unsigned int)(green*255.0);
    unsigned int uiRed   = (unsigned int)(red*255.0);

    unsigned int hexValue = ((uiAlpha<<24)&0xFF000000) | ((uiBlue<<16)&0x00FF0000) | ((uiGreen<<8)&0x0000FF00) | (uiRed&0x000000FF);
    self.hexColorValue = hexValue;

    [self markAsModified];
}

//---------------------------------------------------------------------------------------------------------------------
- (UIColor *) color {

    unsigned int hexValue = self.hexColorValue;
    
    int a = (hexValue >> 24) & 0xFF;
    int b = (hexValue >> 16) & 0xFF;
    int g = (hexValue >>  8) & 0xFF;
    int r = (hexValue)       & 0xFF;
    
    UIColor *color = [UIColor colorWithRed:r/255.0f green:g / 255.0f blue:b / 255.0f alpha:a / 255.0f];
    
    return color;
}


//---------------------------------------------------------------------------------------------------------------------
- (void) setCoordinatesFromLocations:(NSArray *)locations {

    for(MCoordinate *coord in [self.coordinates copy]) {
    
        [self removeCoordinatesObject:coord];
        [self.managedObjectContext deleteObject:coord];
    }
    
    for(CLLocation *loc in locations) {
        MCoordinate *coord = [MCoordinate insertInManagedObjectContext:self.managedObjectContext];
        coord.latitudeValue = loc.coordinate.latitude;
        coord.longitudeValue = loc.coordinate.longitude;
        [self addCoordinatesObject:coord];
    }

    [self markAsModified];
}



//=====================================================================================================================
#pragma mark -
#pragma mark Protected methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _resetEntityWithName:(NSString *)name inContext:(NSManagedObjectContext *)moContext {
    
    [super _resetEntityWithName:name icon:[MIcon iconForHref:DEFAULT_POLYLINE_ICON_HREF inContext:moContext]];
    self.descr = @"";
    self.latitudeValue = 0.0;
    self.longitudeValue = 0.0;
}


//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------




@end
