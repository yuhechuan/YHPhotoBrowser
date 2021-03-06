//
//  YHPhotoBrowserController.m
//  YHPhotoBrowser
//
//  Created by ruaho on 2019/7/11.
//  Copyright © 2019 ruaho. All rights reserved.
//

#import "YHPhotoBrowserController.h"
#import "YHPhotoDisplayViewController.h"
#import "YHPhotoDisplayView.h"
#import "YHPresentAnimatedTransitioningController.h"

static const NSUInteger reusable_page_count = 3;

@interface YHPhotoBrowserController () <
    UIPageViewControllerDataSource,
    UIPageViewControllerDelegate,
    UIViewControllerTransitioningDelegate
>

@property (nonatomic, strong) NSArray<YHPhotoDisplayViewController *> *reusableImageScrollerViewControllers;
@property (nonatomic, assign, readwrite) NSInteger numberOfPages;
@property (nonatomic, assign, readwrite) NSInteger currentPage;

/// Images count >9, use this for indicate
@property (nonatomic, strong) UILabel *indicatorLabel;
/// Images count <=9, use this for indicate
@property (nonatomic, strong) UIPageControl *indicatorPageControl;
/// Hold the indicator control
@property (nonatomic, weak) UIView *indicator;
/// Blur background view
@property (nonatomic, strong) UIView *blurBackgroundView;

/// Gestures
@property (nonatomic, strong) UITapGestureRecognizer *singleTapGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;

@property (nonatomic, strong) YHPresentAnimatedTransitioningController *transitioningController;
@property (nonatomic, assign) CGFloat velocity;

@property (nonatomic, assign) CGRect contentsRect;
@property (nonatomic, assign) CGRect originFrame;
@property (nonatomic, weak) UIView *lastThumbView;
@property (nonatomic, assign) BOOL didEndDragging; // 滑动退出

@end

@implementation YHPhotoBrowserController


#pragma mark - respondsToSelector

- (instancetype)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style
                  navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation
                                options:(NSDictionary *)options {
    NSMutableDictionary *dict = [(options ?: @{}) mutableCopy];
    [dict setObject:@(20) forKey:UIPageViewControllerOptionInterPageSpacingKey];
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                    navigationOrientation:navigationOrientation
                                  options:dict];
    if (!self) {
        return nil;
    }
    
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.transitioningDelegate = self;
    _contentsRect = CGRectMake(0, 0, 1, 1);
    _blurBackground = NO;
    _hideThumb = YES;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // gesture
    [self _addGestureRecognizer];
    
    // Set numberOfPages
    [self _setNumberOfPages];
    // Set visible view controllers
    [self _setCurrentPresentPageAnimated: NO];
    // Set indicatorLabel
    [self _addIndicator];
    // Blur background
    [self _addBlurBackgroundView];
    
    self.dataSource = self;
    self.delegate = self;
    
    [self _setupTransitioningController];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self _updateIndicator];
    [self _updateBlurBackgroundView];
}

#pragma mark - Public method

-(void)setYh_startPage:(NSInteger)yh_startPage {
    _startPage = yh_startPage;
    _yh_startPage = yh_startPage;
    _currentPage = yh_startPage;
}

- (void)setStartPage:(NSInteger)startPage {
    self.yh_startPage = startPage;
}

- (void)reload {
    [self reloadWithCurrentPage:0];
}

- (void)reloadWithCurrentPage:(NSInteger)index {
    self.yh_startPage = index;
    [self _setNumberOfPages];
    NSAssert(index < _numberOfPages, @"index(%@) beyond boundary.", @(index));
    [self _setCurrentPresentPageAnimated: YES];
    [self _updateIndicator];
    [self _updateBlurBackgroundView];
    [self _hideThumbView];
}

#pragma mark - Private methods

- (void)_setNumberOfPages {
    if ([self.yh_dataSource conformsToProtocol:@protocol(YHPhotoBrowserControllerDataSource)] &&
        [self.yh_dataSource respondsToSelector:@selector(numberOfPagesInViewController:)]) {
        self.numberOfPages = [self.yh_dataSource numberOfPagesInViewController:self];
    }
}

- (void)_setCurrentPresentPageAnimated:(BOOL)animated {
    self.currentPage = 0 < self.currentPage && self.currentPage < self.numberOfPages ? self.currentPage : 0;
    YHPhotoDisplayViewController *firstImageScrollerViewController = [self _imageScrollerViewControllerForPage:self.currentPage];
    [self setViewControllers:@[firstImageScrollerViewController] direction:UIPageViewControllerNavigationDirectionForward animated:animated completion:nil];
    [firstImageScrollerViewController reloadData];
}

