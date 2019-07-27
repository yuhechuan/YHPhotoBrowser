//
//  YHLocalViewController.m
//  YHPhotoBrowser
//
//  Created by ruaho on 2019/7/26.
//  Copyright © 2019 ruaho. All rights reserved.
//

#import "YHLocalViewController.h"
#import "YHPhotoBrowserController.h"
#import "YHSquareView.h"

@interface YHLocalViewController ()<YHPhotoBrowserControllerDelegate, YHPhotoBrowserControllerDataSource>

@property (nonatomic, strong) NSMutableArray *imageURLs;
@property (nonatomic, strong) UIImageView    *imageView;
@property (nonatomic, strong) YHSquareView   *squareView;


@end

@implementation YHLocalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUp];
}

- (void)setUp {
    self.title = @"本地图片展示";
    self.view.backgroundColor = [UIColor colorWithRed:70 / 225.0 green:187 / 255.0 blue:38 / 255.0 alpha:1];
    self.tableView.tableFooterView = [UIView new];
    NSString *preTitle = @"plbdx_";
    for (int i = 0;i < 7 ; i ++) {
        [self.imageURLs addObject:[NSString stringWithFormat:@"%@%d",preTitle,i]];
    }
    _squareView= [[YHSquareView alloc]initWithItems:[self.imageURLs copy]];
    _squareView.frame = CGRectMake(0, 100, self.view.bounds.size.width, self.view.bounds.size.height);
    
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

- (void)viewController:(YHPhotoBrowserController *)viewController presentImageView:(UIImageView *)imageView forPageAtIndex:(NSInteger)index progressHandler:(void (^)(NSInteger, NSInteger, NSURL * _Nullable))progressHandler {
    imageView.image = [UIImage imageNamed:self.imageURLs[index]];
}

#pragma mark - YHPhotoBrowserControllerDelegate

- (void)viewController:(YHPhotoBrowserController *)viewController didSingleTapedPageAtIndex:(NSInteger)index presentedImage:(UIImage *)presentedImage {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewController:(YHPhotoBrowserController *)viewController didLongPressedPageAtIndex:(NSInteger)index presentedImage:(UIImage *)presentedImage {
    NSLog(@"didLongPressedPageAtIndex: %@", @(index));
}

- (nullable UIView *)thumbViewForPageAtIndex:(NSInteger)index {
    return _squareView.imageViews[index];
}

- (NSMutableArray *)imageURLs {
    if (!_imageURLs) {
        _imageURLs = [NSMutableArray array];
    }
    return _imageURLs;
}

@end
