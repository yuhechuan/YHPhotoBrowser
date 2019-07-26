//
//  YHButton.m
//  YHButton
//  Created by apple on 2017/6/8.
//  Copyright © 2017年 玉河川. All rights reserved.
//

#import "YHButton.h"

@implementation YHButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self= [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addTarget:self action:@selector(tapClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)tapClick {
    UIViewAnimationOptions op = UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:0.1 delay:0 options:op animations:^{
        [self.layer setValue:@(0.97) forKeyPath:@"transform.scale"];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 delay:0 options:op animations:^{
            [self.layer setValue:@(1.008) forKeyPath:@"transform.scale"];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0 options:op animations:^{
                [self.layer setValue:@(1) forKeyPath:@"transform.scale"];
            } completion:^(BOOL finished) {
                self.operation();
            }];
        }];
    }];
}

- (void)setTitle:(NSString *)title {
    [self setTitle:title forState:UIControlStateNormal];
}

- (void)setButtonColor:(UIColor *)buttonColor {
    [self setBackgroundColor:buttonColor];
}

@end