- (void)_addIndicator {
    if (self.numberOfPages == 1) {
        return;
    }
    if (self.numberOfPages <= 9) {
        [self.view addSubview:self.indicatorPageControl];
        self.indicator = self.indicatorPageControl;
    } else {
        [self.view addSubview:self.indicatorLabel];
        self.indicator = self.indicatorLabel;
    }
    self.indicator.layer.zPosition = 1024;
}

- (void)_updateIndicator {
    if (!self.indicator) {
        return;
    }
    if (self.numberOfPages <= 9) {
        self.indicatorPageControl.numberOfPages = self.numberOfPages;
        self.indicatorPageControl.currentPage = self.currentPage;
        [self.indicatorPageControl sizeToFit];
        self.indicatorPageControl.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2.0f,
                                                       CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.indicatorPageControl.bounds) / 2.0f);
    } else {
        NSString *indicatorText = [NSString stringWithFormat:@"%@/%@", @(self.currentPage + 1), @(self.numberOfPages)];
        self.indicatorLabel.text = indicatorText;
        [self.indicatorLabel sizeToFit];
        self.indicatorLabel.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2.0f,
                                                 CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.indicatorLabel.bounds));
    }
}

- (void)_addBlurBackgroundView {
    [self.view addSubview:self.blurBackgroundView];
    [self.view sendSubviewToBack:self.blurBackgroundView];
}

- (void)_updateBlurBackgroundView {
    self.blurBackgroundView.frame = self.view.bounds;
}

- (void)_hideStatusBarIfNeeded {
    self.presentingViewController.view.window.windowLevel = UIWindowLevelStatusBar;
}

- (void)_showStatusBarIfNeeded {
    self.presentingViewController.view.window.windowLevel = UIWindowLevelNormal;
}

- (void)_addGestureRecognizer {
    [self.view addGestureRecognizer:self.longPressGestureRecognizer];
    [self.view addGestureRecognizer:self.doubleTapGestureRecognizer];
    [self.view addGestureRecognizer:self.singleTapGestureRecognizer];
    [self.singleTapGestureRecognizer requireGestureRecognizerToFail:self.longPressGestureRecognizer];
    [self.singleTapGestureRecognizer requireGestureRecognizerToFail:self.doubleTapGestureRecognizer];
}

- (YHPhotoDisplayViewController *)_imageScrollerViewControllerForPage:(NSInteger)page {
    if (page > self.numberOfPages - 1 || page < 0) {
        return nil;
    }
    
    YHPhotoDisplayViewController *imageScrollerViewController = self.reusableImageScrollerViewControllers[page % reusable_page_count];
    
    // Set new data
    if (!self.yh_dataSource) {
        [NSException raise:@"Must implement `YHPhotoBrowserControllerDataSource` protocol." format:@""];
    }
    
    @yh_weakify(self)
    if ([self.yh_dataSource conformsToProtocol:@protocol(YHPhotoBrowserControllerDataSource)]) {
        imageScrollerViewController.page = page;
        
        if ([self.yh_dataSource respondsToSelector:@selector(viewController:imageForPageAtIndex:)]) {
            imageScrollerViewController.fetchImageHandler = ^UIImage *(void) {
                @yh_strongify(self)
                if (page < self.numberOfPages) {
                    return [self.yh_dataSource viewController:self imageForPageAtIndex:page];
                }
                return nil;
            };
        } else if ([self.yh_dataSource respondsToSelector:@selector(viewController:presentImageView:forPageAtIndex:progressHandler:)]) {
            imageScrollerViewController.configureImageViewWithDownloadProgressHandler = ^(UIImageView *imageView, YHImageDownloadProgressHandler handler) {
                @yh_strongify(self)
                if (page < self.numberOfPages) {
                    [self.yh_dataSource viewController:self presentImageView:imageView forPageAtIndex:page progressHandler:handler];
                }
            };
        } else if ([self.yh_dataSource respondsToSelector:@selector(viewController:presentImageView:forPageAtIndex:)]) {
            imageScrollerViewController.configureImageViewHandler = ^(UIImageView *imageView) {
                @yh_strongify(self)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                if (page < self.numberOfPages) {
                    [self.yh_dataSource viewController:self presentImageView:imageView forPageAtIndex:page];
                }
#pragma clang diagnostic pop
            };
        }
    }
    return imageScrollerViewController;
}

