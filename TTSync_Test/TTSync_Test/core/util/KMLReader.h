//
//  KMLReader.h
//  JZBTest
//
//  Created by Snow Leopard User on 15/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KMLReader : NSObject {
@private
    
}

+ (void) readKMLFileFromPath: (NSString *)filePath allowDuplicated: (BOOL) allow;	


@end


/**
private static function _cleanHTML(str:String) : String {
    
    var list:Array = str.split(/<[^>]*>/g);
    str = list.join("");
    str = str.replace(/&lt;/g,"<").replace(/&gt;/g,">").replace(/&amp;/g,"&").replace(/&nbsp;/g," ");
    return str;
    
}
**/