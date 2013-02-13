//
//  MBaseEntity.m
//

#define __MBaseEntity__IMPL__
#define __MBaseEntity__PROTECTED__
#define __MBaseEntity__SUBCLASSES__PROTECTED__

#import "MBaseEntity.h"
#import "NSString+JavaStr.h"
#import "ImageManager.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define M_DATE_FORMATTER @"yyyy-MM-dd'T'HH:mm:ss'.'SSSS'Z'"




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface MBaseEntity ()

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation MBaseEntity



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) stringFromDate:(NSDate *)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:M_DATE_FORMATTER];
    // The Z at the end of your string represents Zulu which is UTC
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}




//=====================================================================================================================
#pragma mark -
#pragma mark Getter & Setter methods
//---------------------------------------------------------------------------------------------------------------------




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (NSString *) iconHREF {
    
    NSString *value;

    if([self.iconBaseHREF indexOf:@"?"]==NSNotFound){
        value = [NSString stringWithFormat:@"%@?%@%@", self.iconBaseHREF, URL_PARAM_ITP_INFO, self.iconExtraInfo];
    } else {
        value = [NSString stringWithFormat:@"%@&%@%@", self.iconBaseHREF, URL_PARAM_ITP_INFO, self.iconExtraInfo];
    }
    return value;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) updateDeleteMark:(BOOL) value {
    @throw [NSException exceptionWithName:@"AbstractMethodException" reason:@"Abstract method must be implemented by subclass" userInfo:nil];
}



//=====================================================================================================================
#pragma mark -
#pragma mark Protected methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _resetEntityWithName:(NSString *)name {
    
    self.name = name;
    self.iconBaseHREF = nil;
    self.iconExtraInfo = @"";
    self.published_date = [NSDate date];
    self.updated_date = self.published_date;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _updateIconHREF:(NSString *)iconHREF {
    
    NSString *baseURL = nil;
    NSString *extraInfo = nil;
    [MBaseEntity _parseIconHREF:iconHREF baseURL:&baseURL extraInfo:&extraInfo];
    [self _updateIconBaseHREF:baseURL iconExtraInfo:extraInfo];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _updateIconBaseHREF:(NSString *)baseHREF iconExtraInfo:(NSString *)extraInfo {
    self.iconBaseHREF = baseHREF;
    self.iconExtraInfo = extraInfo;
}



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
// ---------------------------------------------------------------------------------------------------------------------
+ (void) _parseIconHREF:(NSString *)iconHREF baseURL:(NSString **)baseURL extraInfo:(NSString **)extraInfo {
    
    NSUInteger p1, p1_1;
    NSUInteger p2, p2_1;
    
    
    p1 = [iconHREF indexOf:URL_PARAM_ITP_INFO];
    if(p1 == NSNotFound) {
        p1 = iconHREF.length - URL_PARAM_ITP_INFO.length;
        p2 = iconHREF.length;
        p1_1 = iconHREF.length;
        p2_1 = iconHREF.length;
    } else {
        p2 = [iconHREF indexOf:@"&" startIndex:p1];
        if(p2 == NSNotFound) {
            p2 = iconHREF.length;
            p1_1 = p1 - 1;
            p2_1 = p2;
        } else {
            p1_1 = p1;
            p2_1 = p2 + 1;
        }
    }
    

    // Compone la parte del BaseURL
    NSString *strBefore = [iconHREF subStrFrom:0 to:p1_1];
    NSString *strAfter = [iconHREF subStrFrom:p2_1];
    *baseURL = [NSString stringWithFormat:@"%@%@", strBefore, strAfter];
    
    
    // Compone la parte del extraInfo
    NSString *infoValue = [iconHREF subStrFrom:p1 + URL_PARAM_ITP_INFO.length to:p2];
    if(infoValue == nil || infoValue.length == 0) {
        IconData *icon = [ImageManager iconDataForHREF:*baseURL];
        infoValue = icon.shortName;
    }
    if([infoValue hasSuffix:URL_PARAM_ITP_VAL_SEP]) {
        *extraInfo = infoValue;
    } else {
        *extraInfo = [NSString stringWithFormat:@"%@%@", infoValue, URL_PARAM_ITP_VAL_SEP];
    }
}



@end