- (void)_setupTransitioningController {
    @yh_weakify(self)
    self.transitioningController.willPresentActionHandler = ^(UIView *fromView, UIView *toView) {
        @yh_strongify(self)
        [self _willPresent];
    };
    self.transitioningController.onPresentActionHandler = ^(UIView *fromView, UIView *toView) {
        @yh_strongify(self)
        [self _onPresent];
    };
    self.transitioningController.didPresentActionHandler = ^(UIView *fromView, UIView *toView) {
        @yh_strongify(self)
        [self _didPresented];
    };
    self.transitioningController.willDismissActionHandler = ^(UIView *fromView, UIView *toView) {
        @yh_strongify(self)
        [self _willDismiss];
    };
    self.transitioningController.onDismissActionHandler = ^(UIView *fromView, UIView *toView) {
        @yh_strongify(self)
        [self _onDismiss];
    };
    self.transitioningController.didDismissActionHandler = ^(UIView *fromView, UIView *toView) {
        @yh_strongify(self)
        [self _didDismiss];
    };
}

- (void)_willPresent {
    YHPhotoDisplayViewController *currentScrollViewController = self.currentScrollViewController;
    currentScrollViewController.view.alpha = 0;
    self.blurBackgroundView.alpha = 0;
    UIView *thumbView = self.currentThumbView;
    if (!thumbView) {
        return;
    }
    [self _hideThumbView];

    currentScrollViewController.view.alpha = 1;
    YHPhotoDisplayView *imageScrollView = currentScrollViewController.imageScrollView;
    UIImageView *imageView = imageScrollView.imageView;
    imageView.image = self.currentThumbImage;
        // record
    self.originFrame = imageView.frame;
    CGRect frame = [thumbView.superview convertRect:thumbView.frame toView:self.view];
    imageView.frame = frame;
    imageView.contentMode = thumbView.contentMode;
    imageView.clipsToBounds = thumbView.clipsToBounds;
    imageView.backgroundColor = thumbView.backgroundColor;
}

- (void)_onPresent {
    YHPhotoDisplayViewController *currentScrollViewController = self.currentScrollViewController;
    self.blurBackgroundView.alpha = 1;
    [self _hideStatusBarIfNeeded];
    
    if (!self.currentThumbView) {
        currentScrollViewController.view.alpha = 1;
        return;
    }
    
    YHPhotoDisplayView *imageScrollView = currentScrollViewController.imageScrollView;
    UIImageView *imageView = imageScrollView.imageView;
    CGRect originFrame = [imageView.superview convertRect:imageView.frame toView:self.view];
    
    if (CGRectEqualToRect(originFrame, CGRectZero)) {
        currentScrollViewController.view.alpha = 1;
        return;
    }

    imageView.frame = self.originFrame;
}

- (void)_didPresented {
    self.currentScrollViewController.view.alpha = 1;
    self.currentScrollViewController.imageScrollView.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.currentScrollViewController reloadData];
    [self _hideIndicator];
}

/// pic  :    正方形 | 长方形(w>h) | 长方形(h>w)
/// view :    正方形 | 长方形(w>h) | 长方形(h>w)
/// 3 * 3 = 9 种情况
- (void)_willDismiss {
    YHPhotoDisplayViewController *currentScrollViewController = self.currentScrollViewController;
    YHPhotoDisplayView *imageScrollView = currentScrollViewController.imageScrollView;
    // 还原 zoom.
    if (imageScrollView.zoomScale != 1 && !self.didEndDragging) {
        [imageScrollView setZoomScale:1 animated:NO];
    }
    
    // 停止播放动画
    NSArray<UIImage *> *images = imageScrollView.imageView.image.images;
    if (images && images.count > 1) {
        UIImage *newImage = images.firstObject;
        imageScrollView.imageView.image = nil;
        imageScrollView.imageView.image = newImage;
    }
    
    if (imageScrollView.contentSize.height > imageScrollView.frame.size.height && imageScrollView.contentOffset.y > 0) {
        [imageScrollView _scrollToTopAnimated:NO];
    }
}

