//
//  YHSquareView.h
//  YHPhotoBrowser
//
//  Created by ruaho on 2019/7/26.
//  Copyright © 2019 ruaho. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CallBack)(NSInteger index);

@interface YHSquareView : UIView

@property (nonatomic, strong, readonly) NSMutableArray <UIImageView *>*imageViews;
@property (nonatomic, copy) CallBack callBack;

- (instancetype)initWithItems:(NSArray *)items;

@end

NS_ASSUME_NONNULL_END
