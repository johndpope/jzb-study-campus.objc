//
//  MyCategory.h
//  JZBTest
//
//  Created by Snow Leopard User on 14/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyClass.h"

@interface MyClass(MyCategory)
- (void) boundMethod_WithChar:(char)c;
@end