- (void)_onDismiss {
    
    [self _showStatusBarIfNeeded];
    self.blurBackgroundView.alpha = 0;
    
    YHPhotoDisplayViewController *currentScrollViewController = self.currentScrollViewController;
    YHPhotoDisplayView *imageScrollView = currentScrollViewController.imageScrollView;
    UIImageView *imageView = imageScrollView.imageView;
    UIImage *currentImage = imageView.image;
    // 没有图片不处理
    if (!currentImage) {
        return;
    }
    // 动画展示
    UIView *thumbView = self.currentThumbView;
    CGRect destFrame = CGRectZero;
    if (thumbView) {
        destFrame = [thumbView.superview convertRect:thumbView.frame toView:self.view];
        imageView.frame = destFrame;
    } else {
        imageScrollView.alpha = 0;
        CGPoint center = self.view.window.center;
        destFrame = CGRectMake(center.x, center.y, 0, 0);
        imageView.frame = destFrame;
    }
}

- (void)_didDismiss {
    self.currentThumbView.hidden = NO;
}

- (void)_hideIndicator {
    if (!self.indicator || 0 == self.indicator.alpha) {
        return;
    }
    [UIView animateWithDuration:0.25 delay:0.5 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
        self.indicator.alpha = 0;
    } completion:^(BOOL finished) {
    }];
}

- (void)_showIndicator {
    if (!self.indicator || 1 == self.indicator.alpha) {
        return;
    }
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
        self.indicator.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

- (void)_hideThumbView {
    if (!_hideThumb) {
        return;
    }
    self.lastThumbView.hidden = NO;
    UIView *currentThumbView = self.currentThumbView;
    currentThumbView.hidden = YES;
    self.lastThumbView = currentThumbView;
}

#pragma mark - Actions

- (void)_handleSingleTapAction:(UITapGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateEnded) {
        return;
    }
    if (!self.yh_delegate) {
        return;
    }
    if ([self.yh_delegate conformsToProtocol:@protocol(YHPhotoBrowserControllerDelegate)]) {
        if ([self.yh_delegate respondsToSelector:@selector(viewController:didSingleTapedPageAtIndex:presentedImage:)]) {
            [self.yh_delegate viewController:self didSingleTapedPageAtIndex:self.currentPage presentedImage:self.currentScrollViewController.imageScrollView.imageView.image];
        }
    }
}

- (void)_handleDoubleTapAction:(UITapGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateEnded) {
        return;
    }
    CGPoint location = [sender locationInView:self.view];
    YHPhotoDisplayView *imageScrollView = self.currentScrollViewController.imageScrollView;
    [imageScrollView _handleZoomForLocation:location];
}

