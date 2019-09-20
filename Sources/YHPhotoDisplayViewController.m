//
//  YHPhotoDisplayViewController.m
//  PhotoBrowser
//
//  Created by ruaho on 2019/7/24.
//  Copyright © 2019 ruaho. All rights reserved.
//

#import "YHPhotoDisplayViewController.h"
#import "YHPhotoDisplayView.h"

@interface YHPhotoDisplayViewController ()
@property (nonatomic, strong, readwrite) YHPhotoDisplayView *imageScrollView;
@property (nonatomic, weak, readwrite) UIImageView *imageView;
@property (nonatomic, strong, readwrite) CAShapeLayer *progressLayer;
@property (nonatomic, assign) BOOL dismissing;
@end

@implementation YHPhotoDisplayViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.imageScrollView];
    [self.view.layer addSublayer:self.progressLayer];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGPoint center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2.0, CGRectGetHeight(self.view.bounds) / 2.0);
    CGRect frame = self.progressLayer.frame;
    frame.origin.x = center.x - CGRectGetWidth(frame) / 2.0f;
    frame.origin.y = center.y - CGRectGetHeight(frame) / 2.0f;
    self.progressLayer.frame = frame;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 干掉加载动画。
    self.progressLayer.hidden = YES;
    self.dismissing = YES;
}

- (void)reloadData {
    [self _prepareForReuse];
    [self _loadData];
}

#pragma mark - Private methods

- (void)_prepareForReuse {
    self.imageView.image = nil;
    self.progressLayer.hidden = YES;
    self.progressLayer.strokeStart = 0;
    self.progressLayer.strokeEnd = 0;
    self.dismissing = NO;
}

- (void)_loadData {
    if (self.fetchImageHandler) {
        self.imageView.image = self.fetchImageHandler();
    } else if (self.configureImageViewWithDownloadProgressHandler) {
        @yh_weakify(self)
        self.configureImageViewWithDownloadProgressHandler(self.imageView, ^(NSInteger receivedSize, NSInteger expectedSize, NSURL *targetURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                @yh_strongify(self)
                if (self.dismissing || !self.view.window) {
                    self.progressLayer.hidden = YES;
                    return;
                }
                CGFloat progress = (receivedSize * 1.0f) / (expectedSize * 1.0f);
                if (0.0f >= progress || progress >= 1.0f) {
                    self.progressLayer.hidden = YES;
                    return;
                }
                self.progressLayer.hidden = NO;
                self.progressLayer.strokeEnd = progress;
            });
        });
    } else if (self.configureImageViewHandler) {
        self.configureImageViewHandler(self.imageView);
    }
}

#pragma mark - Accessor

- (YHPhotoDisplayView *)imageScrollView {
    if (!_imageScrollView) {
        _imageScrollView = [YHPhotoDisplayView new];
    }
    return _imageScrollView;
}

- (UIImageView *)imageView {
    return self.imageScrollView.imageView;
}

- (CAShapeLayer *)progressLayer {
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.frame = CGRectMake(0, 0, 40, 40);
        _progressLayer.cornerRadius = MIN(CGRectGetWidth(_progressLayer.bounds) / 2.0f, CGRectGetHeight(_progressLayer.bounds) / 2.0f);
        _progressLayer.lineWidth = 4;
        _progressLayer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
        _progressLayer.fillColor = [UIColor clearColor].CGColor;
        _progressLayer.strokeColor = [UIColor whiteColor].CGColor;
        _progressLayer.lineCap = kCALineCapRound;
        _progressLayer.strokeStart = 0;
        _progressLayer.strokeEnd = 0;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(_progressLayer.bounds, 7, 7) cornerRadius:_progressLayer.cornerRadius - 7];
        _progressLayer.path = path.CGPath;
        _progressLayer.hidden = YES;
    }
    return _progressLayer;
}

@end

