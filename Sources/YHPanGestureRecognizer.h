//
//  YHPanGestureRecognizer.h
//  YHPhotoBrowser
//
//  Created by ruaho on 2019/7/11.
//  Copyright © 2019 ruaho. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef int(^IsCheckMoved)(void);

@interface YHPanGestureRecognizer : UIPanGestureRecognizer

/**
 是否自动锁住手势方向，默认为NO
 如果设置成YES，则在手势开始时根据x的偏移量大小来确定最可能的滑动方向，并在手势有效期内保持这个方向上的有效性
 */
@property (nonatomic, assign) BOOL  autoHorLock;

/*
 受众 是否开启检测 如果不存在 则默认走检测 ,如果存在 且返回YES 检测  为NO 不检测直接使f当前手势时效
 */
@property (nonatomic, copy)IsCheckMoved isMoved;


@end

NS_ASSUME_NONNULL_END