- (void)_handleLongPressAction:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateEnded) {
        return;
    }
    if (!self.yh_delegate) {
        return;
    }
    if ([self.yh_delegate conformsToProtocol:@protocol(YHPhotoBrowserControllerDelegate)]) {
        if ([self.yh_delegate respondsToSelector:@selector(viewController:didLongPressedPageAtIndex:presentedImage:)]) {
            [self.yh_delegate viewController:self didLongPressedPageAtIndex:self.currentPage presentedImage:self.currentScrollViewController.imageScrollView.imageView.image];
        }
    }
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(YHPhotoDisplayViewController *)viewController {
    return [self _imageScrollerViewControllerForPage:viewController.page - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(YHPhotoDisplayViewController *)viewController {
    return [self _imageScrollerViewControllerForPage:viewController.page + 1];
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    [self _showIndicator];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    YHPhotoDisplayViewController *imageScrollerViewController = pageViewController.viewControllers.firstObject;
    self.currentPage = imageScrollerViewController.page;
    [self _updateIndicator];
    [self _hideIndicator];
    [self _hideThumbView];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented  presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [self.transitioningController prepareForPresent];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [self.transitioningController prepareForDismiss];
}

#pragma mark - Accessor

- (NSArray<YHPhotoDisplayViewController *> *)reusableImageScrollerViewControllers {
    if (!_reusableImageScrollerViewControllers) {
        NSMutableArray *controllers = [[NSMutableArray alloc] initWithCapacity:reusable_page_count];
        for (NSInteger index = 0; index < reusable_page_count; index++) {
            YHPhotoDisplayViewController *imageScrollerViewController = [YHPhotoDisplayViewController new];
            imageScrollerViewController.page = index;
             @yh_weakify(self)
            imageScrollerViewController.imageScrollView.contentOffSetVerticalPercentHandler = ^(CGFloat percent) {
                @yh_strongify(self)
                
                if (self.blurBackground && percent < 0.5) {
                    percent = 0.5;
                }
                self.blurBackgroundView.alpha = percent;
            };
            __weak typeof(imageScrollerViewController) weakScrollerView = imageScrollerViewController;
            imageScrollerViewController.imageScrollView.didEndDraggingInProperpositionHandler = ^(CGFloat velocity){
                @yh_strongify(self)
                self.velocity = velocity;
                self.didEndDragging = YES;
                [weakScrollerView.imageScrollView _recoverTransform]; // 恢复原来位置
                if (self.exit) {
                    self.exit(self);
                } else {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            };
            [controllers addObject:imageScrollerViewController];
        }
        _reusableImageScrollerViewControllers = [[NSArray alloc] initWithArray:controllers];
    }
    return _reusableImageScrollerViewControllers;
}

- (UILabel *)indicatorLabel {
    if (!_indicatorLabel) {
        _indicatorLabel = [UILabel new];
        _indicatorLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        _indicatorLabel.textAlignment = NSTextAlignmentCenter;
        _indicatorLabel.textColor = [UIColor whiteColor];
    }
    return _indicatorLabel;
}

- (UIPageControl *)indicatorPageControl {
    if (!_indicatorPageControl) {
        _indicatorPageControl = [UIPageControl new];
        _indicatorPageControl.numberOfPages = self.numberOfPages;
        _indicatorPageControl.currentPage = self.currentPage;
    }
    return _indicatorPageControl;
}

- (UIView *)blurBackgroundView {
    if (self.blurBackground) {
        if (!_blurBackgroundView) {
            _blurBackgroundView = [[UIToolbar alloc] initWithFrame:self.view.bounds];
            ((UIToolbar *)_blurBackgroundView).barStyle = UIBarStyleBlack;
            ((UIToolbar *)_blurBackgroundView).translucent = YES;
            _blurBackgroundView.clipsToBounds = YES;
            _blurBackgroundView.multipleTouchEnabled = NO;
            _blurBackgroundView.userInteractionEnabled = NO;
        }
    } else {
        if (!_blurBackgroundView) {
            _blurBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
            _blurBackgroundView.backgroundColor = [UIColor blackColor];
            _blurBackgroundView.clipsToBounds = YES;
            _blurBackgroundView.multipleTouchEnabled = NO;
            _blurBackgroundView.userInteractionEnabled = NO;
        }
    }
    return _blurBackgroundView;
}

- (UITapGestureRecognizer *)singleTapGestureRecognizer {
    if (!_singleTapGestureRecognizer) {
        _singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleSingleTapAction:)];
    }
    return _singleTapGestureRecognizer;
}

- (UITapGestureRecognizer *)doubleTapGestureRecognizer {
    if (!_doubleTapGestureRecognizer) {
        _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleDoubleTapAction:)];
        _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    }
    return _doubleTapGestureRecognizer;
}

- (UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (!_longPressGestureRecognizer) {
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handleLongPressAction:)];
    }
    return _longPressGestureRecognizer;
}

- (YHPhotoDisplayViewController *)currentScrollViewController {
    return self.reusableImageScrollerViewControllers[self.currentPage % reusable_page_count];
}

- (UIView *)currentThumbView {
    if (!self.yh_dataSource) {
        return nil;
    }
    if (![self.yh_dataSource conformsToProtocol:@protocol(YHPhotoBrowserControllerDataSource)]) {
        return nil;
    }
    if (![self.yh_dataSource respondsToSelector:@selector(thumbViewForPageAtIndex:)]) {
        return  nil;
    }
    return [self.yh_dataSource thumbViewForPageAtIndex:self.currentPage];
}

- (UIImage *)currentThumbImage {
    UIView *currentThumbView = self.currentThumbView;
    if (!currentThumbView) {
        return nil;
    }
    if ([currentThumbView isKindOfClass:[UIImageView class]]) {
        return ((UIImageView *)self.currentThumbView).image;
    }
    if (currentThumbView.layer.contents) {
        return [[UIImage alloc] initWithCGImage:(__bridge CGImageRef _Nonnull)(currentThumbView.layer.contents)];
    }
    return nil;
}

- (BOOL)thumbClippedToTop {
    UIView *currentThumbView = self.currentThumbView;
    if (!currentThumbView) {
        return NO;
    }
    return currentThumbView.layer.contentsRect.size.height < 1;
}

- (BOOL)dismissByClick {
    if (self.didEndDragging) {
        return NO;
    }
    
    if (0 != self.velocity) {
        return NO;
    }
    return YES;
}

- (BOOL)isPullup {
    return self.didEndDragging;
}

- (YHPresentAnimatedTransitioningController *)transitioningController {
    if (!_transitioningController) {
        _transitioningController = [YHPresentAnimatedTransitioningController new];
    }
    return _transitioningController;
}

@end
