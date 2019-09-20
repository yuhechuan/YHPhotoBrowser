//
//  YHPresentAnimatedTransitioningController.h
//  PhotoBrowser
//
//  Created by ruaho on 2019/7/24.
//  Copyright © 2019 ruaho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^YHContextBlock)(UIView * __nonnull fromView, UIView * __nonnull toView);

@interface YHPresentAnimatedTransitioningController : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, copy, nullable) YHContextBlock willPresentActionHandler;
@property (nonatomic, copy, nullable) YHContextBlock onPresentActionHandler;
@property (nonatomic, copy, nullable) YHContextBlock didPresentActionHandler;
@property (nonatomic, copy, nullable) YHContextBlock willDismissActionHandler;
@property (nonatomic, copy, nullable) YHContextBlock onDismissActionHandler;
@property (nonatomic, copy, nullable) YHContextBlock didDismissActionHandler;


- (nonnull YHPresentAnimatedTransitioningController *)prepareForPresent;
- (nonnull YHPresentAnimatedTransitioningController *)prepareForDismiss;

@end
