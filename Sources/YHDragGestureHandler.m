//
//  YHDragGestureHandler.m
//  YHPhotoBrowser
//
//  Created by ruaho on 2019/7/24.
//  Copyright © 2019 ruaho. All rights reserved.
//

#import "YHDragGestureHandler.h"
#import "YHPanGestureRecognizer.h"

@interface YHDragGestureHandler ()<UIGestureRecognizerDelegate>

@property (nonatomic, assign) CGRect gestureViewOriginFrame;     // 原始位置
@property (nonatomic,   weak) UIView *gestureView;               // 手势的对象视图
@property (nonatomic,   weak) UIView *blurView;                  // 背景视图
@property (nonatomic, assign) CGFloat referenceHeight;           // 参考高度

@end

@implementation YHDragGestureHandler

- (instancetype)initWithGestureView:(UIView *)gestureView {
    return [self initWithGestureView:gestureView
                            blurView:nil];
}

- (instancetype)initWithGestureView:(UIView *)gestureView
                           blurView:(UIView *)blurView {
    self = [super init];
    if (!self) {
        return nil;
    }
    _gestureView = gestureView;
    _blurView = blurView;
    CGFloat height = gestureView.frame.size.height;
    _referenceHeight = height > 0?height:[UIScreen mainScreen].bounds.size.height;
    YHPanGestureRecognizer *pan = [[YHPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
    pan.autoHorLock = YES;
    pan.delegate = self;
    __weak typeof(self) weakSelf = self;
    pan.isMoved = ^int{
        return [weakSelf isMoved];
    };
    [_gestureView addGestureRecognizer:pan];
    
    return self;
}

- (void)panAction:(UIPanGestureRecognizer *)gesture {
    if (self.gestureView == nil) {
        return;
    }
    
    CGPoint pointVelocity = [gesture velocityInView:self.gestureView];
    CGPoint changePoint = [gesture translationInView:self.gestureView];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        self.gestureViewOriginFrame = self.gestureView.frame;
        
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
     
        //背景的一半高度作为参照
        CGFloat halfHeight = _referenceHeight * 0.5;
        CGFloat surplus = ABS(changePoint.y) > halfHeight ? halfHeight : ABS(changePoint.y);
        CGFloat scale = surplus/halfHeight *1.0;
        
        // 判断在下面 还是在上面
        CGFloat originy = self.gestureViewOriginFrame.origin.y;
        CGFloat nowy = self.gestureView.frame.origin.y;
        CGFloat offsety = nowy - originy;
        NSString *moveType = nil;
        if (offsety < 0) { // 在中心线上边
            if (changePoint.y < 0) {
                moveType = @"del";
            } else {
                moveType = @"add";
            }
        } else {// 在中心线下边
            if (changePoint.y < 0) {
                moveType = @"add";
            } else {
                moveType = @"del";
            }
        }
        
        //transform的scale
        CGFloat frameScale;
        if ([moveType isEqualToString:@"add"]) {
            frameScale = 1 + 0.5 * scale;
        } else {
            frameScale = 1 - 0.5 * scale;
        }
        
        CGAffineTransform transform = self.gestureView.transform;
        
        transform = CGAffineTransformScale(transform, frameScale,frameScale);
        transform = CGAffineTransformTranslate(transform, changePoint.x,changePoint.y);
        self.gestureView.transform = transform;
        [gesture setTranslation:CGPointZero inView:self.gestureView];
        
        float alphaValue = (_referenceHeight - fabs(offsety)) / _referenceHeight *1.0;
        if (self.blurView) {
            self.blurView.alpha = alphaValue;
        }
        if (self.dragBlock) {
            self.dragBlock();
        }
        if (self.alphaValueChangeBlock) {
            self.alphaValueChangeBlock(alphaValue);
        }
        
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
     
        float offsety = fabs(self.gestureView.frame.origin.y - self.gestureViewOriginFrame.origin.y);
        //如果放手的瞬时速度大于100或者偏移距离大于100，则走回调
        if (fabs(pointVelocity.y) > 100 || offsety > 80) {
            if (self.completeBlock != nil) {
                self.completeBlock(true, pointVelocity.y);
            }
        }else {
            [UIView animateWithDuration:0.3 animations:^{
                self.gestureView.transform = CGAffineTransformIdentity;
                self.gestureView.frame = self.gestureViewOriginFrame;
                if (self.blurView) {
                    self.blurView.alpha = 1.0;
                }
                if (self.alphaValueChangeBlock) {
                    self.alphaValueChangeBlock(1.0);
                }
            }];
            if (self.completeBlock != nil) {
                self.completeBlock(false, pointVelocity.y);
            }
        }
    }
}

- (int)isMoved {
    UIScrollView *scrollView = nil;
    if ([self.gestureView isKindOfClass:[UIScrollView class]]) {
        scrollView = (UIScrollView *)self.gestureView;
    } else if ([self.gestureView.superview isKindOfClass:[UIScrollView class]]) {
        scrollView = (UIScrollView *)self.gestureView.superview;
    } else {
        
    }
    
    if (!scrollView) {
        return 1;
    }
    
    if (scrollView.contentSize.height <= scrollView.frame.size.height) {
        return 1;
    }
    
    CGFloat contentOffsety = scrollView.contentOffset.y;
    //NSLog(@"scrollView.contentOffset.y == %f",contentOffsety);
    if (contentOffsety == 0 || contentOffsety == scrollView.contentSize.height - scrollView.frame.size.height) {
        return contentOffsety; // 支持长图的滑动
    }
    return -1;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] || [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}


@end
