//
//  KxMenu.h
//  kxmenu project
//  https://github.com/kolyvan/kxmenu/
//
//  Created by Kolyvan on 17.05.13.
//

/*
 Copyright (c) 2013 Konstantin Bukreev. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 - Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


#import <Foundation/Foundation.h>

@interface KxMenuItem : NSObject

@property (strong, nonatomic, strong) UIImage *image;
@property (strong, nonatomic, strong) NSString *title;
@property (weak, nonatomic, weak) id target;
@property (assign, nonatomic) SEL action;
@property (strong, nonatomic, strong) UIColor *foreColor;
@property (assign, nonatomic) NSTextAlignment alignment;
@property (strong, nonatomic) id cmdData;


+ (instancetype) menuItem:(NSString *) title
                    image:(UIImage *) image
                   target:(id)target
                   action:(SEL) action
                  cmdData:(id) cmdData;

@end

@interface KxMenu : NSObject

+ (void) showMenuInView:(UIView *)view
               fromRect:(CGRect)rect
              menuItems:(NSArray *)menuItems;

+ (void) dismissMenu;

+ (UIColor *) tintColor;
+ (void) setTintColor: (UIColor *) tintColor;

+ (UIFont *) titleFont;
+ (void) setTitleFont: (UIFont *) titleFont;

@end
