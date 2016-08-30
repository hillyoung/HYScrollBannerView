//
//  ViewController.m
//  AutoScrollView
//
//  Created by hillyoung on 16/8/19.
//  Copyright © 2016年 hillyoung. All rights reserved.
//

#import "ViewController.h"
#import "HYScrollBannerView.h"

@interface ViewController ()<HYScrollBannerDelegate, HYScrollBannerDataSource>

@property (strong, nonatomic) NSArray *array;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    HYScrollBannerView *collection = [[HYScrollBannerView alloc] initWithFrame:CGRectMake(0, 20, kScreenWidth, 200)];
    // 这里是设置轮播图的播放间隔
    collection.timeInterval = 3.0;
    collection.delegate = self;
    collection.dataSource = self;
    collection.page.currentPageIndicatorTintColor = [UIColor purpleColor];
    // 这里直接传图片的URL字符串(切记是字符串), 要不你还要改里面的图片赋值语句
    self.array = [NSArray arrayWithObjects:@"http://image.baidu.com/search/down?tn=download&word=download&ie=utf8&fr=detail&url=http%3A%2F%2Fp2.gexing.com%2Fkongjianpifu%2F20120713%2F1622%2F4fffdacf88244.jpg&thumburl=http%3A%2F%2Fimg4.imgtn.bdimg.com%2Fit%2Fu%3D3737218198%2C1821201454%26fm%3D21%26gp%3D0.jpg", @"http://d-smrss.oss-cn-beijing.aliyuncs.com/customerportrait/004/888/4f564995-a919-4c7f-ae8f-d8d0bda1d7f4_100x100.jpg", @"http://d-smrss.oss-cn-beijing.aliyuncs.com/customerportrait/004/869/2ebc752a-5176-4f16-b7b5-2233d4ddcc87_100x100.jpg", @"http://d-smrss.oss-cn-beijing.aliyuncs.com/customerportrait/004/888/4f564995-a919-4c7f-ae8f-d8d0bda1d7f4_100x100.jpg", @"http://d-smrss.oss-cn-beijing.aliyuncs.com/customerportrait/004/903/847d2925-7d03-40dd-90d9-429d13aabab8_100x100.jpg", nil];
    [self.view addSubview:collection];
    // 此属性一定要在collectionView添加到俯视图之后再设置, 这里是设置的轮播图数量
//    collection.imagesCount = 5;
    // 设置代理(用来解决图片的点击事件)

    
}


- (void)dealloc {
    
}

#pragma mark - 这里实现cell的点击事件(根据index(也就是indexPath.item))

- (NSInteger)numberInBannerView:(HYScrollBannerView *)bannerView {
    return 5;
}

- (id)bannerView:(HYScrollBannerView *)bannerView sourceForIndex:(NSInteger)index {
    return self.array[index];
}

- (void)bannerView:(HYScrollBannerView *)bannerView didSelectedIndex:(NSInteger)index {
    NSLog(@"点击了第%ld张图片", index);
    
    UIViewController *VC = [[UIViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
