//
// GEOCoding_Test.m
// GMapAPI
//
// Created by Jose Zarzuela on 07/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import "GEOCoding_Test.h"

#import "DDLog.h"
#import "SimpleXMLReader.h"
#import "Placemark.h"
#import "NSString+JavaStr.h"
#import <CoreLocation/CoreLocation.h>



@interface GEOCoding_Test ()

@property (strong) NSMutableArray *placemarks;

@end


@implementation GEOCoding_Test

@synthesize placemarks = _placemarks;


// ---------------------------------------------------------------------------------------------------------------------
+ (void) testGeocoding {

    GEOCoding_Test *test = [[GEOCoding_Test alloc] init];

    [test _searchWithGeoCoder];
    return ;

    [test _readPlacemarks];

    static long numRequests = 0;
    for(int n = 0; n < 10000; n++) {
        double lat = 40.0 + (random() % 400 - 200) / 100.0;
        double lng = -4.0 + (random() % 400 - 200) / 100.0;
        DDLogVerbose(@" count = %ld, lat = %f, lng = %f", ++numRequests, lat, lng);
        [test _searchPlacemarkLat:lat lng:lng];
    }
    [test _searchPlacemarkLat:37.28662 lng:-2.18124];
    [test _searchPlacemarkLat:40.063 lng:-4.857];
    [test _searchPlacemarkLat:40.00822 lng:-5.29672];
    [test _searchPlacemarkLat:40.3604 lng:-2.3959];

}

// ---------------------------------------------------------------------------------------------------------------------
+ (void) transformISOtoUTF {
    NSString *fileNameIn = @"/Users/jzarzuela/Downloads/_tmp_/kk/ESP_adm4.kml";
    NSString *fileNameOut = @"/Users/jzarzuela/Downloads/_tmp_/kk/ESP_adm4-UTF.kml";
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:fileNameIn];
    if(xmlData != nil) {
        DDLogVerbose(@"algo se ha leido 1");
    }

    NSString *content = [[NSString alloc] initWithData:xmlData encoding:NSWindowsCP1250StringEncoding];
    if(content != nil) {
        DDLogVerbose(@"algo se ha leido 2");
    }

    NSData *utfData = [content dataUsingEncoding:NSUTF8StringEncoding];
    if(utfData != nil) {
        DDLogVerbose(@"algo se ha leido 3");
    }

    if(![utfData writeToFile:fileNameOut atomically:true]) {
        DDLogVerbose(@"escrito ok");
    }

    xmlData = [[NSData alloc] initWithContentsOfFile:fileNameOut];
    if(xmlData != nil) {
        DDLogVerbose(@"algo se ha leido UTF");
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _searchWithGeoCoder {

    static long numRequests = 0;

    double lat = 40 + random() % 10 - 5;
    double lng = -4 + random() % 4 - 2;
    DDLogVerbose(@" count = %ld, lat = %f, lng = %f", ++numRequests, lat, lng);

    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];

    [geocoder reverseGeocodeLocation:location completionHandler: ^(NSArray * placemarks, NSError * error) {

         if(error) {
             DDLogVerbose (@"ERROR - reverseGeocodeLocation:completionHandler: %@", error);
             return;
         }
         if(placemarks && placemarks.count > 0) {
             DDLogVerbose (@"All OK - reverseGeocodeLocation:completionHandler: %ld", ++numRequests);
             // do something
             CLPlacemark *topResult = [placemarks objectAtIndex:0];

             NSMutableString *addressInfo = [NSMutableString string];

             [addressInfo appendFormat:@"location = %@\n", topResult.location];
             [addressInfo appendFormat:@"name = %@\n", topResult.name];
             [addressInfo appendFormat:@"addressDictionary = %@\n", topResult.addressDictionary];
             [addressInfo appendFormat:@"ISOcountryCode = %@\n", topResult.ISOcountryCode];
             [addressInfo appendFormat:@"country = %@\n", topResult.country];
             [addressInfo appendFormat:@"postalCode = %@\n", topResult.postalCode];
             [addressInfo appendFormat:@"administrativeArea = %@\n", topResult.administrativeArea];
             [addressInfo appendFormat:@"subAdministrativeArea = %@\n", topResult.subAdministrativeArea];
             [addressInfo appendFormat:@"locality = %@\n", topResult.locality];
             [addressInfo appendFormat:@"subLocality = %@\n", topResult.subLocality];
             [addressInfo appendFormat:@"thoroughfare = %@\n", topResult.thoroughfare];
             [addressInfo appendFormat:@"subThoroughfare = %@\n", topResult.subThoroughfare];
             [addressInfo appendFormat:@"region = %@\n", topResult.region];
             [addressInfo appendFormat:@"inlandWater = %@\n", topResult.inlandWater];
             [addressInfo appendFormat:@"ocean = %@\n", topResult.ocean];
             [addressInfo appendFormat:@"areasOfInterest = %@\n", topResult.areasOfInterest];

             DDLogVerbose (@" address info = \n%@", addressInfo);

             // dispatch_async(dispatch_get_main_queue(), ^(void){
             // [self _searchWithGeoCoder];
             // });

         }
     }];

}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) _searchPlacemarkLat:(double)lat lng:(double)lng {

    for(Placemark *p in self.placemarks) {

        if(lat < p.minLat || lat > p.maxLat || lng < p.minLng || lng > p.maxLng)
            continue;

        double *polyLat = calloc(p.count, sizeof(double));
        double *polyLng = calloc(p.count, sizeof(double));
        for(int n = 0; n < p.count; n++) {
            polyLat[n] = [p.pointsLat[n] doubleValue];
            polyLng[n] = [p.pointsLng[n] doubleValue];
        }
        int isContained = pnpoly((int)p.count, polyLat, polyLng, lat, lng);

        free(polyLat);
        free(polyLng);

        if(isContained != 0) {

            DDLogVerbose(@"name = %@", p.name);
            return true;
        }
    }

    return false;


}

