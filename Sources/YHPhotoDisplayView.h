//
//  YHPhotoDisplayView.h
//  YHPhotoBrowser
//
//  Created by ruaho on 2019/7/11.
//  Copyright © 2019 ruaho. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
