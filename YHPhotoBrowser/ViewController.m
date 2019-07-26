//
//  ViewController.m
//  YHPhotoBrowser
//
//  Created by ruaho on 2019/7/11.
//  Copyright © 2019 ruaho. All rights reserved.
//

#import "ViewController.h"
#import "YHButton.h"
#import "YHLocalViewController.h"
#import "YHRemoteViewController.h"

@interface ViewController ()

@property (nonatomic, strong) YHButton *display;
@property (nonatomic, strong) YHButton *displayPresent;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
}

- (void)setUp {
    self.title = @"项目演示";
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat width = 200;
    CGFloat height = 50;
    CGFloat x = (self.view.bounds.size.width - width) / 2.0;
    CGFloat y1 = 200;
    _display = [[YHButton alloc]initWithFrame:CGRectMake(x, y1, width, height)];
    _display.title = @"本地图片展示";
    _display.buttonColor = [UIColor colorWithRed:70 / 225.0 green:187 / 255.0 blue:38 / 255.0 alpha:1];
    typeof(self) __weak weakSelf = self;
    _display.operation = ^{
        [weakSelf displayAnimation];
    };
    [self.view addSubview:_display];
    
    _displayPresent = [[YHButton alloc]initWithFrame:CGRectMake(x, y1+ height *2, width, height)];
    _displayPresent.title = @"网络图片展示";
    _displayPresent.buttonColor = [UIColor colorWithRed:230 / 225.0 green:103 / 255.0 blue:103 / 255.0 alpha:1];
    _displayPresent.operation = ^{
        [weakSelf displayAnimationPresent];
    };
    [self.view addSubview:_displayPresent];
}

- (void)displayAnimation {
    YHLocalViewController *l = [[YHLocalViewController alloc]init];
    [self.navigationController pushViewController:l animated:YES];
}

- (void)displayAnimationPresent {
    YHRemoteViewController *r = [[YHRemoteViewController alloc]init];
    [self.navigationController pushViewController:r animated:YES];
}



@end
