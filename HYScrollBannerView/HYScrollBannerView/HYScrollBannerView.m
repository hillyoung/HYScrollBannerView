//
//  HYScrollBannerView.m
//  eStyle
//
//  Created by luculent on 16/8/30.
//  Copyright © 2016年 hillyoung. All rights reserved.
//

#import "HYScrollBannerView.h"
#import "MBProgressHUD.h"
#import "UIView+WebCacheOperation.h"
#import "UIImageView+WebCache.h"

typedef void(^SMWebImageCompletionWithFinishedBlock)(UIImage *image);

@interface UIImageView (SMImg)

- (void)hy_setImageWithUrlString:(NSString *)urlString placeholderImage:(UIImage *)placeHolderImage;

@end

@implementation UIImageView (SMImg)

- (void)hy_setImageWithUrlString:(NSString *)urlString placeholderImage:(UIImage *)placeHolderImage{
    [self hy_setImageWithUrlString:urlString placeholderImage:placeHolderImage completed:nil];
}

- (void)hy_setImageWithUrlString:(NSString *)urlString placeholderImage:(UIImage *)placeHolderImage completed:(SMWebImageCompletionWithFinishedBlock)completedBlock{
    
    [self sd_cancelCurrentImageLoad];
    
    NSURL *url = [NSURL URLWithString:urlString];
    SDWebImageManager *imageMgr = [SDWebImageManager sharedManager];
    // 检查磁盘缓存
    NSString *storeKey = [imageMgr cacheKeyForURL:url];
    __block UIImage *roundImage = [imageMgr.imageCache imageFromDiskCacheForKey:storeKey];
    
    if (roundImage) { // 缓存有图片
        self.image = roundImage;
        if (completedBlock != nil) {
            completedBlock(roundImage);
        }
    } else { // 缓存没图片
        self.image = placeHolderImage;
        // 开始下载
        if (url) {
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
            hud.color = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
            hud.activityIndicatorColor = [UIColor lightGrayColor];
            hud.mode = MBProgressHUDModeAnnularDeterminate;
            hud.progress = 0.5;
            __weak typeof(self) weakSelf = self;
            id <SDWebImageOperation> operation = [imageMgr downloadImageWithURL:url options:SDWebImageRetryFailed | SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                // 下载中
                hud.progress = receivedSize/expectedSize;
                
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                
                [hud hide:YES];
                if (!weakSelf) return;
                dispatch_main_sync_safe(^{
                    if (!weakSelf) return;
                    if (image) {
                        // 下载成功
                        // 在这里处理image
                        
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            
                            roundImage = image;
                            
                            dispatch_main_sync_safe(^{
                                
                                if (completedBlock != nil) {
                                    completedBlock(image);
                                }
                                
                                [UIView transitionWithView:self duration:1. options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction animations:^{
                                    weakSelf.image = roundImage;
                                } completion:^(BOOL finished) {
                                    [weakSelf setNeedsLayout];
                                }];
                            });
                        });
                        
                    } else {
                        // 下载失败
                        weakSelf.image = placeHolderImage;
                        [weakSelf setNeedsLayout];
                    }
                });
            }];
            [self sd_setImageLoadOperation:operation forKey:@"UIImageViewImageLoad"];
        }
    }
}

@end

static NSString *reuseIdentifier = @"UICollectionViewCell";
@interface HYScrollBannerView ()<UICollectionViewDataSource, UICollectionViewDelegate>

/**
 *  计时器
 */
@property (strong, nonatomic) NSTimer *timer;
/**
 *  分页控制视图
 */
@property (strong, nonatomic) UIPageControl *page;

@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;

@property (strong, nonatomic) UICollectionView *collectionView;

@end

@implementation HYScrollBannerView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGSize size = self.flowLayout.itemSize;
    self.flowLayout.itemSize = CGSizeMake(size.width, CGRectGetHeight(rect));
}

- (void)dealloc {
    
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    if (newWindow) {
        self.timer.fireDate = [[NSDate date] dateByAddingTimeInterval:1];
    } else {
        self.timer.fireDate = [NSDate distantFuture];
    }
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    [_timer invalidate];
}

#pragma mark - 初始化设置

- (void)setupUI {
    [self addSubview:self.collectionView];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
    
    [self addSubview:self.page];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.page attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-20]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.page attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-20]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.page attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self.page addConstraint:[NSLayoutConstraint constraintWithItem:self.page attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20]];
}

