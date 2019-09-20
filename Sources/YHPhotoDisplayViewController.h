//
//  YHImageScrollerViewController.h
//  YHPhotoBrowser
//
//  Created by ruaho on 2019/7/11.
//  Copyright © 2019 ruaho. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YHPhotoDisplayView;
typedef void(^YHImageDownloadProgressHandler)(NSInteger receivedSize, NSInteger expectedSize,NSURL * _Nullable targetURL);

@interface YHPhotoDisplayViewController : UIViewController

@property (nonatomic, assign) NSInteger page;

/// Return the image for current imageView
@property (nonatomic, copy) UIImage *_Nullable(^ _Nullable fetchImageHandler)(void);
/// Configure image for current imageView
@property (nonatomic, copy) void (^ _Nullable configureImageViewHandler)(UIImageView * _Nullable imageView);

/// Configure image for current imageView with progress
@property (nonatomic, copy) void (^ _Nullable configureImageViewWithDownloadProgressHandler)(UIImageView * _Nullable imageView, YHImageDownloadProgressHandler _Nullable handler);

@property (nonatomic, strong, readonly) YHPhotoDisplayView * _Nullable imageScrollView;

- (void)reloadData;

@end
