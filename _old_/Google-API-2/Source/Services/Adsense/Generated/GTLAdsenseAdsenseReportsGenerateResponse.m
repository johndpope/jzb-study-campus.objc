/* Copyright (c) 2011 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  GTLAdsenseAdsenseReportsGenerateResponse.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   AdSense Management API (adsense/v1.1)
// Description:
//   Gives AdSense publishers access to their inventory and the ability to
//   generate reports
// Documentation:
//   https://code.google.com/apis/adsense/management/
// Classes:
//   GTLAdsenseAdsenseReportsGenerateResponse (0 custom class methods, 7 custom properties)
//   GTLAdsenseAdsenseReportsGenerateResponseHeadersItem (0 custom class methods, 3 custom properties)

#import "GTLAdsenseAdsenseReportsGenerateResponse.h"

// ----------------------------------------------------------------------------
//
//   GTLAdsenseAdsenseReportsGenerateResponse
//

@implementation GTLAdsenseAdsenseReportsGenerateResponse
@dynamic averages, headers, kind, rows, totalMatchedRows, totals, warnings;

+ (NSDictionary *)arrayPropertyToClassMap {
  NSDictionary *map =
    [NSDictionary dictionaryWithObjectsAndKeys:
      [NSString class], @"averages",
      [GTLAdsenseAdsenseReportsGenerateResponseHeadersItem class], @"headers",
      [NSString class], @"rows",
      [NSString class], @"totals",
      [NSString class], @"warnings",
      nil];
  return map;
}

+ (void)load {
  [self registerObjectClassForKind:@"adsense#report"];
}

@end


// ----------------------------------------------------------------------------
//
//   GTLAdsenseAdsenseReportsGenerateResponseHeadersItem
//

@implementation GTLAdsenseAdsenseReportsGenerateResponseHeadersItem
@dynamic currency, name, type;
@end
