//
//  YHPhotoDisplayView.m
//  YHPhotoBrowser
//
//  Created by ruaho on 2019/7/11.
//  Copyright © 2019 ruaho. All rights reserved.
//

#import "YHPhotoDisplayView.h"
#import "YHPanGestureRecognizer.h"
#import "YHDragGestureHandler.h"

#define system_version ([UIDevice currentDevice].systemVersion.doubleValue)
#define observe_keypath_image @"image"

@interface YHPhotoDisplayView ()

@property (nonatomic, strong) UIImageView            *imageView;
@property (nonatomic, weak) id <NSObject>            notification;
@property (nonatomic, assign) BOOL                   dismissing;
@property (nonatomic, assign) CGSize                 imageRealSize;
@property (nonatomic, strong) YHDragGestureHandler   *dragGestureHandler;

@end

@implementation YHPhotoDisplayView

- (void)dealloc {
    [self _removeObserver];
    [self _removeNotificationIfNeeded];
}

#pragma mark - respondsToSelector

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }

#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
#endif
    
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor clearColor];
    self.multipleTouchEnabled = YES;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.alwaysBounceVertical = NO;
    self.minimumZoomScale = 1.0f;
    self.maximumZoomScale = 1.0f;
    self.delegate = self;
    
    [self addSubview:self.imageView];
    [self _addObserver];
    [self _addNotificationIfNeeded];
    [self _addPanGestureRecognizer];

    return self;
}


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self _updateFrame];
    [self _recenterImage];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (!self.window) {
        [self _updateUserInterfaces];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (![keyPath isEqualToString:observe_keypath_image]) {
        return;
    }
    if (![object isEqual:self.imageView]) {
        return;
    }
    if (!self.imageView.image) {
        return;
    }

    [self _updateUserInterfaces];
}

#pragma mark - Internal Methods

- (void)_handleZoomForLocation:(CGPoint)location {
    CGPoint touchPoint = [self.superview convertPoint:location toView:self.imageView];
    if (self.zoomScale > 1) {
        [self setZoomScale:1 animated:YES];
    } else if (self.maximumZoomScale > 1) {
        CGFloat newZoomScale = self.maximumZoomScale;
        CGFloat horizontalSize = CGRectGetWidth(self.bounds) / newZoomScale;
        CGFloat verticalSize = CGRectGetHeight(self.bounds) / newZoomScale;
        [self zoomToRect:CGRectMake(touchPoint.x - horizontalSize / 2.0f, touchPoint.y - verticalSize / 2.0f, horizontalSize, verticalSize) animated:YES];
    }
}

- (void)_scrollToTopAnimated:(BOOL)animated {
    CGPoint offset = self.contentOffset;
    offset.y = -self.contentInset.top;
    [self setContentOffset:offset animated:animated];
}

#pragma mark - Private methods

- (void)_addObserver {
    [self.imageView addObserver:self forKeyPath:observe_keypath_image options:NSKeyValueObservingOptionNew context:nil];
}

- (void)_removeObserver {
    [self.imageView removeObserver:self forKeyPath:observe_keypath_image];
}

- (void)_addNotificationIfNeeded {
    if (system_version >= 8.0) {
        return;
    }
    
    @yh_weakify(self)
    self.notification = [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        @yh_strongify(self)
        [self _updateFrame];
        [self _recenterImage];
    }];
}

- (void)_addPanGestureRecognizer {
    self.dragGestureHandler = [[YHDragGestureHandler alloc]initWithGestureView:self];
    __weak typeof(self) weakSelf = self;
    self.dragGestureHandler.completeBlock = ^(BOOL finish, CGFloat velocity) {
        if (finish && weakSelf.didEndDraggingInProperpositionHandler) {
            weakSelf.bounces = NO;
            weakSelf.didEndDraggingInProperpositionHandler(velocity);
        }
    };
    self.dragGestureHandler.alphaValueChangeBlock = ^(float alphaValue) {
        if (weakSelf.contentOffSetVerticalPercentHandler) {
            weakSelf.contentOffSetVerticalPercentHandler(alphaValue);
        }
    };
}


- (void)_removeNotificationIfNeeded {
    if (system_version >= 8.0) {
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self.notification];
}

- (void)_updateUserInterfaces {
    [self setZoomScale:1.0f animated:YES];
    [self _updateFrame];
    [self _recenterImage];
    [self _setMaximumZoomScale];
    self.alwaysBounceVertical = YES;
}

- (void)_updateFrame {
    self.frame = [UIScreen mainScreen].bounds;
    
    UIImage *image = self.imageView.image;
    if (!image) {
        return;
    }
    
    CGSize properSize = [self _properPresentSizeForImage:image];
    self.imageRealSize = properSize;
    self.imageView.frame = CGRectMake(0, 0, properSize.width, properSize.height);
    self.contentSize = properSize;
}

- (CGSize)_properPresentSizeForImage:(UIImage *)image {
    CGFloat ratio = CGRectGetWidth(self.bounds) / image.size.width;
    return CGSizeMake(CGRectGetWidth(self.bounds), ceil(ratio * image.size.height));
}

- (void)_recenterImage {
    CGFloat contentWidth = self.contentSize.width;
    CGFloat horizontalDiff = CGRectGetWidth(self.bounds) - contentWidth;
    CGFloat horizontalAddition = horizontalDiff > 0.f ? horizontalDiff : 0.f;
    
    CGFloat contentHeight = self.contentSize.height;
    CGFloat verticalDiff = CGRectGetHeight(self.bounds) - contentHeight;
    CGFloat verticalAdditon = verticalDiff > 0 ? verticalDiff : 0.f;

    self.imageView.center = CGPointMake((contentWidth + horizontalAddition) / 2.0f, (contentHeight + verticalAdditon) / 2.0f);
}

- (void)_setMaximumZoomScale {
    CGSize imageSize = self.imageView.image.size;
    CGFloat selfWidth = CGRectGetWidth(self.bounds);
    CGFloat selfHeight = CGRectGetHeight(self.bounds);
    if (imageSize.width <= selfWidth && imageSize.height <= selfHeight) {
        self.maximumZoomScale = 1.0f;
    } else {
        self.maximumZoomScale = MAX(MIN(imageSize.width / selfWidth, imageSize.height / selfHeight), 3.0f);
    }
}


/// +/- Sale.
- (CGFloat)_contentOffSetZoomSale {
    CGFloat offsetY = self.contentOffset.y;
    CGFloat offsetYU = fabs(offsetY);
    CGFloat imageHeight = self.imageView.frame.size.height;
    CGFloat d = (imageHeight - offsetYU) / imageHeight *1.0;
    return d;
}

/// 恢复原样
- (void)_recoverTransform {
    self.transform = CGAffineTransformIdentity;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self _recenterImage];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.dismissing) {
        return;
    }
    if (scrollView.zoomScale < 1) {
        [scrollView setZoomScale:1.0f animated:YES];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}


#pragma mark - Accessor

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.userInteractionEnabled = YES;
    }
    return _imageView;
}

@end
