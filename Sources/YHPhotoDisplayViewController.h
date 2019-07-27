//
//  YHImageScrollerViewController.h
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

#import <UIKit/UIKit.h>

@class YHPhotoDisplayView;
typedef void(^YHImageDownloadProgressHandler)(NSInteger receivedSize, NSInteger expectedSize,NSURL * _Nullable targetURL);

@interface YHPhotoDisplayViewController : UIViewController

@property (nonatomic, assign) NSInteger page;

/// Return the image for current imageView
@property (nonatomic, copy) UIImage *(^fetchImageHandler)(void);
/// Configure image for current imageView
@property (nonatomic, copy) void (^configureImageViewHandler)(UIImageView *imageView);

/// Configure image for current imageView with progress
@property (nonatomic, copy) void (^configureImageViewWithDownloadProgressHandler)(UIImageView *imageView, YHImageDownloadProgressHandler handler);

@property (nonatomic, strong, readonly) YHPhotoDisplayView *imageScrollView;

- (void)reloadData;

@end
