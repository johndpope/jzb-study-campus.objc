//
//  BlockActionSheet.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/02/14.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

#import "BlockActionSheet.h"

@interface BlockActionSheet() <UIActionSheetDelegate>
@property (strong, nonatomic) TActionSheetCode blockCode;
@end

@implementation BlockActionSheet

+ (id)      showInView:(UIView *)view
             withTitle:(NSString *)title
     cancelButtonTitle:(NSString *)cancelButtonTitle
destructiveButtonTitle:(NSString *)destructiveButtonTitle
     otherButtonTitles:(NSArray *)otherButtonTitles
                  code:(TActionSheetCode)code {
    
    BlockActionSheet *me = [[BlockActionSheet alloc] initWithTitle:title
                                                          delegate:nil
                                                 cancelButtonTitle:nil
                                            destructiveButtonTitle:nil
                                                 otherButtonTitles:nil];

    if(destructiveButtonTitle) {
        [me addButtonWithTitle:destructiveButtonTitle];
        me.destructiveButtonIndex = 0;
    } else {
        me.destructiveButtonIndex = -1;
    }
    
    for(NSString *btnTitle in otherButtonTitles) {
        [me addButtonWithTitle:btnTitle];
    }

    if(cancelButtonTitle) {
        [me addButtonWithTitle:cancelButtonTitle];
        me.cancelButtonIndex = me.numberOfButtons-1;
    } else {
        me.cancelButtonIndex = -1;
    }

    me.blockCode = code;
    me.delegate = me;
    [me showInView:view];
    return me;
}

// before animation and hiding view
- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(self.blockCode) {
        self.blockCode(buttonIndex);
    }
}


@end
