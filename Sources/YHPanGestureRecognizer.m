//
//  YHPanGestureRecognizer.m
//  YHPhotoBrowser
//
//  Created by ruaho on 2019/7/11.
//  Copyright © 2019 ruaho. All rights reserved.
//

#import "YHPanGestureRecognizer.h"

typedef NS_ENUM(NSInteger, YHPanDirection) {
    YHPanDirectionAny = 0,
    YHPanDirectionHor,       // 理论上的开始横向
    YHPanDirectionVer
};

@interface YHPanGestureRecognizer()

@property (nonatomic, assign) YHPanDirection    direction;
@property (nonatomic, assign) CGPoint           beginPoint;

@end


@implementation YHPanGestureRecognizer

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (_autoHorLock) {
        _direction = YHPanDirectionAny;
        _beginPoint = [[touches anyObject] locationInView:nil];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    if (!_autoHorLock) {
        return;
    }
    
    int isMovedValue = self.isMoved?self.isMoved():1;
    
    if (isMovedValue == -1) {
        self.state = UIGestureRecognizerStateFailed;
        return;  // 不开启检测 并且失效
    }
    CGPoint nowPoint = [[touches anyObject] locationInView:nil];
    CGFloat offsetx = _beginPoint.x - nowPoint.x;
    CGFloat offsety = _beginPoint.y - nowPoint.y;
    
    if (isMovedValue == 0 && offsety > 0) {
        self.state = UIGestureRecognizerStateFailed;
        return;  // 不开启检测 并且失效
    }
    
    if (isMovedValue > 1 && offsety < 0) {
        self.state = UIGestureRecognizerStateFailed;
        return;  // 不开启检测 并且失效
    }

    if (_direction == YHPanDirectionAny && (offsetx != 0 || offsety != 0)) {
        offsetx = fabs(offsetx);
        offsety = fabs(offsety);
        //NSLog(@"offsetx == %f offsety ==%f",offsetx,offsety);
        if (offsetx > offsety) {
            _direction = YHPanDirectionHor;
            self.state = UIGestureRecognizerStateFailed;
        } else {
            _direction = YHPanDirectionVer;
        }
    } else if (_direction == YHPanDirectionHor) {
        self.state = UIGestureRecognizerStateFailed;
    } else {
        
    }
}



@end
