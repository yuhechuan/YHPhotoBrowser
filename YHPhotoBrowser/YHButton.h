//
//  YHButton.h
//  YHButton
//
//  Created by apple on 2017/6/8.
//  Copyright © 2017年 玉河川. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^Operation)(void);

@interface YHButton : UIButton

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIColor *buttonColor;
@property (nonatomic, copy) Operation operation;

@end
