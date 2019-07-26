//
//  YHDragGestureHandler.h
//  YHPhotoBrowser
//
//  Created by ruaho on 2019/7/24.
//  Copyright © 2019 ruaho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import<UIKit/UIKit.h>

@interface YHDragGestureHandler : NSObject
/*
 *手势结束的回调
 */
@property (nonatomic, copy) void (^completeBlock)(BOOL finish, CGFloat velocity);
/*
 * 有拖拽效果的拖拽回调
 */
@property (nonatomic, copy) void (^dragBlock)(void);
/*
 *需要背景色进行变化时调用
 */
@property (nonatomic, copy) void (^alphaValueChangeBlock)(float alphaValue);

/*
 * 手势冲突解决方案
 */
@property (nonatomic, copy) void (^scrollViewConflictBlock)(CGFloat contentOffsety);

/*
 * 只有手势识别view
 */
- (instancetype)initWithGestureView:(UIView *)gestureView;

/*
 * 添加背景颜色调整view
 */
- (instancetype)initWithGestureView:(UIView *)gestureView
                           blurView:(UIView *)blurView;


@end

