//
//  YHSquareView.m
//  YHPhotoBrowser
//
//  Created by ruaho on 2019/7/26.
//  Copyright © 2019 ruaho. All rights reserved.
//

#import "YHSquareView.h"

@interface YHSquareView ()

@property (nonatomic, strong, readwrite) NSMutableArray <UIImageView *>*imageViews;

@end

@implementation YHSquareView

- (instancetype)initWithItems:(NSArray *)items {
    if (self = [super init]) {
        [self _initItems:items];
    }
    return self;
}

- (void)_initItems:(NSArray *)items {
    NSInteger count = items.count;
    for (int i = 0; i < count; i ++) {
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:items[i]]];
        CGFloat margin = 10;
        CGFloat marginLeftRight = 30;
        NSInteger linePre = 3;
        NSInteger realrow = i %linePre;
        NSInteger realsection = i /linePre;

        CGFloat imageWH = ([UIScreen mainScreen].bounds.size.width - 2 *marginLeftRight - (linePre -1)*margin) /linePre *1.0;
        
        imageView.frame = CGRectMake(marginLeftRight + realrow * (imageWH + margin), realsection * (imageWH + margin), imageWH, imageWH);
        imageView.userInteractionEnabled = YES;
        imageView.tag = i;
        imageView.contentMode =  UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
        [imageView addGestureRecognizer:tap];
        
        [self addSubview:imageView];
        [self.imageViews addObject:imageView];
    }
}

- (void)tapClick:(UITapGestureRecognizer *)t {
    NSInteger tag = t.view.tag;
    if (self.callBack) {
        self.callBack(tag);
    }
}


- (NSMutableArray<UIImageView *> *)imageViews {
    if (!_imageViews) {
        _imageViews = [NSMutableArray array];
    }
    return _imageViews;
}

@end