// ---------------------------------------------------------------------------------------------------------------------
int pnpoly (int nvert, double *vertx, double *verty, double testx, double testy){
    int i, j, c = 0;
    for(i = 0, j = nvert - 1; i < nvert; j = i++) {
        if(((verty[i] > testy) != (verty[j] > testy)) &&
           (testx < (vertx[j] - vertx[i]) * (testy - verty[i]) / (verty[j] - verty[i]) + vertx[i]))
            c = !c;
    }
    return c;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _readPlacemarks {

    self.placemarks = [NSMutableArray array];

    NSString *fileName = @"/Users/jzarzuela/Downloads/_tmp_/kk/ESP_adm4.kml";
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:fileName];

    NSError *error;
    NSDictionary *dict = [SimpleXMLReader dictionaryForXMLData:xmlData error:&error];
    DDLogVerbose(@"error = %@", error);

    NSArray *items = [dict valueForKeyPath:@"kml.Document.Placemark"];
    if([items isKindOfClass:[NSDictionary class]]) {
        items = [NSArray arrayWithObject:items];
    }
    for(NSDictionary *item in items) {

        NSString *name = [[item valueForKeyPath:@"name.text"] trim];
        NSString *descr = [[item valueForKeyPath:@"description.text"] trim];

        NSArray *polygons = [item valueForKeyPath:@"MultiGeometry.Polygon"];
        if([polygons isKindOfClass:[NSDictionary class]]) {
            polygons = [NSArray arrayWithObject:polygons];
        }

        for(NSDictionary *poly in polygons) {

            Placemark *p = [[Placemark alloc] init];
            p.name = name;
            p.descr = descr;

            NSString *coordinates = [poly valueForKeyPath:@"outerBoundaryIs.LinearRing.coordinates.text"];
            NSArray *coordList = [coordinates componentsSeparatedByString:@"\n"];
            for(NSString *value in coordList) {
                NSArray *splittedStr = [value componentsSeparatedByString:@","];
                if(splittedStr.count == 2) {
                    // en un kml estan al reves (lng, lat)
                    double lat = [splittedStr[1] doubleValue];
                    double lng = [splittedStr[0] doubleValue];
                    [p.pointsLat addObject:[NSNumber numberWithDouble:lat]];
                    [p.pointsLng addObject:[NSNumber numberWithDouble:lng]];
                    p.minLat = p.minLat > lat ? lat : p.minLat;
                    p.maxLat = p.maxLat < lat ? lat : p.maxLat;
                    p.minLng = p.minLng > lng ? lng : p.minLng;
                    p.maxLng = p.maxLng < lng ? lng : p.maxLng;
                }
            }

            [self.placemarks addObject:p];

        }
    }


}

@end
