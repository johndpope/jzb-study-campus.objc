//
//  MyImageView.h
//  iTravelPOI
//
//  Created by jzarzuela on 02/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol MyImageDelegate2 <NSObject>

- (void) setSelectedImage:(UIImage *) image;

@end

@interface MyImageView : UIImageView {
    
}

@property (nonatomic, assign) id<MyImageDelegate2> delegate2;

@end
