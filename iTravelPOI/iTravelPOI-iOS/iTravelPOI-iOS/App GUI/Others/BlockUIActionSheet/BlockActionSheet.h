//
//  BlockActionSheet.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/02/14.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BlockActionSheet;
typedef void (^TActionSheetCode)(BlockActionSheet *actionSheet, NSInteger buttonIndex);

@interface BlockActionSheet : UIActionSheet

+ (id)      showInView:(UIView *)view
             withTitle:(NSString *)title
     cancelButtonTitle:(NSString *)cancelButtonTitle
destructiveButtonTitle:(NSString *)destructiveButtonTitle
     otherButtonTitles:(NSArray *)otherButtonTitles
                  code:(TActionSheetCode)code;

@end
