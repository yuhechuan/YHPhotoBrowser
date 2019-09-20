//
//  YHPhotoDisplayView.h
//  YHPhotoBrowser
//
//  Created by ruaho on 2019/7/11.
//  Copyright © 2019 ruaho. All rights reserved.
//

#ifndef yh_weakify
#if DEBUG
#if __has_feature(objc_arc)
#define yh_weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define yh_weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define yh_weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define yh_weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef yh_strongify
#if DEBUG
#if __has_feature(objc_arc)
#define yh_strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define yh_strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define yh_strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define yh_strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif


#import <UIKit/UIKit.h>

@interface YHPhotoDisplayView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, strong, readonly ) UIImageView *imageView;

- (void)_handleZoomForLocation:(CGPoint)location;
- (void)_scrollToTopAnimated:(BOOL)animated;
- (void)_recoverTransform;

/// Scrolling content offset'y percent.
@property (nonatomic, copy) void(^contentOffSetVerticalPercentHandler)(CGFloat);

/// loosen hand with decelerate
/// velocity: > 0 up, < 0 dwon, == 0 others(no swipe, e.g. tap).
@property (nonatomic, copy) void(^didEndDraggingInProperpositionHandler)(CGFloat velocity);

@end
