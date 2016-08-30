//
//  HYScrollBannerView.h
//  eStyle
//
//  Created by luculent on 16/8/30.
//  Copyright © 2016年 hillyoung. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kRandomColor [UIColor colorWithRed:arc4random_uniform(256) / 255.0 green:arc4random_uniform(256) / 255.0 blue:arc4random_uniform(256) / 255.0 alpha:1.0]

@class HYScrollBannerView;

@protocol HYScrollBannerDelegate <NSObject>
@optional

/**
 *  轮播图的点击事件
 *
 *  @param index 被点击的轮播图的序号
 */
- (void)bannerView:(HYScrollBannerView *)bannerView didSelectedIndex:(NSInteger)index;    // fixed font style. use custom view (UILabel) if you want something different

@end

@protocol HYScrollBannerDataSource <NSObject>

- (NSInteger)numberInBannerView:(HYScrollBannerView *)bannerView;

- (id)bannerView:(HYScrollBannerView *)bannerView sourceForIndex:(NSInteger)index;

@end

/**
 *  基于sdwebimage和MBProgressHUD进行的封装
 */
@interface HYScrollBannerView : UIView

/**
 *  用来处理点击事件的代理
 */
@property (weak, nonatomic) id <HYScrollBannerDelegate> delegate;

/**
 *  数据源
 */
@property (weak, nonatomic) id <HYScrollBannerDataSource> dataSource;

/**
 *  分页控件
 */
@property (strong, nonatomic, readonly) UIPageControl *page;

/**
 *  轮播图自动播放的时间间隔
 */
@property (assign, nonatomic) NSTimeInterval timeInterval;

@end
