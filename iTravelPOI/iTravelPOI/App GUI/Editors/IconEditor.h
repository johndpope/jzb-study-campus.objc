//
//  IconEditor.h
//  iTravelPOI
//
//  Created by jzarzuela on 02/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyImageView.h"


@interface IconEditor : UIViewController <MyImageDelegate2> {
}

@property (nonatomic, retain) IBOutlet UIImageView *selectedIcon;
@property (nonatomic, retain) IBOutlet MyImageView *imageMap;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollerView;

@end
