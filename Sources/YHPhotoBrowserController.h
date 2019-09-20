//
//  YHPhotoBrowserController.h
//  YHPhotoBrowser
//
//  Created by ruaho on 2019/7/11.
//  Copyright © 2019 ruaho. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YHPhotoBrowserController;

#pragma mark - YHPhotoBrowserControllerDataSource

@protocol YHPhotoBrowserControllerDataSource <NSObject>

/// Return the pages count
- (NSInteger)numberOfPagesInViewController:(nonnull YHPhotoBrowserController *)viewController;

@optional

/// Return the image, implement one of this or follow method
- (nonnull UIImage *)viewController:(nonnull YHPhotoBrowserController *)viewController imageForPageAtIndex:(NSInteger)index;

/// Configure the imageView's image, implement one of this or upper method
- (void)viewController:(nonnull YHPhotoBrowserController *)viewController presentImageView:(nonnull UIImageView *)imageView forPageAtIndex:(NSInteger)index __attribute__((deprecated("use `viewController:presentImageView:forPageAtIndex:progressHandler` instead.")));
/// Configure the imageView's image, implement one of this or upper method
- (void)viewController:(nonnull YHPhotoBrowserController *)viewController presentImageView:(nonnull UIImageView *)imageView forPageAtIndex:(NSInteger)index progressHandler:(nullable void (^)(NSInteger receivedSize, NSInteger expectedSize,NSURL * _Nullable targetURL))progressHandler;

/// Use for dismiss animation, will be an UIImageView in general.
- (nullable UIView *)thumbViewForPageAtIndex:(NSInteger)index;

@end

#pragma mark - YHPhotoBrowserControllerDelegate

@protocol YHPhotoBrowserControllerDelegate <NSObject>

@optional

/// Action call back for single tap, presentedImage will be nil untill loaded image
- (void)viewController:(nonnull YHPhotoBrowserController *)viewController didSingleTapedPageAtIndex:(NSInteger)index presentedImage:(nullable UIImage *)presentedImage;

/// Action call back for long press, presentedImage will be nil untill loaded image
- (void)viewController:(nonnull YHPhotoBrowserController *)viewController didLongPressedPageAtIndex:(NSInteger)index presentedImage:(nullable UIImage *)presentedImage;

@end


#pragma mark - YHPhotoBrowserController

@interface YHPhotoBrowserController : UIPageViewController

@property (nonatomic, weak, nullable) id<YHPhotoBrowserControllerDataSource> yh_dataSource;
@property (nonatomic, weak, nullable) id<YHPhotoBrowserControllerDelegate> yh_delegate;

@property (nonatomic, assign) NSInteger startPage;
@property (nonatomic, assign) NSInteger yh_startPage;

@property (nonatomic, assign, readonly) NSInteger numberOfPages;
@property (nonatomic, assign, readonly) NSInteger currentPage;
/// Will show first page.
- (void)reload;
/// Will show the specified page.
- (void)reloadWithCurrentPage:(NSInteger)index;
/// Default value is `YES`
@property (nonatomic, assign) BOOL blurBackground;
/// Default value is `YES`
@property (nonatomic, assign) BOOL hideThumb;
/// Custom exit method, if did not provide, use dismiss.
@property (nonatomic, copy, nullable) void (^exit)(YHPhotoBrowserController * _Nonnull sender);
@end
