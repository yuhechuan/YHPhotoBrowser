//
//  YHRemoteViewController.m
//  YHPhotoBrowser
//
//  Created by ruaho on 2019/7/26.
//  Copyright © 2019 ruaho. All rights reserved.
//

#import "YHRemoteViewController.h"
#import "YHPhotoBrowserController.h"
#import "YHSquareView.h"

@interface YHRemoteViewController ()<YHPhotoBrowserControllerDelegate, YHPhotoBrowserControllerDataSource>

@property (nonatomic, strong) NSMutableArray *imageURLs;
@property (nonatomic, strong) UIImageView    *imageView;
@property (nonatomic, strong) YHSquareView   *squareView;

@end

@implementation YHRemoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
}

- (void)setUp {
    self.title = @"远端图片展示";
    self.view.backgroundColor = [UIColor colorWithRed:230 / 225.0 green:103 / 255.0 blue:103 / 255.0 alpha:1];
    self.tableView.tableFooterView = [UIView new];
    
    NSString *preTitle = @"Image-";
    for (int i = 0;i < 8 ; i ++) {
        [self.imageURLs addObject:[NSString stringWithFormat:@"%@%d",preTitle,i]];
    }
    _squareView= [[YHSquareView alloc]initWithItems:[self.imageURLs copy]];
    _squareView.frame = CGRectMake(0, 150, self.view.bounds.size.width, self.view.bounds.size.height);
    
    __weak typeof(self) ws = self;
    _squareView.callBack = ^(NSInteger index) {
        [ws show:index];
    };
    [self.view addSubview:_squareView];
}

- (void)show:(NSInteger)index {
    YHPhotoBrowserController *pbViewController = [YHPhotoBrowserController new];
    pbViewController.yh_dataSource = self;
    pbViewController.yh_delegate = self;
    pbViewController.yh_startPage = index;
    pbViewController.blurBackground = YES;
    [self presentViewController:pbViewController animated:YES completion:nil];
}

#pragma mark - YHPhotoBrowserControllerDataSource

- (NSInteger)numberOfPagesInViewController:(YHPhotoBrowserController *)viewController {
    return self.imageURLs.count;
}

- (void)viewController:(YHPhotoBrowserController *)viewController
      presentImageView:(UIImageView *)imageView
        forPageAtIndex:(NSInteger)index
       progressHandler:(void (^)(NSInteger, NSInteger))progressHandler {
    
    NSString *url = self.imageURLs[index];
    UIImage *placeholder = [UIImage imageNamed:url];
    imageView.image = placeholder;
}

#pragma mark - YHPhotoBrowserControllerDelegate

- (void)viewController:(YHPhotoBrowserController *)viewController didSingleTapedPageAtIndex:(NSInteger)index presentedImage:(UIImage *)presentedImage {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewController:(YHPhotoBrowserController *)viewController didLongPressedPageAtIndex:(NSInteger)index presentedImage:(UIImage *)presentedImage {
    NSLog(@"didLongPressedPageAtIndex: %@", @(index));
}

- (nullable UIView *)thumbViewForPageAtIndex:(NSInteger)index {
    return _imageView;
}

- (NSMutableArray *)imageURLs {
    if (!_imageURLs) {
        _imageURLs = [NSMutableArray array];
    }
    return _imageURLs;
}

@end
