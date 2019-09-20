//
//  YHPresentAnimatedTransitioningController.m
//  PhotoBrowser
//  Created by ruaho on 2019/7/24.
//  Copyright © 2019 ruaho. All rights reserved.
//

#import "YHPresentAnimatedTransitioningController.h"
#import "YHPhotoDisplayView.h"

@interface YHPresentAnimatedTransitioningController ()
@property (nonatomic, assign) BOOL isPresenting;
@end

@implementation YHPresentAnimatedTransitioningController

#pragma mark - Public methods

- (nonnull YHPresentAnimatedTransitioningController *)prepareForPresent {
    self.isPresenting = YES;
    return self;
}

- (nonnull YHPresentAnimatedTransitioningController *)prepareForDismiss {
    self.isPresenting = NO;
    return self;
}

#pragma mark - Private methods

- (UIViewAnimationOptions)_animationOptions {
    return 7 << 16;
}

- (void)_animateWithTransition:(nullable id <UIViewControllerContextTransitioning>)transitionContext
                    animations:(void (^)(void))animations
                    completion:(void (^)(BOOL flag))completion {
    // Prevent other interactions disturb.
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
                        options:[self _animationOptions]
                     animations:animations
                     completion:^(BOOL finished) {
                         completion(finished);
                         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                     }];
}

- (void)_presentWithTransition:(id <UIViewControllerContextTransitioning>)transitionContext
                     container:(UIView *)container
                          from:(UIView *)fromView
                            to:(UIView *)toView
                    completion:(void (^)(BOOL flag))completion {

    toView.frame = container.bounds;
    [container addSubview:toView];
    
    if (self.willPresentActionHandler) {
        self.willPresentActionHandler(fromView, toView);
    }
    @yh_weakify(self)
    [self _animateWithTransition:transitionContext
                      animations:^{
                          @yh_strongify(self)
                          if (self.onPresentActionHandler) {
                              self.onPresentActionHandler(fromView, toView);
                          }
                      }
                      completion:^(BOOL flag) {
                          @yh_strongify(self)
                          if (self.didPresentActionHandler) {
                              self.didPresentActionHandler(fromView, toView);
                          }
                          completion(flag);
                      }];
}

- (void)_dismissWithTransition:(id <UIViewControllerContextTransitioning>)transitionContext
                     container:(UIView *)container
                          from:(UIView *)fromView
                            to:(UIView *)toView
                    completion:(void (^)(BOOL flag))completion {
    [container addSubview:fromView];
    if (self.willDismissActionHandler) {
        self.willDismissActionHandler(fromView, toView);
    }
    @yh_weakify(self)
    [self _animateWithTransition:transitionContext
                      animations:^{
                          @yh_strongify(self)
                          if (self.onDismissActionHandler) {
                              self.onDismissActionHandler(fromView, toView);
                          }
                      }
                      completion:^(BOOL flag) {
                          @yh_strongify(self)
                          if (self.didDismissActionHandler) {
                              self.didDismissActionHandler(fromView, toView);
                          }
                          completion(flag);
                      }];

}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.isPresenting) {
        return 0.35f;
    }
    return 0.15f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *container = [transitionContext containerView];
    if (!container) {
        return;
    }
    UIViewController *fromController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    if (!fromController) {
        return;
    }
    UIViewController *toController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if (!toController) {
        return;
    }
    
    if (self.isPresenting) {
        [self _presentWithTransition:transitionContext
                           container:container
                                from:fromController.view
                                  to:toController.view
                          completion:^(BOOL flag) {
                              [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                          }];
    } else {
        [self _dismissWithTransition:transitionContext
                           container:container
                                from:fromController.view
                                  to:toController.view
                          completion:^(BOOL flag) {
                              [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                          }];
    }
}

#pragma mark - Accessor



@end