#pragma mark - setter方法

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.itemSize = CGSizeMake(kScreenWidth, 10);
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.minimumInteritemSpacing = 0;
    }
    
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    }
    
    return _collectionView;
}

- (UIPageControl *)page {
    if (!_page) {
        _page = [[UIPageControl alloc] init];
        _page.translatesAutoresizingMaskIntoConstraints = NO;
        _page.tintColor = kRandomColor;
        _page.currentPageIndicatorTintColor = kRandomColor;
    }
    
    return _page;
}

// 这里是添加计时器的
- (void)setTimeInterval:(NSTimeInterval)timeInterval {
    
    if (_timeInterval != timeInterval) {
        _timeInterval = timeInterval;
    }
    
    [self setupTimer];
}

#pragma mark - Private

- (void)setupTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(autoScroll) userInfo:nil repeats:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    // 这里设置成3组, 让界面上显示的永远都停留在中间的那一组
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if ([self.dataSource respondsToSelector:@selector(numberInBannerView:)]) {
        NSUInteger imageCount = [self.dataSource numberInBannerView:self];
        self.page.numberOfPages = imageCount;
        return imageCount;
    }
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.frame.size.height)];
    
    id source = nil;
    
    if ([self.dataSource respondsToSelector:@selector(bannerView:sourceForIndex:)]) {
        source = [self.dataSource bannerView:self sourceForIndex:indexPath.row];
    }
    
    if ([source isKindOfClass:[UIImage class]]) {
        
        imageView.image = source;
    } else if ([source isKindOfClass:[NSString class]]) {
        // 这里需要你自己设置占位图 (这里替换图片的时候默认使用溶解动画)
        [imageView hy_setImageWithUrlString:source placeholderImage:[UIImage imageNamed:@"button_keyboard_emotions"]];
    }
    
    [cell.contentView addSubview:imageView];
    
    return cell;
}

#pragma mark - cell的点击事件

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(bannerView:didSelectedIndex:)]) {
        [self.delegate bannerView:self didSelectedIndex:indexPath.row];
    }
}

#pragma mark - 这里是在手动滑动将要开始的时候将计时器停止(移除), 防止其在后台还在计时, 造成滚动多页的情况

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.timer invalidate];
    [self keepInMiddleGroupWithScrollView:self.collectionView];
}

#pragma mark - 这里是处理手动滑动之后视图的位置调整

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (self.timer.valid) {
        [self.timer invalidate];
    }
    
    [self keepInMiddleGroupWithScrollView:self.collectionView];
    [self setupTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    CGFloat temp = scrollView.contentOffset.x / kScreenWidth;
    int i = 0;
    if (temp - (CGFloat)((int)temp) > 0.0) {
        i = (int)temp + 1;
    } else {
        i = (int)temp;
    }
    
    if ([self.dataSource respondsToSelector:@selector(numberInBannerView:)]) {
        self.page.currentPage = i % [self.dataSource numberInBannerView:self];
    }
}

#pragma mark - 这里是处理定时器滚动完之后视图位置调整

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self keepInMiddleGroupWithScrollView:scrollView];
}

#pragma mark - 这里是计时器带动视图滚动的处理

- (void)autoScroll {
    CGPoint offset = self.collectionView.contentOffset;
    offset.x = offset.x + kScreenWidth;
    if (offset.x - (CGFloat)((int)offset.x) != 0) {
        offset.x = (int)offset.x + 1;
    }
    
    [self.collectionView scrollRectToVisible:CGRectMake(offset.x, 0, kScreenWidth, self.frame.size.height) animated:YES];
    NSLog(@"滚动中");
}

#pragma mark - 这个方法是为了保证视图永远处在最中间的那一组, 不会滚动到头

- (void)keepInMiddleGroupWithScrollView:(UIScrollView *)scrollView {
    
    CGFloat temp = scrollView.contentOffset.x / kScreenWidth;
    int i = ceil(temp);
    
    NSUInteger imageCount = 0;
    
    if ([self.dataSource respondsToSelector:@selector(numberInBannerView:)]) {
        imageCount = [self.dataSource numberInBannerView:self];
    }
    
    self.page.currentPage = i % imageCount;
    
    if (scrollView.contentOffset.x < kScreenWidth * imageCount || scrollView.contentOffset.x >  kScreenWidth * (imageCount * 2 - 1)) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:i % imageCount inSection:1] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    } else {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:i % imageCount inSection:1] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
}

@end

